% Copyright © 2013,2014,2015 Pavel Krizek, Tomas Lukes, lukestom@fel.cvut.cz
%
% This file is part of SIMToolbox.
%
% SIMToolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% SIMToolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with SIMToolbox.  If not, see <http://www.gnu.org/licenses/>.

%-----------------------------------------------------------------------------
function process(cfg)
% process(cfg,imginfo, ptrninfo, calinfo)
%-----------------------------------------------------------------------------

global data
% clear progress bar
hndlprb = data.hndl.axPrgBar;
progressbarGUI(hndlprb);
c = 0;

% initialize processing
[imginfo, ptrninfo, calinfo, angles, cfg] = initprocess(cfg);

% SIM: initialize peak position
if cfg.sim.enable || cfg.msm.enable
%     waitbar(0, hndlwb, 'Finding position of peaks');
    % find and assign peaks
    if ~isfield(data,'ptrn')
        ptrn = sim_findpeaksassign(imginfo,ptrninfo,calinfo,cfg,hndlprb);
        if isempty(ptrn)
%             if ishandle(hndlwb), delete(hndlwb); end
            return;
        else
            data.ptrn = ptrn;
        end
    else
        ptrn = data.ptrn;
    end
end

% VSM, MSM: precompute virtual mask
if ~isempty(ptrninfo) && ...
        (any([cfg.db.vsm([cfg.vsm.eval.enable]==1).applymask]) || cfg.msm.enable)
    % create pattern mask
    if strcmp(cfg.sim.spotfindermethod.type,'calibration')
        if ~isempty(calinfo)
            ptrninfo.MaskOn = seq2subseq(ptrnmaskprecompute(imginfo, ptrninfo, calinfo, ...
                'runningorder', cfg.ptrn.ro,'sigma',cfg.ptrn.blure,'progressbar',hndlprb),ptrninfo,cfg.ptrn.ro);
        else
            return;
        end
    else
        ptrninfo.MaskOn = genMasks(imginfo,ptrn,hndlprb);
    end
end

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

nummeth = sum([cfg.vsm.eval.enable,cfg.sim.enable,cfg.msm.enable]);
% clear progress bar
progressbarGUI(hndlprb);
% process all time stamps
for T = 1:imginfo.image.size.t
    % for all z-sections
    for Z = 1:imginfo.image.size.z
        methID = 0;
        % stop
        if ~data.hndl.btnRun.Value, c = 1; break; end
        
        % update progress bar
        if imginfo.image.size.t>1
            str = sprintf('Processing time %d/%d, section %2d/%d', T, imginfo.image.size.t, Z, imginfo.image.size.z);
        else
            str = sprintf('Processing section %2d/%d', Z, imginfo.image.size.z);
        end
        progressbarGUI(hndlprb,...
                (methID+nummeth*(Z-1)+nummeth*imginfo.image.size.z*(T-1))/...
                (imginfo.image.size.t*imginfo.image.size.z*nummeth),...
                str);
        
        % load sequence for the current section & rewind according to pattern offset
        % split sequence if appropriate - based on the running order (e.g,several line patterns)
        seq = seq2subseq(seqload(imginfo, 'z',Z,'t',T,'offset',-cfg.ptrn.offset,'datatype','double'), ptrninfo, cfg.ptrn.ro);
        
        % flatfield correction
        if cfg.vsm.flatfield, [seq,calinfo] = runseqflatfield(seq, calinfo, imginfo); end
        
        % stripe removal
        if cfg.vsm.striperemoval, seq = seqstriperemoval(seq); end
        
        % background substraction
        if data.cfg.vsm.bgsubtract
            thresh = data.cfg.vsm.bgsubtractThresh/data.imginfo.camera.norm;
            seq = seqbgsubtract(seq,thresh);
        end
        
        % stop
        if ~data.hndl.btnRun.Value && methID<nummeth, c = 1; break; end
        
        % VSM sequence processing
        for I = find([cfg.vsm.eval.enable])
            methID = methID+1;
            if cfg.vsm.eval(I).applymask
                im.(cfg.vsm.eval(I).id) = feval(cfg.vsm.eval(I).fnc, seq(angles), ptrninfo.MaskOn(angles));
            else
                im.(cfg.vsm.eval(I).id) = feval(cfg.vsm.eval(I).fnc, seq(angles));
            end
            progressbarGUI(hndlprb,...
                (methID+nummeth*(Z-1)+nummeth*imginfo.image.size.z*(T-1))/...
                (imginfo.image.size.t*imginfo.image.size.z*nummeth),...
                str);
        end
        
        % stop
        if ~data.hndl.btnRun.Value && methID<nummeth, c = 1; break; end
        
        % SIM sequence processing
        if cfg.sim.enable
            methID = methID+1;
            im.sr = processsim(seq(angles),ptrn(angles),cfg);
            progressbarGUI(hndlprb,...
                (methID+nummeth*(Z-1)+nummeth*imginfo.image.size.z*(T-1))/...
                (imginfo.image.size.t*imginfo.image.size.z*nummeth),...
                str);
        end
        
        % stop
        if ~data.hndl.btnRun.Value && methID<nummeth, c = 1; break; end
        
        % MAP-SIM processing
        if cfg.msm.enable
            methID = methID+1;
            [im.mapsim,cfg.msm] = mapsim( ...
                seq(angles),...
                ptrninfo.MaskOn(angles),...
                seqcfhomodyne(seq(angles)),...
                cfg.msm);
            progressbarGUI(hndlprb,...
                (methID+nummeth*(Z-1)+nummeth*imginfo.image.size.z*(T-1))/...
                (imginfo.image.size.t*imginfo.image.size.z*nummeth),...
                str);
        end
        
        % stop
        if ~data.hndl.btnRun.Value && methID<nummeth, c = 1; break; end
        
        % save results
        figssave(imginfo,im,cfg);
        
        % clear memory due to memory problems with long sequences
        clear('seq');
        
    end%Z
