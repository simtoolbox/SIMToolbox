function b = imfilterseparable(a, h, pad_boundary)
% Image filtering using separable convolution.
% This algorithm is about 2x faster than imfilter.
% 
%   B = imfilterseparable(A, H)
%   B = imfilterseparable(A, H, pad_boundary)
% 
% Input/output arguments:
%
%   A              ... [m x n]  input image
%   H              ... [1 x q]  kernel for separable convolution
%   pad_boundary   ... [string] 'none' (default) / 'replicate' / 'circular' / 'symmetric'
%   B              ... [m x n]  output image
%
% See also fspecialseparable, fspecial, imfilter, padarray

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

if nargin < 3
  pad_boundary = 'none';
end

assert(isvector(h) && isnumeric(h),'imfilterseparable:notvector','Kernel for separable convolution must be a vector.');

if strcmp(pad_boundary,'none')
  % separable convolution with no padding (boundary is 0)
  b = conv2(h,h,a,'same');
else
  % pad image and perform separable convolution
  padsize = fix(numel(h)/2);
  b = conv2(h, h, padarray(a,[padsize padsize],pad_boundary,'both'),'valid');
  % remove remaining padding for even mask size
  if mod(numel(h),2) == 0    
    b = b(2:end,2:end);
  end
end

%eof