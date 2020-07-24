function [ptrn, numsubseq, ro] = ptrnchecklines(ptrninfo, numro)
% Test if the running order contains lines only
%
%   [ptrn, numangles, ro] = ptrnchecklines(ptrninfo, numro)
%
% Input/output arguments:
%
%   ptrninfo   ... [struct]  pattern information created by ptrnopen
%   numro      ... [scalar]  number of the running order (0 is the first)
%   ptrn       ... [struct]  pattern description contained in the running order
%   numsubseq  ... [scalar]  number of subsequences in (e.g., number of angles)
%   ro         ... [struct]  running order data
%
% See also ptrnopen, ptrngetro, ptrngetnumro, ptrngetnumseq

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

% read running order and number of angles
[ro, numsubseq] = ptrngetro(ptrninfo, numro);

% test line pattern in all subsequences
try
  ptrn = [ro.data{:}];
  assert(all(strcmp('lines',{ptrn.id})), 'ptrn:nolines', 'Pattern must contain lines for SIM processing.');
catch err
  ptrn = [];  % empty if any of the patterns is not lines
end
