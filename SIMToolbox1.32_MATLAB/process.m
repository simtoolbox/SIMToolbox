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
function process(cfg,imginfo, ptrninfo, calinfo)
%-----------------------------------------------------------------------------

% create progress bar
hndlwb = waitbar(0,'Initializing ...','CreateCancelBtn',@stop,'Name','Processing ...','Tag','WaitBar','WindowStyle','modal');
pos = get(hndlwb,'Position');
set(hndlwb,'Position',pos+[0 1.5*pos(4) 0 0]);

% initialize processing
[imginfo, ptrninfo, calinfo, angles, cfg] = initprocess(cfg);

% SIM: initialize peak position
if cfg.sim.enable
    waitbar(0, hndlwb, 'Finding position of peaks');
    ptrn = sim_findpeaksassign(imginfo, ptrninfo, calinfo, round(imginfo.image.size.z/2), cfg);   % ???   Z
end

% VSM: precompute virtual mask
if ~isempty(ptrninfo) && ~isempty(calinfo) && (any([cfg.db.vsm([cfg.vsm.eval.enable]==1).applymask]) || cfg.msm.enable==1)
    ptrninfo.MaskOn = seq2subseq(ptrnmaskprecompute(imginfo, ptrninfo, calinfo, ...
        'runningorder', cfg.ptrn.ro, 'sigma', cfg.ptrn.blure, 'progressbar', hndlwb), ptrninfo, cfg.ptrn.ro);
end

% process all time stamps
for T = 1:imginfo.image.size.t
    
    % for all z-sections
    for Z = 1:imginfo.image.size.z
        
        % stop
        if ~ishandle(hndlwb), break; end;
        
        % update progress bar
        if imginfo.image.size.t>1,
            str = sprintf('Processing time %d/%d, section %2d/%d', T, imginfo.image.size.t, Z, imginfo.image.size.z);
            if ishandle(hndlwb), waitbar((T*imginfo.image.size.z+Z)/imginfo.image.size.t/imginfo.image.size.z, hndlwb, str); end;
        else
            str = sprintf('Processing section %2d/%d', Z, imginfo.image.size.z);
            if ishandle(hndlwb), waitbar(Z/imginfo.image.size.z, hndlwb, str); end;
        end;
        
        % load sequence
        seq = seq2subseq(seqload(imginfo, 'z',Z,'t',T,'offset',-cfg.ptrn.offset,'datatype','double'), ptrninfo, cfg.ptrn.ro);
        
        % flatfield correction
        if cfg.vsm.flatfield
            [seq,calinfo] = runseqflatfield(seq, calinfo, imginfo);
        end
        
        % remove stripes in raw data
        if cfg.vsm.striperemoval, seq = seqstriperemoval(seq); end;
        
        % stop
        if ~ishandle(hndlwb), break; end;
        
        % VSM sequence processing
        for I = find([cfg.vsm.eval.enable])
            if cfg.vsm.eval(I).applymask
                im.(cfg.vsm.eval(I).id) = feval(cfg.vsm.eval(I).fnc, seq(angles), ptrninfo.MaskOn(angles));
            else
                im.(cfg.vsm.eval(I).id) = feval(cfg.vsm.eval(I).fnc, seq(angles));
            end
        end
        
        % stop
        if ~ishandle(hndlwb), break; end;
        
        % SIM sequence processing
        if cfg.sim.enable
            im.sr = processsim(seq(angles), ptrn(angles), cfg);
        end
        
        % MAP-SIM processing
        if cfg.msm.enable
            if ~cfg.vsm.eval(4).enable
                im.absexp = seqcfhomodyne(seq(angles));
            end
            
            %%% if the calibration is not known and patterns are estimated from the data
            if cfg.msm.enable && isempty(calinfo)
                cfg.msm.estimate = 1;
                
                if ~isempty(ptrninfo.MaskOn) % patterns were already estimated
                    im.mapsim  = mapsim(seq(angles), ptrninfo.MaskOn(angles), im.absexp, cfg.msm);
                else
                    % patterns does not exist -> estimate patterns
                    ptrn = sim_findpeaksassign(imginfo, ptrninfo, calinfo, Z, cfg);
                    if isempty(ptrn); updateDlgMain('on','mapsimpreview'); return; end;
                    
                    ptrninfo.MaskOn = genMasks(seq,ptrn);
                    im.mapsim  = mapsim(seq(angles), ptrninfo.MaskOn(angles), im.absexp, cfg.msm);
                end
                
            elseif cfg.msm.enable == 1 && ~isempty(calinfo)
                %%% if the calibration is known - patterns are known
                cfg.msm.estimate =0;
                im.mapsim = mapsim(seq(angles), ptrninfo.MaskOn(angles), im.absexp, cfg.msm);
            end
            
        end
        
        % stop
        if ~ishandle(hndlwb), break; end;
        
        % 1 - av
        % 2 - maxmin
        % 3 - maxmin2av
        % 4 - absexp
        % 5 - maask
        if ~cfg.vsm.eval(4).enable && isfield(im,'absexp')
            im = rmfield(im,'absexp');
        end
        
        % save results
        figssave(imginfo, im, cfg);
        
        % clear memory due to memory problems with long sequences
        clear('seq');
        
    end%Z
