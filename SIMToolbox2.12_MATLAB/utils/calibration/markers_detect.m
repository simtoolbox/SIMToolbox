function markers = markers_detect(im, sigma, bordersiz, thr)
% Detect circular markers on a chessboard
%
%   markers = markers_detect(im, sigma, bordersiz, thr)
%
% Input/output arguments:
%
%   im        ... [m x n]    input image
%   sigma     ... [scalar]   sigma of the gaussian bluring kernel (default 2)
%   bordersiz ... [scalar]   border to exclude image boundary (default 0)
%   thr       ... [scalar]   treshold for corner detection (default 0.5)
%   markers   ... [npts x 2] [X,Y] coordinates of markers
%
% See also markers_sort, markers_check

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

if nargin < 2, sigma = 2; end;
if nargin < 3, bordersiz = 0; end;
if nargin < 4, thr = 0.5; end;

% blure image
hfil = fspecialseparable('gauss', 2*fix(3*sigma)+1, sigma);
imb = imfilterseparable(im, hfil, 'replicate');

% squares with markers have lower intensity than other squares
imb = abs(imb-mean(imb(:)));

% create a mask - squares with markers stay black
mask = imb > mean(imb(:));

% exclude chessboard edges (doesn't work when chessboard is rotated too much)
% this for the old marker style: split two markers next to each other
imsiz = size(im);
row = sum(mask,1) < 0.2*imsiz(1);
col = sum(mask,2)' < 0.2*imsiz(2);
mask(:,row) = true;
mask(col,:) = true;

% exclude image boundary
bordermask = true(imsiz);
bordermask(bordersiz+1:imsiz(1)-bordersiz, bordersiz+1:imsiz(2)-bordersiz) = false;
mask(bordermask) = true;

% find markers using distance transform
imd = imfilterseparable(double(bwdist(mask)), hfil, 'replicate');
idx = findlocmax2d(imd, thr*max(imd(:)), 8);
[r,c] = ind2sub(imsiz,double(idx));

% remove points that are too close to each other
if ~isempty(idx)
  markers = sortrows([c r imd(idx)], -3);
  valid = circfilter(markers(:,1:2), 2);
  markers = markers(valid,1:2);
  markers = markers(1:min(4,sum(valid)),:);
else
  markers = [];
end

% figure;
% imagesc(imd);
% colormap gray;
% axis image off;
% hold on
% plot(markers(:,1),markers(:,2),'rx');

%eof