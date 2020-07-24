function [val,idx] = locmax1d(x, thr)
% Find local maxima along 1D vector
%
%   [val,idx] = locmax1d(x, thr)
%
% Input/output arguments:
%
%   x     ... [1 x n]  data vector
%   thr   ... [scalar] find local maxima > threshold (default no threshold)
%   val   ... [1 x npts]  values at local maxima
%   idx   ... [1 x npts]  position of local maxima

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

% make a vector
x = x(:);
npts = length(x);

% find local maxima
idx = find([false; diff(x(1:npts-1)) > 0 & diff(-x(2:npts)) > 0; false]);

% threshold local maxima
if nargin > 1
  idx = idx(x(idx) > thr);  
end;

% value of x at all local maxima
val = x(idx);