function [imb, params] = filter_dao(imraw, params)
% 2D band-pass filter based on shifted Gaussian filter
%
%   [imb, params] = filter_dao(imraw, params)
%
% Input/output arguments:
%
%   imraw             ... [m x n]  input image
%   imb               ... [m x n]  filtered image
%   params.sigma      ... [scalar] sigma of the gaussian kernel (default 1)
%   params.size       ... [scalar] size of the filter (default auto)
%
% See also fspecialseparable, imfilterseparable, filter_daoint

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

% This filter was used in DAOPHOT [Stenson-1987] and in DAOSTORM [Holden-NM-2011]

% default parameters
if nargin < 2 || ~isfield(params,'sigma')
  params.sigma = 1;            % default sigma
end

if nargin < 2 || ~isfield(params,'size')
  params.size = 2*ceil(3*params.sigma)+1;  % default filter size
end

% return function info
if nargin < 1
  imb.mfile = fileparts_name([mfilename('fullpath') '.m']);
  imb.type = 'dao';
  imb.name = 'Lowered Gaussian';
  imb.params = params;
  return;
end

assert(isscalar(params.sigma) && params.sigma > 0, 'filter:params', 'DAO: Wrong sigma size.');
assert(isscalar(params.size) && params.size > 0 && params.size == fix(params.size), 'filter:params', 'DAO: Wrong filter size.');

% difference of two separable convolution filters with gaussian and box kernel
h1 = fspecialseparable('gauss', params.size, params.sigma);
h2 = fspecialseparable('average', params.size);
imb = imfilterseparable(imraw, h1, 'replicate') - imfilterseparable(imraw, h2, 'replicate');

% h = fspecial('gauss', params.size, params.sigma);
% imb = imfilter(imraw, h - mean(h(:)), 'replicate', 'same'));

%eof