function h = fspecialseparable(type, varargin)
% Generate kernels for separable convolution
%
%   h = fspecialseparable(type, parameters)
%
% Kernel types:
%
%   Gaussian kernel
%     h = fspecialseparable('gauss', hsize, sigma)
%
%   Integrated Gaussian kernel
%     h = fspecialseparable('gausserf', hsize, sigma)
%
%   Averaging kernel
%     h = fspecialseparable('average', hsize)
%
% Input/output arguments:
%
%   hsize  ... [scalar]  size of the kernel
%   sigma  ... [scalar]  sigma for Gaussian kernels
%   h      ... [1 x siz]  kernel vector
%
% Example:
%
%   h1 = fspecialseparable('gauss', 10, 1)
%   h2 = fspecialseparable('average', 5)
%
% See also imfilterseparable, fspecial, imfilter

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

switch type
  case 'gauss'
    siz = (varargin{1}-1)/2;
    sigma = varargin{2};
    x = -siz:siz;
    h = exp(-(x.*x)/(2*sigma*sigma));
    h(h<eps*max(h(:))) = 0;
    sumh = sum(h(:));
    if sumh ~= 0,
      h  = h/sumh;
    end
  case 'gausserf'
    siz = (varargin{1}-1)/2;
    sigma = varargin{2};
    nrm = sqrt(2)*sigma;
    x = -siz:siz;
    h = erf((x+0.5)/nrm)-erf((x-0.5)/nrm);
    h(h<eps*max(h(:))) = 0;
    sumh = sum(h(:));
    if sumh ~= 0,
      h  = h/sumh;
    end
  case 'average'
    siz = varargin{1};
    h   = ones(1,siz)/siz;
  otherwise
    error('fspecialseparable:unknownfilter','Unknown filter type.');
end

%eof