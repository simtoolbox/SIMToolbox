function IM = ptrn2camera(imginfo, ptrninfo, calinfo, method)
% Map illumination pattern from a microdisplay to a camera
%
% 1) Create a lookup table
%
%    ptrn2camera(imginfo, ptrninfo, calinfo)
%    ptrn2camera(imginfo, ptrninfo, calinfo, method)
%
%       imginfo  ... [struct]  image information created by imginfoinit
%       ptrninfo ... [struct]  pattern information created by ptrnopen
%       calinfo  ... [struct]  calibration information created by calload
%       method   ... [string]  interpolation method (default '*linear')
%
% 2) Map illuminaiton pattern to camera
%
%    IMcamera = ptrn2camera(IMdisplay)
%
%       IMdisplay ... [m x n]  pattern image on a microdisplay
%       IMcamera  ... [p x q]  corresponding image in a camera
%
% Example:
%      
%    imginfo = imginfoinit('data/polen/pollen 100X 1.45NA');
%    ptrninfo = ptrnopen(ptrndirinfo('data/polen/pollen 100X 1.45NA'));
%    calinfo = calload('data\polen\calibration\calibration_LIN.yaml');
%    ptrn2camera(imginfo, ptrninfo, calinfo);
%    imgptrn = ptrnload(ptrninfo, 'runningorder', 1, 'number', 5);
%    imgcam = ptrn2camera(imgptrn);
%    imagesc(imgcam); colormap gray; axis image off;
%    ptrnclose(ptrninfo);
%
% See also ptrnopen, ptrnload, ptrnclose, imginfoinit, calload

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

persistent LUT;

if nargin > 1 && isstruct(imginfo)

  % default interpolation method
  if (nargin < 4 || isempty(method))
    method = '*linear';
  end
  
  LUT.method = method;
  
  % camera coordinates = pixels where to transform
  [X,Y] = meshgrid(1:imginfo.image.size.x, 1:imginfo.image.size.y);
  
  % camera coordinates transformed into display coordinates
  wpts = cali2w([X(:),Y(:)], calinfo.cal.map, imginfo.camera.roi);
  LUT.xi = reshape(wpts(:,1), [imginfo.image.size.y, imginfo.image.size.x]);
  LUT.yi = reshape(wpts(:,2), [imginfo.image.size.y, imginfo.image.size.x]);
  
  % display coordinates
  [LUT.X, LUT.Y] = meshgrid(1:ptrninfo.imagesize.x, 1:ptrninfo.imagesize.y);
  
  IM = [];
  
else

  assert(~isempty(LUT), 'ptrn2camera:LUTerror', 'Create LUT first.');
  
  % transform display image into camera image
  IM = interp2(LUT.X, LUT.Y, imginfo, LUT.xi, LUT.yi, LUT.method, 0);
  
end

%eof