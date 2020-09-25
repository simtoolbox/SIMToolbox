function [rsub, csub, valsub] = subpix2d_fitquadric(r, c, im, nbr)
% Compute subpixel position of local intensity maxima by fitting
% a quadric function: ax^2 + by^2 + cx + dy + e = z
%
%    [rsub, csub, valsub] = subpix2d_fitquadric(r, c, im, nbr)
%
% Input/output arguments:
%
%    r,c         ... [npts x 1] row and column coordinates of approximate position 
%    im          ... [m x n]    image matrix
%    nbr         ... [scalar]   interpolate in a neighbourhood (default 1)
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

if (nargin < 4), nbr = 1; end;

assert(~isempty(r) && ~isempty(c), 'subpix2d:empty','No coordinates are given.');
assert(numel(r) == numel(c), 'subpix2d:notconsistent','Coordinates are not consistent.');
assert(nbr > 0, 'subpix2d:nbr','Neighbourhood size must be greater than zero.');

r = round(r(:));
c = round(c(:));
[m,n] = size(im);

% indices of feature points
ind = sub2ind([m,n], r, c);

% 8-neibourhood coordinates
[C,R] = meshgrid(-nbr:nbr,-nbr:nbr);
C = C(:); R = R(:);
numnbrs = length(C);
indnbr = repmat(ind,1,numnbrs) + repmat((C*m+R)',length(ind),1);

% local parabola fitting by LSQ
par = im(indnbr) * pinv([R.^2, C.^2, R, C, ones(numnbrs,1)])';

% subpixel corrections to original row and column coords
r0 = -par(:,3) ./ par(:,1) / 2;
c0 = -par(:,4) ./ par(:,2) / 2;

% Add subpixel corrections
rsub = r + r0; 
csub = c + c0;

% interpolated value at subpixel coordinates
valsub = sum([r0.^2, c0.^2, r0, c0] .* par(:,1:4),2) + par(:,5);

%eof