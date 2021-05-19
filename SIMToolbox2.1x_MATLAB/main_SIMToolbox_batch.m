%% main_MAPSIM_from_Toolbox_batch
clear; clc;

addpath(genpath('utils'));
javaaddpath('utils\yaml\java\snakeyaml-1.9.jar');

datapath = uigetdir('','Choose initial folder with subfolders.');
if ~nnz(datapath)
    fprintf(2,'No data input.\n');
    return
else
    [caliName, caliPath] = uigetfile({'*.yaml', 'Calibration file .YAML'},...
        'Open calibration file',fileparts(datapath));
end

fol = getsubfolders(datapath,'*.tif');
% fol = fol(cellfun(@isempty,strfind(squeeze(struct2cell(fol)),'res')));
fol = fol(~contains(struct2cell(fol),'res'));
ind = choosefolder(fol);

%% run batch
for f = ind
    
    [filePath,fileMask,~] = fileparts(fol(f).path);
    resFolder = [filePath filesep 'results_' datestr(date,'YYmmDD')];
    
    % load data info
    % idataPath ... path to folder
    % calibName ... full path with name
    data = load_data(filePath,fileMask,[caliPath caliName]);
    
    % manual settings
    if nnz(resFolder)
        data.cfg.resdir = [resFolder filesep];
    end
    
    data.cfg.vsm.eval(1).enable = 1;    % _av.tif
    data.cfg.vsm.eval(2).enable = 0;    % _maxmin.tif
    data.cfg.vsm.eval(3).enable = 0;    % _maxmin2av.tif
    data.cfg.vsm.eval(4).enable = 1;    % _absexp.tif
    data.cfg.vsm.eval(5).enable = 0;    % _mask.tif
    data.cfg.sim.enable = 1;            % _sr.tif
    data.cfg.msm.enable = 1;            % _mapsim.tif
    
    % sr-sim
    data.cfg.sim.otf.params.rad = 0.25;
    data.cfg.sim.otf.params.type = 'standard';
    data.cfg.sim.apodize.type = 'standard';
    data.cfg.sim.apodize.params.rad = 0.065;
    data.cfg.sim.upsample = 0;
    
    % map-sim                       % def. val.     % Description
    data.cfg.msm.fc = 0.16;         % 0.3           % Cut off frequency for apodization
    data.cfg.msm.wmerg = 0.9;      % 0.85          % Weights for spectral merging
    data.cfg.msm.alph = 0.5;        % 0.5           % Initial Alpha
    data.cfg.msm.lamb  = 0.0001;    % 0.0001        % Lambda (Normalization Coefficient)
    data.cfg.msm.maxiter = 5;       % 5             % Maximum number of iterations allowed
    data.cfg.msm.thresh = 0.01;     % 0.01          % Convergence Threshold
    data.cfg.msm.upsample = 0;      % 1             % 2x upsampling (yes = 1, no = 0);
    
    % CPU/GPU
    data.cfg.msm.meth = 'CUDA'; % CPU or CUDA
    
    % Bith depth
    data.cfg.save = [ ...
        struct('fnc', 'imgsave16', 'enable', 0), ...
        struct('fnc', 'imgsave32', 'enable', 1)];
    
    
    %%%%%%%%%%% PROCESS %%%%%%%%% %%
    % process(data.cfg,data.imginfo,data.ptrninfo,data.calinfo);
    % initialize processing
    [imginfo,ptrninfo,calinfo,angles,cfg] = initprocess(data.cfg);
    
    % spot finder method
    if cfg.sim.enable || cfg.msm.enable
        % data.ptrn
        % add number of harmonics into running order
        [ptrn,numangles] = ptrnchecklines(ptrninfo,cfg.ptrn.ro);
        for m = 1:numangles
            ptrn(m).numharmon = cfg.ptrn.angles(m).numharmon;
            ptrn(m).enable = cfg.ptrn.angles(m).enable;
        end
        if isempty(calinfo)    % NO CALIBRATION
            % initialize peak position without calibration
            % filter type
            %   1: 'dao'        2: 'daoint'     3: 'diffav'
            %   4: 'dog'        5: 'dogint'     6: 'gauss'
            %   7: 'gaussint'   8: 'none'       9: 'wavelet'
            idx = 6;
            cfg.db.spotfinder.selection.filter = cfg.db.spotfinder.filter(idx).type;
            cfg.sim.spotfindermethod = spotfinder_method_spotfinder(cfg.db.spotfinder);
            
            
            str = '5*std(F)';   % 6*std(F) - default
            cfg.db.spotfinder.detector.params.threshold.params.fnc = str;
            cfg.sim.spotfindermethod.params.detector.params.threshold.params.fnc = str;
            
            ptrn = [];
            while cfg.sim.spotfindermethod.params.radius < 12 && isempty(ptrn)
                fprintf('\tFinding position of peaks. Radius: %2.1f\n', ...
                    cfg.sim.spotfindermethod.params.radius);
                ptrn = sim_findpeaksassign(imginfo,ptrninfo,calinfo,cfg,[]);
                if isempty(ptrn)
                    fprintf(2,'Peaks were not detected. Increase radius.\n');
                    cfg.sim.spotfindermethod.params.radius = ...
                        cfg.sim.spotfindermethod.params.radius + 0.5;
                end
            end
            
        else    % WITH CALIBRATION
            % initialize peak position with calibration
            ptrn = sim_findpeaksassign(imginfo,ptrninfo,calinfo,cfg,[]);
        end
        if isempty(ptrn)
            fprintf(2,'Peaks were not detected.\n');
            return;
        elseif ~isempty(ptrn)
            fprintf('\t\t- Peaks were succesfuly detected.\n');
        end
    end
    
    % VSM: precompute virtual mask
    if ~isempty(ptrninfo) && ...
            ~isempty(calinfo) && ...
            (any([cfg.db.vsm([cfg.vsm.eval.enable] == 1).applymask]) || ...
            cfg.msm.enable)
        ptrninfo.MaskOn = seq2subseq(ptrnmaskprecompute(imginfo, ptrninfo, calinfo, ...
            'runningorder', cfg.ptrn.ro, 'sigma', cfg.ptrn.blure), ...
            ptrninfo, cfg.ptrn.ro);
    end
    
    % process
    if imginfo.image.size.t>1 && imginfo.image.size.z == 1 % video sequence
        cfg.msm.vidnorm.enable = 1;
    end
    
    %%% INIT CUDA ONCE HERE %%%
    if strcmp(cfg.msm.meth,'CUDA')
        MapcoreCudaPrepare([...
            imginfo.image.size.x,...
            imginfo.image.size.y,...
            sum(angles)*imginfo.image.size.seq/length(ptrn),...
            cfg.msm.maxiter,...
            cfg.msm.lamb,...
            cfg.msm.alph,...
            cfg.msm.thresh,...
            cfg.msm.fc]);
    end %%% INIT CUDA ONCE HERE %%%
    
    % for all time stamps
    totT = tic;
    for T = 1:imginfo.image.size.t
        % for all z-sections
        zT = tic;
        for Z = 1:imginfo.image.size.z
            
            % update progress bar
            if imginfo.image.size.t > 1
                fprintf('\tProcessing time %d/%d\n, section %2d/%d', T, ...
                    imginfo.image.size.t, Z, imginfo.image.size.z);
            else
                fprintf('\tProcessing section %2d/%d', Z, imginfo.image.size.z);
            end
            
            % load sequence
            try
                seq = seq2subseq(seqload(imginfo, 'z',Z,'t',T,...
                    'offset',-cfg.ptrn.offset,'datatype','double'), ptrninfo, cfg.ptrn.ro);
            catch seq
                break;
            end
            
            % flatfield correction
            if cfg.vsm.flatfield
                [seq,calinfo] = runseqflatfield(seq, calinfo, imginfo);
            end
            
            % flatfield correction
            if ~isempty(calinfo) && cfg.vsm.flatfield
                [seq,calinfo] = runseqflatfield(seq, calinfo, imginfo);
            end
            
            % remove stripes in raw data
            if cfg.vsm.striperemoval, seq = seqstriperemoval(seq); end
            
            % VSM sequence processing
            for m = find([cfg.vsm.eval.enable])
                if cfg.vsm.eval(m).applymask
                    im.(cfg.vsm.eval(m).id) = feval(cfg.vsm.eval(m).fnc, ...
                        seq(angles),ptrninfo.MaskOn(angles));
                else
                    im.(cfg.vsm.eval(m).id) = feval(cfg.vsm.eval(m).fnc,seq(angles));
                end
            end
            
            % SIM sequence processing
            if cfg.sim.enable
                im.sr = processsim(seq(angles),ptrn(angles),cfg);
            end
            
            
            % MAP-SIM processing
            if cfg.msm.enable
                if ~exist('im','var') || ~isfield(im,'absexp')
                    im.absexp = seqcfhomodyne(seq(angles));
                end
                
                %%% if the calibration is not known and patterns are estimated from the data
                if cfg.msm.enable && isempty(calinfo)
                    cfg.msm.estimate = 1;
                    
                    if ~isempty(ptrninfo.MaskOn) % patterns were already estimated
                        [im.mapsim, cfg.msm] = mapsim( ...
                            seq(angles),...
                            ptrninfo.MaskOn(angles),...
                            im.absexp,...
                            cfg.msm);
                    else
                        % patterns does not exist -> estimate patterns
                        ptrn = sim_findpeaksassign(imginfo, ptrninfo, calinfo, Z, cfg);
                        if isempty(ptrn), updateDlgMain('on','mapsimpreview'); return; end
                        
                        ptrninfo.MaskOn = genMasks(seq,ptrn);
                        [im.mapsim, cfg.msm] = mapsim( ...
                            seq(angles),...
                            ptrninfo.MaskOn(angles),...
                            im.absexp,...
                            cfg.msm);
                    end
                    
                elseif cfg.msm.enable && ~isempty(calinfo)
                    %%% if the calibration is known - patterns are known
                    cfg.msm.estimate = 0;
                    [im.mapsim, cfg.msm] = mapsim( ...
                        seq(angles),...
                        ptrninfo.MaskOn(angles),...
                        im.absexp,...
                        cfg.msm);
                end
            end
            
            % 1 - av
            % 2 - maxmin
            % 3 - maxmin2av
            % 4 - absexp
            % 5 - mask
            if ~cfg.vsm.eval(4).enable && isfield(im,'absexp')
                im = rmfield(im,'absexp');
            end
            
            % save results
            figssave(imginfo,im,cfg);
            
            % clear memory due to memory problems with long sequences
            clear seq;
            zTime = toc(zT);
            fprintf('\t%.2f s\n', zTime);
        end % Z planes
    end % Time
    %%% AFTER PROCESSING ALL ZPLANES %%%
    if strcmp(cfg.msm.meth,'CUDA')
        MapcoreCudaFinish();
    end %%% AFTER PROCESSING ALL ZPLANES %%%
    
    fprintf('Images are stored in: %s\n',cfg.resdir);
end % Files
totalTime = toc(totT);
fprintf('Total time: %s\n\n', datestr(datenum(0,0,0,0,0,totalTime),'HH:MM:SS:FFF'));

%% delete temp end of all
javarmpath('utils_toolbox\yaml\java\snakeyaml-1.9.jar');
rmpath(genpath('utils_toolbox'));
rmpath(genpath('utils_batch'));
rmdir('temp','s');

