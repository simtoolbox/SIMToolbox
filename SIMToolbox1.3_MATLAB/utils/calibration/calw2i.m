function ipts = calw2i(wpts, map, roi)
% Map world coordinates to image coordinates
%
%   ipts = calw2i(wpts, map)
%   ipts = calw2i(wpts, map, roi)
%
% Input/output arguments:
%
%    wpts ... [n x 2]    [X,Y] world coordinates
%    map  ... [struct]   projection matrix (fields Hw2i, Hi2w), optional radial correction (fileds: Rw2i, Ri2w)
%    roi  ... [struct]   camera ROI defined by struct('xlim',[xmin,xmax],'ylim',[ymin,ymax]) (default xmin=1, ymin=1)
%    ipts ... [n x 2]    [X,Y] image coordinates
%
% See also cali2w, calload, calhomolin, calhomorad, calloadgdf

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

% create homogenous coordinates
wpts(:,3) = 1;

% use homography
ipts = wpts * map.Hw2i';

% return image point
ipts = [ipts(:,1)./ipts(:,3), ipts(:,2)./ipts(:,3)];

% radial correction of image points
if isfield(map,'Rw2i')
  
  radcpt = map.Rw2i(1:2);         % center point
  radcoef = map.Rw2i(3:end);      % coeficients
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

% shift coordinates according to ROI of a camera
ipts(:,1) = ipts(:,1) - roi.xlim(1) + 1;
ipts(:,2) = ipts(:,2) - roi.ylim(1) + 1;

%eof