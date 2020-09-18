function [prof,radius] = imgradprof(im,cnt,rstep,astep)
% Compute average radial profile of an image
%
%   [prof,radius] = imgradprof(im, cnt, rstep, astep)
%
% Input/output arguments:
%
%   im        ... [m x n]   image
%   cnt       ... [1 x 2]   center of the profile (default is center of the image)
%   rstep     ... [scalar]  radius step (default 0.25 pixel)
%   astep     ... [scalar]  angle step (default 0.5 degree)
%   prof      ... [1 x numr]  averaged radial profile
%   radius    ... [1 x numr]  radius coordinate of the profile

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

siz = size(im);

if nargin < 2 || isempty(cnt)
  cnt = ceil((siz+1)/2);
end

if nargin < 3
  rstep = 0.25;
end

if nargin < 4
  astep = 0.5;
end

center = ceil((siz+1)/2);
R = min(center - abs(center - cnt)) - 1;
alfa = (0:astep:360)*pi/180; alfa(end) = [];
radius = 0:rstep:R;

[x,y] = meshgrid(1:siz(2),1:siz(1));
[r,th] = meshgrid(radius,alfa);
[xi,yi] = pol2cart(th,r);

prof = mean(interp2(x,y,im,xi+cnt(2),yi+cnt(1),'linear',0),1);

%eof