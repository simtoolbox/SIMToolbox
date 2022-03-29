% Copyright � 2013,2014,2015,2016,2017,2018 Pavel Krizek, Tomas Lukes, Jakub Pospisil
% pospij27@fel.cvut.cz
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

function cfg = config()

cfg.ver = '2020-09-01';
cfg.MTBver = ver('MATLAB');

cfg.datadir = 'data';
cfg.resdir = ['$data$' filesep 'results'];

% reconstruction preview
cfg.preview = struct('t',1,'z',1,'saturate',[0.001 0.999],'cm','gray');

cfg.debug = 0;

% calibration file
cfg.cal.calibr = cfg.datadir;

% repertoire
cfg.ptrn.repz = ['patterns' filesep];
cfg.ptrn.ro = NaN;
cfg.ptrn.blure = 1.35;
cfg.ptrn.offset = 0;
cfg.ptrn.angles = [];

% SR-SIM image processing
cfg.sim.spotfindermethod = [];  % spot finder method
cfg.sim.smoothpadsize = 32;     % image border padding before FFT
cfg.sim.smoothsigma = 0.25;     % image border smoothing before FFT
cfg.sim.harmonweight = [0 1 1]; % weight on harmonics (first index is 0th harmonics)
cfg.sim.wiener = 1;
cfg.sim.otf = struct('type','standard','params',struct('rad',0.25));
cfg.sim.apodize = struct('type','standard','params',struct('rad',0.18));
cfg.sim.enable = 0;
cfg.sim.upsample = 0;

% MAP-SIM image processing
cfg.msm.enable = 0;
cfg.msm.alph = 0.5;         % Initial Alpha
cfg.msm.fc = 0.3;           % Cut-off frequency
cfg.msm.otf = struct('type','standard','params',struct('rad',0.25));
cfg.msm.apodize = struct('type','standard','params',struct('rad',0.18));
cfg.msm.lamb  = 0.0001;     % Lambda (Normalization Coefficient)
cfg.msm.maxiter = 5;        % Maximum number of iterations allowed
cfg.msm.thresh = 0.01;      % Convergence Threshold
cfg.msm.wmerg = 0.85;       % Spectral merging weight
cfg.msm.upsample = 0;

cfg.msm.vidnorm.enable = 0;
cfg.msm.vidnorm.mapmax = NaN;
cfg.msm.vidnorm.hommax = NaN;
cfg.msm.vidnorm.msmmax = NaN;

cfg.msm.vidnorm.mapmin = NaN;
cfg.msm.vidnorm.hommin = NaN;
cfg.msm.vidnorm.msmmin = NaN;

cfg.msm.meth = 'CPU';   % CPU or CUDA (GPU)
cfg.msm.gpuDriverVersion = 9.2;

% OS-SIM image processing
cfg.vsm.flatfield = 0;
cfg.vsm.striperemoval = 1;
cfg.vsm.bgsubtract = 0;
cfg.vsm.bgsubtractThresh = 0;
cfg.vsm.eval = [ ...
  struct('fnc', 'seqwf',          'enable', 1), ...
  struct('fnc', 'seqcfmaxmin',    'enable', 0), ...
  struct('fnc', 'seqcfmaxmin2av', 'enable', 0), ...
  struct('fnc', 'seqcfhomodyne',  'enable', 1), ...
  struct('fnc', 'seqcfscaledsub', 'enable', 0)];

% Save options 16/32bit

cfg.save = [ ...
  struct('fnc', 'imgsave16', 'enable', 0), ...
  struct('fnc', 'imgsave32', 'enable', 1)];

% Preview
cfg.db.preview.z = 1;
cfg.db.preview.t = 1;
cfg.db.preview.cm = {'gray','hot','isolum','jet',...
    'jetwhite','morgenstemning','parula'};

% initialize database with modules
cfg.db.otf = getapodizationnames;
cfg.db.apodize = getapodizationnames;
cfg.db.vsm = getvsmnames(cfg.vsm.eval);
cfg.db.sim = struct('name','SR-SIM','id','sr');
cfg.db.msm = struct('name','MAP-SIM','id','mapsim');
cfg.db.spotfinder.filter = spotfinder_getnames('filter');
cfg.db.spotfinder.detector = spotfinder_getnames('detector');
cfg.db.spotfinder.estimator = spotfinder_getnames('estimator');

% default selection for a spotfinder
cfg.db.spotfinder.selection = struct('filter','wavelet','detector','locmax','estimator','lsq_fitquadric');
cfg.db.spotfinder.radius = 8;       % corresponds to spatial frequency of a 1st harmonics
cfg.db.spotfinder.radiusthr = 0.05; % [percent] maximum distance from a circle with radius corresponding to n-th harmonics
cfg.db.spotfinder.radiusequal = 1;  % equal radius for all angles

cfg.db.manual.k0 = 0;
cfg.db.manual.angl = 0;
cfg.db.manual.phsoff = 0;
cfg.db.manual.radius = 5.5;%8;  % corresponds to spatial frequency of a 1st harmonics
cfg.db.manual.radiusequal = 1; 	% equal radius for all angles

% initialize menu prepareDataDir
cfg.db.estpat.dimorders = {'z-angle-phase-t (Nikon)', ...
    'z-phase-angle-t (Zeiss)', ...
    'phase-z-angle-t (OMX)', ...
    'angle-phase-z-t'};
cfg.db.estpat.numangles = 3;
cfg.db.estpat.numphases = 5;

% ----- override default settings  -----
for I = 1:length(cfg.db.otf)
  if isfield(cfg.db.otf(I).params, 'rad')
    cfg.db.otf(I).params.rad = cfg.sim.otf.params.rad;
  end
end
for I = 1:length(cfg.db.apodize)
  if isfield(cfg.db.apodize(I).params, 'rad')
    cfg.db.apodize(I).params.rad = cfg.sim.apodize.params.rad;
  end
end
cfg.db.spotfinder.filter(strcmp('dog',{cfg.db.spotfinder.filter.type})).params = struct('sigma1',0.5,'sigma2',1,'size',7);
cfg.db.spotfinder.detector(strcmp('locmax',{cfg.db.spotfinder.detector.type})).params = struct('conn',8,'threshold',struct('type','fnc','params',struct('fnc','6*std(F)')));
cfg.db.spotfinder.estimator(strcmp('lsq_fitquadric',{cfg.db.spotfinder.estimator.type})).params = struct('nbr',1);

%eof