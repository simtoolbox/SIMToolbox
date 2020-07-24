function wpts = cali2w(ipts, map, roi)
% Map image coordinates to world coordinates
%
%   wpts = cali2w(ipts, map)
%   wpts = cali2w(ipts, map, roi)
%
% Input/output arguments:
%
%    ipts ... [n x 2]    [X,Y] image coordinates
%    map  ... [struct]   projection matrix (fields Hw2i, Hi2w), optional radial correction (fileds: Rw2i, Ri2w)
%    roi  ... [struct]   camera ROI defined by struct('xlim',[xmin,xmax],'ylim',[ymin,ymax]) (default xmin=1, ymin=1)
%    wpts ... [n x 2]    [X,Y] world coordinates
%
% See also calw2i, calload, calhomolin, calhomorad, calloadgdf

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

% default ROI
if nargin < 3
  roi.xlim = 1;
  roi.ylim = 1;
end

% shift coordinates according to ROI of a camera
ipts(:,1) = ipts(:,1) + roi.xlim(1) - 1;
ipts(:,2) = ipts(:,2) + roi.ylim(1) - 1;

% radial correction of image points
if isfield(map,'Ri2w')

  radcpt = map.Ri2w(1:2);         % center point
  radcoef = map.Ri2w(3:end);      % coeficients
  npts = size(ipts,1);

  iptscnt = [ipts(:,1) - radcpt(1), ipts(:,2) - radcpt(2)];
  r2 =  sum(iptscnt.^2,2);
  
  % 2k Taylor series: cc = 1 + radcoef[0]*r2 + radcoef[1]*r2*r2 + radcoef[2]*r2*r2*r2 + ...
  cc = ones(npts,1); rn = r2;
  for I = 1:length(radcoef)
    cc = cc + radcoef(I)*rn;
    rn = rn.*r2;
  end;

  % point after radial transformation
  ipts = [radcpt(1) + cc .* iptscnt(:,1), radcpt(2) + cc .* iptscnt(:,2)];

end

% create homogenous coordinates
ipts(:,3) = 1;
 
% use homography
wpts = ipts * map.Hi2w';

% return world point
wpts = [wpts(:,1)./wpts(:,3), wpts(:,2)./wpts(:,3)];

%eof