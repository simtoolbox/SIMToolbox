function map = calhomolin(wpts,ipts)
% Compute linear homography between world and image coordinates
% such that:
%             ipts = wpts * map.Hw2i'
%             wpts = ipts * map.Hi2w'
%
%   map = calhomolin(wpts, ipts)
%
% Input/output arguments:
%
%   wpts ... [npts x 2]  [X,Y] world coordinates
%   ipts ... [npts x 2]  [X,Y] image coordinates
%   map  ... [struct]  projection matrix
%
% See also cali2w, calw2i, calhomorad, calload

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

numpts = size(wpts,1);

assert(numpts == size(ipts,1), 'calhomolin:numpts', 'Number of points does not match.');
assert(numpts > 3, 'calhomolin:numpts:', 'Not enough points.');

% create homogenous coordinates
wpts(:,3) = 1; % [x y 1]
ipts(:,3) = 1; % [u v 1]

% normalize point coordinates to ensure better numerical stability
wmu = mean(wpts(:,1:2),1); wstd = std(wpts(:,1:2),0,1);
imu = mean(ipts(:,1:2),1); istd = std(ipts(:,1:2),0,1);
Nw = [1/wstd(1), 0, -wmu(1)/wstd(1); 0, 1/wstd(2), -wmu(2)/wstd(2); 0, 0, 1];
Ni = [1/istd(1), 0, -imu(1)/istd(1); 0, 1/istd(2), -imu(2)/istd(2); 0, 0, 1];
wpts = wpts * Nw';
ipts = ipts * Ni';

% fill matrix (full matrix representation)
% A = [ x y 1 0 0 0 -ux -uy -u ; ...
%       0 0 0 x y 1 -vx -vy -v ];
% A = [wpts, zeros(numpts,3), repmat(-ipts(:,1),1,3).*wpts; ...
%      zeros(numpts,3), wpts, repmat(-ipts(:,2),1,3).*wpts];
%
% compute homography
% [U,D,V] = svd(A); % use single instead of double if SVD has problem with memmory
% Hw2i = reshape(double(V(:,9)),3,3)';

% fill matrix (no shearing - better stability of the solution)
% A = [ x y 1 0 0 0 -u ; ...
%       0 0 0 x y 1 -v ];
A = [wpts, zeros(numpts,3), -ipts(:,1); ...
     zeros(numpts,3), wpts, -ipts(:,2)];

% compute homography
[U,D,V] = svd(A);

Hw2i = reshape(V(1:6,7),3,2)'; Hw2i(3,3) = V(7,7);
map.Hw2i = inv(Ni) * (Hw2i / Hw2i(9)) * Nw;

Hi2w = inv(map.Hw2i);
map.Hi2w = Hi2w / Hi2w(9);

% eof