end%T

% close figures & waitbar
if ishandle(hndlwb), delete(hndlwb); end;

msgbox(['Processing was successfully finished. Output images were saved into the data directory: '...
    cfg.datadir]);


%-----------------------------------------------------------------------------
function stop(h, varargin)                        % Callback for Cancel button
%-----------------------------------------------------------------------------
delete(get(h,'Parent'));

%-----------------------------------------------------------------------------
function [imginfo, ptrninfo, calinfo, angles, cfg] = initprocess(cfg)
%-----------------------------------------------------------------------------

% some angles must be selected
angles = logical([cfg.ptrn.angles.enable]);
if ~any(angles) || ~any([[cfg.vsm.eval.enable], cfg.sim.enable, cfg.msm.enable])
    error('process:init', 'No angles selected.');
end

% initialize source images
imginfo = imginfoinit(cfg.datadir);
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
cfg.vsm.eval().id = [];
cfg.vsm.eval().applymask = [];
[cfg.vsm.eval.id] = cfg.db.vsm.id;
[cfg.vsm.eval.applymask] = cfg.db.vsm.applymask;

% initialize output directory and remove all existing files
cfg.resdir = fixresname(cfg.resdir, imginfo.data.dir, imginfo.data.filemask);
if ~isdir(cfg.resdir),
    mkdir(cfg.resdir);
else
    delete([cfg.resdir '*.tif']);
end

% save config
cfgsave([cfg.resdir imginfo.data.filemask '.cfg'], imginfo, cfg);

%------------------------------------------
function IMsr = processsim(seq, ptrn, cfg)
%------------------------------------------
% SIM sequence processing

otf = cfg.sim.otf;

% padding and smoothing of image borders to remove ugly cross in FFT
seq = seqpadsmooth(seq, cfg.sim.smoothpadsize, cfg.sim.smoothsigma);

% compute expanded spectra for all illumination angles
seq = sim_extract(seq, ptrn);

% shift expanded spectra to center position
seq = sim_shiftspectra(seq, ptrn,cfg.sim);

% generating shifted OTFs
seq = sim_addOTF(seq, ptrn, otf);

% combining spectra
IMsr = sim_combine(seq, cfg.sim);
if cfg.sim.upsample ==1
    IMsr = imgrmpadding(IMsr, cfg.sim.smoothpadsize*2);
else
    IMsr = imgrmpadding(IMsr, cfg.sim.smoothpadsize);
end

%------------------------------------------
function figssave(imginfo, im, cfg)
%------------------------------------------
names = fieldnames(im);
for I = 1:length(names)
    imgsave32(imginfo.camera.norm*im.(names{I}), [cfg.resdir imginfo.data.filemask '_' names{I} '.tif']);
end

%eof
