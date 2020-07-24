function c = structcat(a,b)
% Concatenate two structures with different fields
%
%   c = structcat(a,b)
%
% Input/output arguments:
%
%   a,b,c   ... [struct]

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

assert(all(size(a) == size(b)),'structcat:size','Structures are not the same size.');

c = cell2struct([struct2cell(a); struct2cell(b)], [fieldnames(a); fieldnames(b)], 1);