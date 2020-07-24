function [corners, imc] = corners_detect(im, sigma, thr, subpix2d, subpixnbr)
% Detect corners on a chessboeard image
%
%   [corners, imc] = corners_detect(im, sigma, thr, subpix2d, subpixnbr)
%
% Input arguments:
%
%   im        ... [m x n]    input image
%   sigma     ... [scalar]   bluring with gaussian kernel with a given sigma
%   thr       ... [scalar]   treshold for corner detection
%   subpixnbr ... [scalar]   neighbourhood size for computation of subpixel coordinates
%   subpix2d  ... [handle]   handle to a function which computes subpixel coordinates
%                            [rsub, csub, valsub] = @subpix2d(r, c, imc, subpixnbr)
%                            r/rsub and c/csub are row and column coordinates
%
% Output arguments:
%
%   corners   ... [npts x 3] [X,Y,VAL] coordinates of corners and with filter response
%   imc       ... [m x n]    image with filter response
%
% See also subpix2d_fitquadric, subpix2d_gradintersect

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

% suppress noise by bluring the image
hfil = fspecialseparable('gauss', 2*fix(3*sigma)+1, sigma);
imb = imfilterseparable(im, hfil, 'replicate');

% responce of the corner detector
hfil = [1 0 -1; 0 0 0; -1 0 1];
imc1 = imfilter(imb, hfil, 'replicate');
imc2 = imfilter(imb, -hfil, 'replicate');
imc = imc1.^2 + imc2.^2;

% quit - don't detect position of corners
if nargin < 3
  corners = [];
  return;
end;

% find position of corners as local intensity maxima
[m,n] = size(im);
idx = findlocmax2d(imc, thr, 8);
[r,c] = ind2sub([m,n], double(idx));

if nargin < 4
  % no subpixel computation
  corners = sortrows([c, r, imb(idx)], -3);
else
  % remove points that are too close to the border
  idx = r <= subpixnbr | c <= subpixnbr | r > m-subpixnbr | c > n-subpixnbr;
  r(idx) = []; c(idx) = [];
  try
    % compute local maxima to subpixel accuracy
    [rsub, csub, valsub] = subpix2d(r, c, imc, subpixnbr);
    % sort corners according to the highest filter response
    corners = sortrows([csub, rsub, valsub], -3);
  catch
    corners = [];
  end
end

% figure(2);clf;
% imagesc(im)
% colormap gray;
% axis image off;
% set(gca,'Position',[0 0 1 1]);
% hold on
% if ~isempty(corners), plot(corners(:,2),corners(:,1),'rx'); end;

%eof