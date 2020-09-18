function [gdf, ptrncal] = calloadgdf(filename, varargin)
% Load gauge definition from a repertoire with calibration sequence
%
%   [gdf, ptrncal] = calloadgdf(filename, 'PropertyName', PropertyValue, ...)
%
% Input/output arguments:
%
%   filename           ... [string]  calibration repertoire file name
%   gdf                ... [struct]  gauge definition (type, origin, definition points, image)
%   ptrncal            ... [struct]  pattern information (same as for ptrnopen)
%
%   Property Names
%      'runningorder'  ... [scalar]  running order of the GDF pattern (default 1)
%      'number'        ... [scalar]  position of the GDF pattern in the sequence (default 1)
%
% Example:
%
%   gdf = calloadgdf('patterns\calibr\calibr_box16_seq3.repz');
%   figure(1); clf; hold on;
%   imagesc(gdf.Image); colormap gray; axis image off;
%   plot(gdf.Data(:,1), gdf.Data(:,2), 'bx');
%   plot(gdf.Origin(:,1), gdf.Origin(:,2), 'ro');
% 
% See also calload, cali2w, calw2i, ptrnopen, ptrnload, ptrnclose

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

% extract input variables
[runningorder, number] = chkinput(varargin{:});

% open pattern repertoire
ptrncal = ptrnopen(filename);

% test GDF sequence
cal = ptrncal.runningorder(runningorder+1).data{number};
assert(isfield(cal,'id') && strcmp(cal.id,'calibr') && isfield(cal,'gdf'), 'calloadgdf:notgdf', 'Gauge definition not present.');

% get gdf coordinates
gdf = cal.gdf;

% load gdf image
gdf.Image = imread([ptrncal.datadir filesep cal.images{1}]);

% close repertoire
if nargout < 2
  ptrnclose(ptrncal);
end

% ----------------------------------------------------------------------------

function [runningorder, number] = chkinput(varargin)

% default options
runningorder = 1; number = 1;

% run through input arguments
for I = 1:2:length(varargin) 
  assert(ischar(varargin{I}) && any(strcmp(varargin{I},{'runningorder','number'})), 'calloadgdf:chkinput', 'Wrong property name.');
  eval([lower(varargin{I}) '=varargin{I+1};']);
end

%eof