end%T

%%% AFTER PROCESSING ALL ZPLANES %%%
if strcmp(cfg.msm.meth,'CUDA')
    MapcoreCudaFinish();
end %%% AFTER PROCESSING ALL ZPLANES %%%

if c
    progressbarGUI(hndlprb,'SIM reconstruction was canceled.','red');
else
    % close figures & waitbar
    progressbarGUI(hndlprb,1,'SIM reconstruction is successfully completed.');
    btn = questdlg([sprintf('Output images were saved into the data directory:\n') ...
        cfg.resdir], 'Processing was successfully finished.', ...
        'OK','Open folder','OK');
    if strcmp(btn,'Open folder')
        winopen(cfg.resdir);
    end
end

%-----------------------------------------------------------------------------
function stop(h, varargin)                        % Callback for Cancel button
%-----------------------------------------------------------------------------
delete(get(h,'Parent'));

%-----------------------------------------------------------------------------
function [imginfo, ptrninfo, calinfo, angles, cfg] = initprocess(cfg)
%-----------------------------------------------------------------------------

% some angles must be selected
angles = logical([cfg.ptrn.angles.enable]);
if ~any(angles) || ~any([[cfg.vsm.eval.enable],cfg.sim.enable,cfg.msm.enable])
    error('process:init', 'No angles selected.');
end

% initialize source images
imginfo = imginfoinit(cfg.datadir,cfg.filemask);
assert(imginfo.image.size.w == 1, 'process:init', 'Number of channels is limited to one only.');

% initialize calibration
try
    calinfo = calload(cfg.cal.calibr);
catch err
    calinfo = [];
end

% initialize patterns
ptrninfo = ptrnopen(cfg.ptrn.repz);
ptrninfo.MaskOn = [];
assert(ptrngetnumseq(ptrninfo, cfg.ptrn.ro) == imginfo.image.size.seq, 'process:init', 'Number of patterns is not consistent.');

% options for VSM
[cfg.vsm.eval(:).id] = deal([]);
[cfg.vsm.eval(:).applymask] = deal([]);
[cfg.vsm.eval.id] = cfg.db.vsm.id;
[cfg.vsm.eval.applymask] = cfg.db.vsm.applymask;

% initialize output directory and remove all existing tif files
cfg.resdir = fixresname(cfg.resdir, imginfo.data.dir, imginfo.data.filemask);
if ~isfolder(cfg.resdir)
    mkdir(cfg.resdir);
else
    delete([cfg.resdir filesep '*.tif']);
end

% save config
cfgsave([cfg.resdir filesep imginfo.data.filemask '.cfg'], imginfo, cfg);

%------------------------------------------
function IMsr = processsim(seq,ptrn,cfg)
%------------------------------------------
% SIM sequence processing
otf = cfg.sim.otf;
% padding and smoothing of image borders to remove ugly cross in FFT
seq = seqpadsmooth(seq,cfg.sim.smoothpadsize,cfg.sim.smoothsigma);
% compute expanded spectra for all illumination angles
seq = sim_extract(seq,ptrn);
% shift expanded spectra to center position
seq = sim_shiftspectra(seq,ptrn,cfg.sim);
% generating shifted OTFs
seq = sim_addOTF(seq,ptrn,otf);
% combining spectra
IMsr = sim_combine(seq,cfg.sim);
if cfg.sim.upsample
    IMsr = imgrmpadding(IMsr,cfg.sim.smoothpadsize*2);
else
    IMsr = imgrmpadding(IMsr,cfg.sim.smoothpadsize);
end

%------------------------------------------
function figssave(imginfo,im,cfg)
%------------------------------------------
names = fieldnames(im);
ind = find([cfg.save.enable]);
for m = 1:length(names)
    feval(cfg.save(ind).fnc,imginfo.camera.norm*im.(names{m}), ...
          [cfg.resdir filesep imginfo.data.filemask '_' names{m} '.tif']);
end

%eof
