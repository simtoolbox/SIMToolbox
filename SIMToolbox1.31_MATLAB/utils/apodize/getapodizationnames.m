function fnc = getapodizationnames
% Read names of apodizing filters
%
%   fnc = getapodizationnames()
%
% Output arguments:
%
%   fnc   ... [struct]   available filters and their properties

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

% get directory of the current mfile
fd = fileparts_dir([mfilename('fullpath') '.m']);

% list all apodizing filters in this mfile directory
list = dir([fd filesep 'apodize_*.m']);
num = length(list);

% fill output array of structures
for I = 1:num
  fnc(I) = feval(list(I).name(1:end-2));
end

%eof