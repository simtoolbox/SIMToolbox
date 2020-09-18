function A = imgrmpadding(A, padsize)
% Remove image padding of a specified size
%
%   A = imgrmpadding(A, padsize)
%
% Input/output arguments:
%
%   A        ... [m x n]  image
%   padsize  ... [scalar] size of padding
%
% See also padarray, seqpadsmooth

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

sizold = size(A);
siznew = sizold - 2*padsize;
A = A(padsize+(1:siznew(1)), padsize+(1:siznew(2)));
