function [s, overlapmask] = sim_matchspectra(a,b,thr)
% Compute "s" such that B = s * A for overlaping region
%
%   [s, overlapmask] = sim_matchspectra(A,B,thr)
%
% For complex numbers
%
%   real(B) + i*imag(B) = (real(A) + i*imag(A)) * (real(s) + i*imag(s))
%
% This can be rewritten into a system of equations:
%
%   re(B) = re(A) * re(s) - im(A) * im(s)
%   im(B) = im(A) * re(s) + re(A) * im(s)
% 
% Input/output arguments:
%
%   A,B      ... [struct]  filds O for mask, S for values
%   thr      ... [scalar]  ovelap threshold
%
% See also sim_combine

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

if nargin < 3, thr = 0.5; end

% overlapmask = a.O > thr * max(a.O(:)) &  b.O > thr * max(b.O(:));
aO = abs(a.O);
bO = abs(b.O);
overlapmask = aO > thr * max(aO(:)) &  bO > thr * max(bO(:));

A = a.S(overlapmask);   % ./ a.O(overlapmask);
B = b.S(overlapmask);   % ./ b.O(overlapmask);

% complex linear regression to solve system of equations
s = sum(conj(A).*B)/sum(abs(A).^2); % analytical expression of the same equation

%eof