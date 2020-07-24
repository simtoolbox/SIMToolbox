function [A, params] = apodize_triangle(siz, params)
% 2D triangle function apodizing filter (Bartlett window)
%
%   [A, params] = apodize_triangle(siz, params)
%
% Input/output arguments:
%
%   siz                 ... [m,n]     filter size
%   params.rad          ... [scalar]  radius of the filter (default 0.25)
%   params.pow          ... [scalar]  power (default 1)
%   params.offset       ... [u,v]     offset of the filter with respect to center (default [0,0])
%   params.resolution   ... [scalar]  pixel size (default NaN), converts radius to spatial frequency
%   A                   ... [m x n]   filter profile
%
% Filter definition:
%
%   A = 1 - r/params.rad   for radius <= params.rad
%   A = 0                  otherwise
%
% Example:
%
%   A = apodize_triangle([255 255], struct('rad',0.5));
%   figure; imagesc(-1:1, -1:1, A); axis image;

% Copyright � 2009-2015 Pavel Krizek
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

% default values
if nargin < 2 || ~isfield(params,'resolution')
  params.resolution = NaN;
end

if nargin < 2 || ~isfield(params,'rad')
  params.rad = 0.25;
end

if nargin < 2 || ~isfield(params,'pow')
  params.pow = 1;
end


if nargin < 2 || ~isfield(params,'offset')
  params.offset = [0 0];
end

% return function info
if nargin < 1
  A.mfile = fileparts_name([mfilename('fullpath') '.m']);
  A.type = 'triangle';
  A.name = 'Triangle';
  A.params = params;
  return;
end

assert(numel(siz) == 2 && any(siz > 0), 'apodize:siz', 'Wrong filter size.');

% convert rad -> frequency
if isnan(params.resolution)
  rad = params.rad;
else
  rad = 2*params.resolution/params.rad;
end

% create a rotationaly symmetric mesh grid with radius normalized to filter size
cnt = ceil((siz+1)/2) + params.offset;
[x,y] = meshgrid(1:siz(2), 1:siz(1));
r = hypot((x-cnt(2))*2/siz(2), (y-cnt(1))*2/siz(1));

% triangle function
A = (1 - r/rad).^params.pow .* (r <= rad);

%eof