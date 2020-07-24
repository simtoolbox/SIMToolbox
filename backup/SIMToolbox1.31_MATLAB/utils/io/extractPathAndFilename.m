function [pathstr, filename] = extractPathAndFilename(filename, filenameold)
% Extract image name and directory from the file path 
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

pathstr = fileparts_dir(filename);
fname = fileparts_nameext(filename);
if isempty(pathstr)  
  pathstr = fileparts_dir(filenameold);
  filename = [pathstr filesep fname];
end