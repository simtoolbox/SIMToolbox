function numptrn = ptrngetnumseq(ptrninfo, numro)
% Get number of illumination patterns in a given running order
%
%   numptrn = ptrngetnumseq(ptrninfo, numro)
%
% Input/output arguments:
%
%   ptrninfo   ... [struct]  pattern information created by ptrnopen
%   numro      ... [scalar]  number of the running order (starts from 0)
%   numptrn    ... [scalar]  number of patterns in a given running order
%
% See also ptrnopen, ptrngetro, ptrngetnumro, ptrngetimagenames

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

assert((numro >= 0) && (numro < ptrngetnumro(ptrninfo)), 'ptrngetnumseq:outofrange', 'Running order out of range.');

numptrn = ptrninfo.runningorder(numro+1).numseq;
