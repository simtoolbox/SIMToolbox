function [imb, params] = filter_diffav(imraw, params)
% 2D band-pass filter based on Difference-of-Averaging filter 
%
%   [imb, params] = filter_diffav(imraw, params)
%
% Input/output arguments:
%
%   imraw             ... [m x n]  input image
%   imb               ... [m x n]  filtered image
%   params.size1      ... [scalar] size1 of the filter (default 3)
%   params.size2      ... [scalar] size2 of the filter (default 5)
%
% See also fspecialseparable, imfilterseparable

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

% This filter was used in [Hunag&Lidke-BioOpticsExpress-2011]

% default parameters
if nargin < 2 || ~isfield(params,'size1')
  params.size1 = 3;
end

if nargin < 2 || ~isfield(params,'size2')
  params.size2 = 5;
end

% return function info
if nargin < 1
  imb.mfile = fileparts_name([mfilename('fullpath') '.m']);
  imb.type = 'diffav';
  imb.name = 'Difference of Average (Box)';
  imb.params = params;
  return;
end

assert(isscalar(params.size) && params.size > 0 && params.size == fix(params.size), 'filter:params', 'DIFFAV: Wrong filter size1.');
assert(isscalar(params.size) && params.size > 0 && params.size == fix(params.size), 'filter:params', 'DIFFAV: Wrong filter size2.');
assert(params.size2 > params.size1, 'filter:params', 'DIFFAV: Filter size2 must be greater than size1.');

% difference of two separable convolution filters with box kernel
h1 = fspecialseparable('average', params.size1);
h2 = fspecialseparable('average', params.size2);
imb = imfilterseparable(imraw, h1, 'replicate') - imfilterseparable(imraw, h2, 'replicate');

%eof