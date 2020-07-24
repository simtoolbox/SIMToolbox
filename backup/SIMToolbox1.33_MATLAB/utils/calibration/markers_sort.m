function markers = markers_sort(markers)
% Sort markers such that their ordering is as follows
%
%         x o x      H C G
%         x x o  ->  I E A 
%         o x o      D F B
%
%   markers = markers_sort(markers)
%
% Input/output arguments:
%
%   markers  ...  [npts x 2]  [X,Y] coordinates of markers
%
% See also markers_detect

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

% get point to point distances
dst = zeros(4,4);
for I = 1:4
  dst(:,I) = ptdist(markers(I,:), markers(1:4,:));
end

% find a key point A
[foo,idx] = min(sum(dst,1));

% order points accorcing to the distance to A
[foo,idx] = sort(dst(:,idx)); 
markers = markers(idx,:);

% add some more points
markers(6,:) = mean(markers([2 4],:),1);                       % F: (B+D)/2
markers(5,:) = mean(markers([3 6],:),1);                       % E: (C+F)/2
markers(7,:) = markers(5,:) - (markers(4,:) - markers(5,:));   % G: E - (D-E)
markers(8,:) = markers(5,:) - (markers(2,:) - markers(5,:));   % H: E - (B-E)
markers(9,:) = mean(markers([4 8],:),1);                       % I: (D+H)/2

%eof