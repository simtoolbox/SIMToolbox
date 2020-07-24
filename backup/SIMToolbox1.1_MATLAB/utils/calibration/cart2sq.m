function [th,rsq] = cart2sq(x,y)
% Map cartesian coordinates to sqarish coordinates with respect to [0,0]
%
%   [th,rsq] = cart2sq(x,y)
%
% Input/output arguments:
%
%   x,y  ...  [npts x 1]   x,y cartesian coordinates of points
%   rsq  ...  [npts x 1]   squarish radius of points
%   th   ...  [npts x 1]   angle of points

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

rsq = max(abs(x), abs(y));
th = atan2(y,x);
