function [fits, params] = estimator_lsq_fitquadric(imraw, loc, params)
% Compute position of local maxima to subpixel accuracy by fitting a quadric function
%
%   [fits, params] = estimator_lsq_fitquadric(imraw, loc, params)
%
% Input/output arguments:
%
%   imraw             ... [m x n]  input image
%   loc               ... [struct] pixel localizations: loc.x, loc.y, loc.val
%   fits              ... [struct] subpixel localizations: fits.x, fits.y, fits.val, fits.dst
%   params.nbr        ... [scalar] neighbourhood (default 1)
%
% See also subpix2d_fitquadric

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

% default parameters
if nargin < 3 || ~isfield(params,'nbr')
  params.nbr = 1;
end

% return function info
if nargin < 1
  fits.mfile = fileparts_name([mfilename('fullpath') '.m']);
  fits.type = 'lsq_fitquadric';
  fits.name = 'LSQ quadric fit';
  fits.params = params;
  return;
end

assert(isscalar(params.nbr) && params.nbr > 0 && params.nbr == fix(params.nbr), 'estimator:params', 'LSQFITQUADRIC: Wrong neighbourhood size.');

try
  % compute subpixel coordinates
  [fits.y, fits.x, fits.val] = subpix2d_fitquadric(loc.y, loc.x, imraw, params.nbr);
  % distances betwenn pixel and subpixel coordinates
  fits.dst = sqrt((loc.x-fits.x).^2 + (loc.y-fits.y).^2);
catch err
  if strcmp(err.identifier,'subpix2d:empty')
    fits.x = zeros(0,1);
    fits.y = zeros(0,1);
    fits.val = zeros(0,1);
    fits.dst = zeros(0,1);
  end
end

% eof