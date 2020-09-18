function repz = ptrndirinfo(datadir)
% Check if a pattern repertoire is stored in the given directory
%
%   repz = ptrndirinfo(datadir)
%
% Input/output arguments:
%
%   datadir  ... [string]  path to data
%   repz     ... [string]  full path to the repertoire
%
% See also ptrnopen

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

dirinfo = dir([datadir filesep '*.repz']);

switch length(dirinfo)
  case 0
    error('ptrndirinfo:norepz', 'No pattern repertoire in the directory.');
  case 1
    repz = [datadir filesep dirinfo.name];
  otherwise
    error('ptrndirinfo:toomanyrepz', 'Too many pattern repertoires in the directory.');
end
