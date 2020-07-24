function [imb, params] = filter_gauss(imraw, params)
% 2D low-pass Gaussian filter
%
%   [imb, params] = filter_gauss(imraw, params)
%
% Input/output arguments:
%
%   imraw             ... [m x n]  input image
%   imb               ... [m x n]  filtered image
%   params.sigma      ... [scalar] sigma of the gaussian kernel (default 1)
%   params.size       ... [scalar] size of the filter (default auto)
%
% See also fspecialseparable, imfilterseparable, filter_gauss

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

% default parameters
if  nargin < 2 || ~isfield(params,'sigma')
  params.sigma = 1;
end

if  nargin < 2 || ~isfield(params,'size')
  params.size = 2*ceil(3*params.sigma)+1;
end

% return function info
if nargin < 1
  imb.mfile = fileparts_name([mfilename('fullpath') '.m']);
  imb.type = 'gauss';
  imb.name = 'Gaussian';
  imb.params = params;
  return;
end

assert(isscalar(params.sigma) && params.sigma > 0, 'filter:params', 'GAUSS: Wrong sigma size.');
assert(isscalar(params.size) && params.size > 0 && params.size == fix(params.size), 'filter:params', 'GAUSS: Wrong filter size.');

% separable convolution with gaussian kernel
h = fspecialseparable('gauss', params.size, params.sigma);
imb = imfilterseparable(imraw, h, 'replicate');

%eof