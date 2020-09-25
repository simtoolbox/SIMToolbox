function pathstr = fileparts_dir(filename)
% Extract directory from the file name
%
%   str = fileparts_dir(filename)
%
% See also fileparts_name, fileparts_nameext

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

[pathstr, name, ext] = fileparts(filename);

if isempty(pathstr)
  return
end

% change '/' to '\'
pathstr = strrep(pathstr,'/',filesep);

if isempty(ext)
  pathstr = [pathstr filesep name];
end

% remove '\' in the end
if ~isempty(pathstr) && (pathstr(end) == filesep)
  pathstr(end) = []; 
end

