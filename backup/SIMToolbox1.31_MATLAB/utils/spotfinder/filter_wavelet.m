function [levels, params] = filter_wavelet(imraw, params)
% 2D band-pass filter based on wavelets
%
%   [levels, params] = filter_wavelet(imraw, params)
%
% Input/output arguments:
%
%   imraw             ... [m x n]  input image
%   levels            ... [m x n x level]  wavelet levels
%   params.order      ... [scalar] B-spline order (default 3)
%   params.scaling    ... [scalar] scaling factor (default 2)
%   params.size       ... [scalar] size of the filter (default auto)
%   params.samples    ... [scalar] number of samples (default auto)
%   params.numlevels  ... [scalar] mumber of wavelet levels (default 2)
%
% The kernel generated with the defualt parameters is the same as in
% Wavelet Analysis for SMLM [Izeddin-OE-2012], i.e., g = [1 4 6 4 1]/16.
% Estimation of the background Gaussian noise can be performed from the
% 1st wavelet level. Threshold for the 2nd wavelet level ranges between
% 0.5 to 2 times the standard deviation of the 1st wavelet level. 

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
if nargin < 2 || ~isfield(params,'order')
  params.order = 3;
end

if nargin < 2 || ~isfield(params,'scaling')
  params.scaling = 2;
end

if nargin < 2 || ~isfield(params,'size')
  params.size = 2*ceil(params.order*params.scaling/2)-1;
end

if nargin < 2 || ~isfield(params,'samples')
  params.samples = -(params.size-1)/2:(params.size-1)/2;
end

if nargin < 2 || ~isfield(params,'level')
  params.numlevels = 2;
end

% return function info
if nargin < 1
  levels.mfile = fileparts_name([mfilename('fullpath') '.m']);
  levels.type = 'wavelet';
  levels.name = 'Wavelet';
  levels.params = params;
  return;
end

assert(isscalar(params.order) && params.order > 0, 'filter:params', 'WAVELET: Wrong B-spline order.');
assert(isscalar(params.scaling) && params.scaling > 0, 'filter:params', 'WAVELET: Wrong scaling factor.');
assert(isscalar(params.size) && params.size > 0, 'filter:params', 'WAVELET: Wrong filter size.');
assert(isscalar(params.numlevels) && params.numlevels > 0, 'filter:params', 'WAVELET: Wrong number of wavelet levels.');

% 1st level
g = bspline_blender(params.order,params.scaling,params.samples);
padsize = repmat(fix(numel(g)/2),1,2);
V = conv2(g, g, padarray(imraw,padsize,'replicate'), 'valid');
levels = (imraw - V);

% 2nd to nth level
V(:,:,2:params.numlevels) = 0;  levels(:,:,2:params.numlevels) = 0; 
for I = 2:params.numlevels
  g(2,:) = 0; g = g(1:numel(g)-1); % add zero between each number
  padsize = repmat(fix(numel(g)/2),1,2);
  V(:,:,I) = conv2(g, g, padarray(V(:,:,I-1),padsize,'replicate'), 'valid');
  levels(:,:,I) = (V(:,:,I-1) - V(:,:,I));
end

function y = bspline_blender(k,s,t)
% k...order
% t...samples
% s...scale

y = N(k, (t / s) + (k / 2));
y = y/sum(y);

function b = N(k,t)
% k...order
% t...samples

if k <= 1
    b = double(t >= 0 & t < 1);
else
    b = t ./ (k - 1) .* N(k-1,t) + (k - t) ./ (k - 1) .* N(k-1,t-1);
end

%eof