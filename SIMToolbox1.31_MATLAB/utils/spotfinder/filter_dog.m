function [imb, params] = filter_dog(imraw, params)
% 2D band-pass filter based on Difference-of-Gaussians filter
%
%   [imb, params] = filter_dog(imraw, params)
%
% Input/output arguments:
%
%   imraw             ... [m x n]  input image
%   imb               ... [m x n]  filtered image
%   params.sigma1     ... [scalar] sigma of the gaussian kernel (default 1)
%   params.sigma2     ... [scalar] sigma of the gaussian kernel (default 2)
%   params.size       ... [scalar] size of the filter (default auto)
%
% See also fspecialseparable, imfilterseparable, filter_dogint

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
if nargin < 2 || ~isfield(params,'sigma1')
  params.sigma1 = 1;
end

if nargin < 2 || ~isfield(params,'sigma2')
  params.sigma2 = 2;
end

if nargin < 2 || ~isfield(params,'size')
  params.size = 2*ceil(3*params.sigma2)+1;
end

% return function info
if nargin < 1
  imb.mfile = fileparts_name([mfilename('fullpath') '.m']);
  imb.type = 'dog';
  imb.name = 'Difference of Gaussians';
  imb.params = params;
  return;
end

assert(isscalar(params.sigma1) && params.sigma1 > 0, 'filter:params', 'DOG: Wrong sigma1 size.');
assert(isscalar(params.sigma2) && params.sigma2 > 0, 'filter:params', 'DOG: Wrong sigma2 size.');
assert(params.sigma2 > params.sigma1, 'filter:params','DOG: sigma2 must be greater than sigma1.');
assert(isscalar(params.size) && params.size > 0 && params.size == fix(params.size), 'filter:params', 'DOG: Wrong filter size.');

% difference of two separable convolution filters with gaussian kernel
h1 = fspecialseparable('gauss', params.size, params.sigma1);
h2 = fspecialseparable('gauss', params.size, params.sigma2);
imb = imfilterseparable(imraw, h1, 'replicate') - imfilterseparable(imraw, h2, 'replicate');

%eof