function ro = ro_lines(name, trigger, angle, on1, off1, step1, on2, off2, step2)

% Copyright © 2019-2015 Pavel Krizek
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

if nargin <= 6
  on2 = on1; off2 = off1; step2 = step1;
end

data = {};
for I = 1:length(angle)
  if angle(I) == 0 || angle(I) == 90
    data = [data, { struct('id', 'lines', 'angle', angle(I), 'on', on1, 'off', off1, 'step', step1) }];
  else
    data = [data, { struct('id', 'lines', 'angle', angle(I), 'on', on2, 'off', off2, 'step', step2) }];
  end
end

ro = struct('name', [name '_' trigger], 'trigger', trigger, 'data', { data });