function cfg = calconfig()
% Configuration of the calibration process
%
% See also calprocess

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

cfg.resdir = '$data$\';
cfg.imFFwhite = '$file$_FFwhite.tif';
cfg.imFFblack = '$file$_FFblack.tif';

cfg.display = struct('name', 'SXGA-3DM (4DD)', 'size', struct('x', 1280, 'y', 1024), 'pixel', struct('pitch', 13.62, 'gap', 0.54));

% default settings
cfg.ptrnrepz = '';
cfg.ptrnro = 1; % running order
    
% show images when processing
cfg.plotdet = 1;
cfg.plotdisptilt = 1;
cfg.plotmatch = 1;
cfg.plotmap = 1;

% markers
cfg.detmarksigmablure = 2;  % blure image before marker detection
cfg.detmarkborder = 100;    % size of image border, where markers are not detected

% corners
cfg.detcornsigmablure = 2;  % blure image before corner detection
cfg.detcornthr = 0.3;       % CORNER THRESHOLD
cfg.detsubpixnbr = 1;       % neighbourhood size for estimation of subpixel position of corners
cfg.detcorndst = 0.8;       % remove corners closer than 0.8 of an aproximate distance between corners
