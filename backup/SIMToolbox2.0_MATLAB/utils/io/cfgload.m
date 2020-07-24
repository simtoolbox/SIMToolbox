function cfg = cfgload(imginfo, cfg)

% Copyright © 2009-2015 Pavel Krizek
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

try
    % load previously saved settings
    assert(~isempty(imginfo), 'cfgload:nodata', 'Cannot load configuration as there are no image data.');
    filename = [imginfo.data.dir filesep imginfo.data.filemask '.cfg'];
    assert(isfile(filename), 'cfgload:nofile', 'Configuration file not found.');
    c = YAML.read(filename);
    assert(strcmp(c.id, 'SIM_config'), 'cfgload:filecorrupted', 'Configuration file corrupted.');
    
    % load calibration, pattern, and other options
    cfg.cal = c.cal;
    cfg.ptrn = c.ptrn;
    cfg.sim = c.sim;
    
    % SIM - spotfinder parameters - override defaults with saved values
    if strcmp(cfg.sim.spotfindermethod.type,'spotfinder')
        cfg.db.spotfinder.selection.filter = c.sim.spotfindermethod.params.filter.type;
        cfg.db.spotfinder.selection.detector = c.sim.spotfindermethod.params.detector.type;
        cfg.db.spotfinder.selection.estimator = c.sim.spotfindermethod.params.estimator.type;
        cfg.db.spotfinder.filter(strcmp(cfg.db.spotfinder.selection.filter,{cfg.db.spotfinder.filter.type})).params = c.sim.spotfindermethod.params.filter.params;
        cfg.db.spotfinder.detector(strcmp(cfg.db.spotfinder.selection.detector,{cfg.db.spotfinder.detector.type})).params = c.sim.spotfindermethod.params.detector.params;
        cfg.db.spotfinder.estimator(strcmp(cfg.db.spotfinder.selection.estimator,{cfg.db.spotfinder.estimator.type})).params = c.sim.spotfindermethod.params.estimator.params;
    end
    
    % vsm options
    cfg.vsm.flatfield = c.vsm.flatfield;
    cfg.vsm.striperemoval = c.vsm.striperemoval;
    for I = 1:length(cfg.vsm.eval)
        if any(strcmp(cfg.vsm.eval(I).fnc,c.vsm.eval))
            cfg.vsm.eval(I).enable = 1;
        else
            cfg.vsm.eval(I).enable = 0;
        end
    end
    
catch err
    
    if strcmp(err.identifier, 'cfgload:filecorrupted')
        waitfor(warndlg(err.message, 'Warning', 'modal'));
    end
    
    % change cfg using default options
    c = config();
    
    cfg.resdir = c.resdir;
    cfg.preview = c.preview;
    cfg.cal = c.cal;
    cfg.ptrn = c.ptrn;
    cfg.sim = c.sim;
    cfg.msm = c.msm;
    cfg.vsm = c.vsm;
    
    % set path to calibration file and pattern repertoire
    if ~isempty(imginfo)
        cfg.cal.calibr = imginfo.data.dir;
        cfg.ptrn.repz = imginfo.data.dir;
        try
            if ~isfield(imginfo, 'pattern')
                cfg.ptrn.repz = ptrndirinfo(imginfo.data.dir); % look for pattern repz in datadir
            end
        catch err
%             waitfor(warndlg(err.message, 'Warning', 'modal'));
        end
    else
        cfg.cal.calibr = '';
        cfg.ptrn.repz = '';
    end
    
end

% reset preview and set Z to half of the range
cfg.preview.t = 1;
if ~isempty(imginfo)
    cfg.preview.z = ceil(imginfo.image.size.z/2);
else
    cfg.preview.z = 1;
end

% set resolution for OTF and SIM  apodization
if isempty(imginfo)
    cfg = setresolution(cfg, NaN);
else
    cfg = setresolution(cfg, imginfo.image.resolution.x);
end

%-----------------------------------------------------------------------------
function cfg = setresolution(cfg, resolution)
%-----------------------------------------------------------------------------
cfg.sim.otf.params.resolution = resolution;
cfg.sim.apodize.params.resolution = resolution;

%eof