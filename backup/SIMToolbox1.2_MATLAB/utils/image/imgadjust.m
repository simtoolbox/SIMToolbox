function IM = imgadjust(IM, in, out)
% Adjust image intensity values
% 
%   J = imadjust(I, [low_in; high_in], [low_out; high_out])
%
% Maps the values in I to new values in J such that values between
% low_in and high_in map to values between low_out and high_out.
% Interval for low/high in/out is not limited as in imadjust.
%
% See also imadjust

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

IM = (IM - in(1)) / (in(2) - in(1)) * (out(2) - out(1)) + out(1);