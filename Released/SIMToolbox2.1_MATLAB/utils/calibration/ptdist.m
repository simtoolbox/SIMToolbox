function dst = ptdist(pt, pts)
% Determine Euclidean distance between points
%
%   dst = ptdist(pt, pts)
%
% Input/output arguments:
%
%   pt    ...  [1 x 2]     [X,Y] point coordinates
%   pts   ...  [npts x 2]  [X,Y] coordinates of points
%   dst   ...  distances from the point (pt) to other points (pts)
%
% Example:
%
%   dst = ptdist([0 0], rand(5,2));

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

dst = sqrt((pt(1)-pts(:,1)).^2 + (pt(2)-pts(:,2)).^2);