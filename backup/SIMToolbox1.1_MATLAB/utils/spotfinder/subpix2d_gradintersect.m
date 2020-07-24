function [rsub, csub, val] = subpix2d_gradintersect(r, c, im, nbr)
% Compute subpixel position of local maxima from intensity gradients
%
%   [rsub, csub, val] = subpix2d_gradintersect(r, c, im, nbr)
%
% Input/output arguments:
%
%    r,c         ... [npts x 1] row and column coordinates of approximate position 
%    im          ... [m x n]    image matrix
%    nbr         ... [scalar]   interpolate in a neighbourhood (default 4)
%    rsub, csub  ... [npts x 1] row and column coordinates with subpixel corrections
%    valsub      ... [npts x 1] interpolated value at subpixel positions
%
% See also spotfinder, subpix2d_gradintersect

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

  if (nargin < 4), nbr = 4; end; % bigger neighbourhood gives a better estimate

  assert(~isempty(r) && ~isempty(c), 'subpix2d:empty','No coordinates are given.');
  assert(numel(r) == numel(c), 'subpix2d:notconsistent','Coordinates are not consistent.');
  assert(nbr > 0, 'subpix2d:nbr','Neighbourhood size must be greater than zero.');
  
  r = round(r(:));
  c = round(c(:));
  npts = length(r);
    
  % grid coordinates are -n:n, where Nx (or Ny) = 2*n+1
  box = -nbr:nbr; Nx = length(box); Ny = Nx;
  % grid midpoint coordinates are -n+0.5:n-0.5;
  [xm,ym] = meshgrid(-(Nx-1)/2.0+0.5:(Nx-1)/2.0-0.5, -(Ny-1)/2.0+0.5:(Ny-1)/2.0-0.5);

  % compute subpixel corrections for all points
  rsub = zeros(npts,1);
  csub = zeros(npts,1);
  for Ipts = 1:npts
    [rsub(Ipts), csub(Ipts)] = radialcenter(im(r(Ipts)+box,c(Ipts)+box));
  end
  
  % add subpixel corrections
  rsub = r + rsub;
  csub = c + csub;
  
  % approximate local maxima value
  val = im(sub2ind(size(im), round(rsub), round(csub)));

  function [yc, xc] = radialcenter(I)
  % Method: Considers lines passing through each half-pixel point with slope
  % parallel to the gradient of the intensity at that point.  Considers the
  % distance of closest approach between these lines and the coordinate
  % origin, and determines (analytically) the origin that minimizes the
  % weighted sum of these distances-squared.
  %
  % Method taken from:
  % Raghuveer Parthasarathy. Rapid, accurate particle tracking by calculation
  % of radial symmetry centers. Nature Methods (2012)

  % Calculate derivatives along 45-degree shifted coordinates (u and v)
  dIdu = I(1:Ny-1,2:Nx)   - I(2:Ny,1:Nx-1);
  dIdv = I(1:Ny-1,1:Nx-1) - I(2:Ny,2:Nx);

  % Smoothing
  h = ones(3)/9;  % simple 3x3 averaging filter
  fdu = conv2(dIdu, h, 'same');
  fdv = conv2(dIdv, h, 'same');

  % Gradient magnitude, squared
  dImag2 = fdu.*fdu + fdv.*fdv; 

  % Slope of the gradient + make sure not to divide by 0
  fdu_fdv = fdu-fdv;
  fdu_fdv(abs(fdu_fdv) < 1E-9) = 1E-9;
  m = -(fdv + fdu) ./ fdu_fdv; 

  % y intercept of the line of slope m that goes through each grid midpoint
  b = ym - m.*xm;

  % weight by square of gradient magnitude and inverse distance to gradient intensity centroid.
  sdI2 = sum(dImag2(:));
  xcentroid = sum(sum(dImag2.*xm))/sdI2;
  ycentroid = sum(sum(dImag2.*ym))/sdI2;
  w  = dImag2./sqrt((xm-xcentroid).*(xm-xcentroid)+(ym-ycentroid).*(ym-ycentroid));  

  % least squares minimization to determine the radial symmetry center
  % system origin (xc, yc) such that lines y = mx+b have
  % the minimal total distance^2 to the origin
  % inputs m, b, w are defined on a grid, w are the weights for each point
  wm2p1 = w./(m.*m+1);
  sw  = sum(sum(wm2p1));
  smmw = sum(sum(m.*m.*wm2p1));
  smw  = sum(sum(m.*wm2p1));
  smbw = sum(sum(m.*b.*wm2p1));
  sbw  = sum(sum(b.*wm2p1));
  det = smw*smw - smmw*sw;
  xc = (smbw*sw - smw*sbw)/det;   % relative to image center
  yc = (smbw*smw - smmw*sbw)/det; % relative to image center
  end

end
%eof