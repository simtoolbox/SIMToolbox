function calinfo = calload(filename)
% Load calibration file from YAML file
%
%   calinfo = calload(filename)
%
% Input/output arguments:
%
%   filename    ... [string]  file name
%   calinfo     ... [struct]  calibration data
%
% Example:
%      
%   calinfo = calload('data/polen/calibration/calibration_LIN.yaml');
%   gdf = calloadgdf([calinfo.dir filesep calinfo.setup.ptrn.repz]);
%   ipts = calw2i(gdf.Data, calinfo.cal.map);
%   plot(ipts(:,1),ipts(:,2),'bx')
%   title('Chessboard corners mapped from microdisplay to camera image');
%
% See also calw2i, cali2w, calloadgdf, calhomolin, calhomorad, calsave

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

% test if file exists
assert(isfilest(filename), 'calload:filenotfound', 'Calibration file not found.');

% pase file parts
datadir = fileparts_dir(filename);

try
  % load calibration
  calinfo = YAML.read(filename);
  calinfo.dir = datadir;
  % test file
  assert(strcmp(calinfo.id, 'SIM_calibration'));
catch err
  error('calload:fileerror', 'Not a valid calibration file.');
end

try
    calinfo.setup.display = calinfo.display;
    calinfo.setup.camera = calinfo.camera;
    calinfo.setup.cfg = calinfo.cfg;
    
    calinfo = rmfield(calinfo,{'display','camera','cfg'});
catch
    
end

% load flat field images
try
  calinfo.cal.imFFwhite = imread([datadir filesep calinfo.setup.cfg.imFFwhite]);
  calinfo.cal.imFFblack = imread([datadir filesep calinfo.setup.cfg.imFFblack]);
catch err
  calinfo.cal.imFFwhite = [];
  calinfo.cal.imFFblack = [];
  % fprintf('Warning: Missing data for flat field correction.\n');
end

%eof