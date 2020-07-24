function fnc = spotfinder_getnames(str)
% Find available functions for filter/detector/threshold/estimator
%
%   fnc = spotfinder_getnames(str)
%
% Input/output arguments:
%
%   str   ... [string]  mask of functions (e.g., 'filter')
%   fnc   ... [struct]  list of available functions
%
% See also spotfinder, filter_*, detector_*, threshold_*, estimator_*

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

fd = fileparts_dir([mfilename('fullpath') '.m']);

list = dir([fd filesep str '_*.m']);
num = length(list);

for I = 1:num
  fnc(I) = feval(list(I).name(1:end-2));
end
