function [thr, params] = threshold_mustd_val(im, params)
% Threshold image by a constant: thr = mean(im) + std(im) * params.thr
%
%   [thr, params] = threshold_mustd_val(im, params)
%
% Input/output arguments:
%
%   im           ... [m x n]   input image
%   thr          ... [scalar]  output threshold value
%   params.thr   ... [scalar]  threshold value (default 1)
%   params.dim   ... [scalar]  image dimension (default 1)
%
% See also spotfinder

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
if nargin < 2 || ~isfield(params,'thr')
  params.thr = 1;
end

if nargin < 2 || ~isfield(params,'dim')
  params.dim = 1;
end

% return function info
if nargin < 1
  thr.mfile = fileparts_name([mfilename('fullpath') '.m']);
  thr.type = 'mustd_val';
  thr.name = 'mu + std*thr';
  thr.params = params;
  return;
end

im = im(:,:,params.dim);
thr = mean(im(:)) + std(im(:)) * params.thr;

%eof