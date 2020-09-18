function [fit, loc, imb] = spotfinder(imraw, filter, detector, estimator)
% Spotfinder - detection of local intensity maxima in image
%
%   [fit, loc, imb] = spotfinder(imraw)
%   [fit, loc, imb] = spotfinder(imraw, filter, detector, estimator)
%
% Input/output arguments:
%
%   imraw      ... [m x n]   input image
%   filter     ... [struct]  filter definition (default spotfinder_default_filter)
%   detector   ... [struct]  detector definition (default spotfinder_default_detector)
%   estimator  ... [struct]  estimator definition (default spotfinder_default_estimator)
%   loc        ... [struct]  pixel localizations: loc.x, loc.y, loc.val
%   fit        ... [struct]  subpixel localizations: fits.x, fits.y, fits.val, fits.dst
%   imb        ... [m x n]   filtered input image
%
% See also spotfinder_default_filter, spotfinder_default_detector, spotfinder_default_estimator

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

% default values
if nargin < 2 || isempty(filter)
  filter = spotfinder_default_filter;
end

if nargin < 3 || isempty(detector)
  detector = spotfinder_default_detector;
end

if nargin < 4 || isempty(estimator)
  estimator = spotfinder_default_estimator;
end

% reduce noise in image
if ~isfield(filter,'params'), filter.params = []; end
imb = feval(['filter_' filter.type], imraw, filter.params);

% detect spots
if ~isfield(detector,'params'), detector.params = []; end
loc = feval(['detector_' detector.type], imb, detector.params);

% fit spots
if ~isfield(estimator,'params'), estimator.params = []; end
fit = feval(['estimator_' estimator.type], imraw, loc, estimator.params);

%eof