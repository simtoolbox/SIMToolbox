function method = spotfinder_method_manual(db)

% Copyright © 2014,2015 Pavel Krizek, Tomas Lukes, lukestom@fel.cvut.cz
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

method.type = 'manual';
method.params.k0 = db.k0;
method.params.angl = db.angl;
method.params.radius = db.radius;
method.params.radiusequal = db.radiusequal;