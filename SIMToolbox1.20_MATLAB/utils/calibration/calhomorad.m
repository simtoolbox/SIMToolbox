function map = calhomorad(wpts,ipts)
% Compute mapping with radial correction between world and image coordinates
%
%   map = calhomorad(wpts, ipts)
%
% Input/output arguments:
%
%   wpts ... [npts x 2]  [X,Y] world coordinates
%   ipts ... [npts x 2]  [X,Y] image coordinates
%   map  ... [struct]  projection matrix and coefficients for radial correction
%
% See also cali2w, calw2i, calhomolin, calload

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

[Hi2w,Hw2i,Ri2w,Rw2i] = cal2Destim(ipts,wpts);

map.Hw2i = Hw2i' / Hw2i(9);
map.Hi2w = Hi2w' / Hi2w(9);
map.Rw2i = Rw2i;
map.Ri2w = Ri2w;
