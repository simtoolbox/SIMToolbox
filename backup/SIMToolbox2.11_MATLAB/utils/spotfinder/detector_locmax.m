function [loc, params] = detector_locmax(im, params)
% Find local intensity maxima above threshold
%
%   [loc, params] = detector_locmax(im, params)
%
% Input/output arguments:
%
%   im                ... [m x n]  input image
%   loc               ... [struct] localizations: loc.x, loc.y, loc.val
%   params.dim        ... [scalar] image dimension use (default end)
%   params.conn       ... [scalar] connectivity (default 8)
%   params.threshold  ... [struct] see threshold_* (default spotfinder_default_threshold)
%
% See also threshold_val, threshold_fnc, threshold_mustd_val

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
if nargin < 2 || ~isfield(params,'dim')
  params.dim = 'end';
end

if nargin < 2 || ~isfield(params,'conn')
  params.conn = 8;
end

if nargin < 2 || ~isfield(params,'threshold')
  params.threshold = spotfinder_default_threshold;
end

% return function info
if nargin < 1
  loc.mfile = fileparts_name([mfilename('fullpath') '.m']);
  loc.type = 'locmax';
  loc.name = 'Local maxima';
  loc.params = params;
  return;
end

[m,n,dim] = size(im);

if ischar(params.dim) && strcmp(params.dim,'end'), params.dim = dim; end;

assert(isfield(params.threshold,'type'), 'detector:params', 'LOCMAX: Threshold must be a structure.');
assert(isscalar(params.dim) && params.dim > 0 && params.dim <= dim && params.dim == fix(params.dim), 'detector:params', 'LOCMAX: Wrong image dimension.');
assert(params.conn == 4 || params.conn == 8, 'detector:params', 'LOCMAX: Wrong connectivity.');

% image to threshold
im = double(im(:,:,params.dim));

% estimate threshold
[thr, params.threshold.params] = feval(['threshold_' params.threshold.type], im, params.threshold.params);

% find local maxima (center is greater or equal) 
idx = findlocmax2d(im, min(thr(:)), params.conn);

% if thr is a matrix
if numel(thr) > 1
  ind = im(idx) > thr(idx);
  idx = idx(ind);
end

% output
[loc.y, loc.x] = ind2sub([m,n], double(idx));
loc.val = im(idx);

%eof