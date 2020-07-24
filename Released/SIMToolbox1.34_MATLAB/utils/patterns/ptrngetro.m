function [ro, numsubseq] = ptrngetro(ptrninfo, numro)
% Read running order
%
%   [ro, numsubseq] = ptrngetro(ptrninfo, numro)
%
% Input/output arguments:
%
%   ptrninfo   ... [struct]  pattern information created by ptrnopen
%   numro      ... [scalar]  number of the running order (starts from 0)
%   ro         ... [struct]  running order data
%   numsubseq  ... [scalar]  number of different subsequece patterns in
%                            a specified running order (e.g., line angles)
%
% See also ptrnopen, ptrngetnumro, ptrngetnumseq, ptrngetimagenames

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

assert(~isempty(ptrninfo), 'ptrngetro:empty', 'Pattern repertoire is empty.');
assert(~isnan(numro),  'ptrngetro:nan', 'Running order not specified.');
assert((numro >= 0) && (numro <= length(ptrninfo.runningorder)), 'ptrngetro:outofrange', 'Running order out of range.');

ro = ptrninfo.runningorder(numro+1);
numsubseq = length(ro.data);
