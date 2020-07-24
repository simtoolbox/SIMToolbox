function printerror(err)
% Print error message
%
%   printerror(err)
%
% Input/output arguments:
%
%   err   ... [struct]  error message
%
% See also lasterr

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

fprintf('%s\n', err.message);
for I = 1:length(err.stack);
  fprintf('%s at line %d\n', err.stack(I).file, err.stack(I).line);
end
fprintf('\n\n');
waitfor(warndlg(err.message,'Warning','modal'));
