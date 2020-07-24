function def = spotfinder_default_threshold
% Default threshold for spotfinder detector
%
%   def = spotfinder_default_threshold()
%
% Input/output arguments:
%
%   def   ... [struct]  default threshold definition
%
% See also spotfinder, spotfinder_default_detector

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

def = struct('type','std_val','params',struct('thr',1));
%def = struct('type','fnc','params',struct('fnc','0'));
%def = struct('type','val','params',struct('thr',0));