function def = spotfinder_default_filter
% Default filter for spotfinder
%
%   def = spotfinder_default_filter()
%
% Input/output arguments:
%
%   def   ... [struct]  default filter definition
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

def = struct('type','wavelet','params',struct('order',3,'scaling',2,'numlevels',2));
% def = struct('type','gauss','params',struct('sigma',1));
