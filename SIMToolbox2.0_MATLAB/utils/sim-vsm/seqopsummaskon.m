function [sumInMon,  sumMon]  = seqopsummaskon(IMseq, MaskOn)
% Sum sequence of images at MaskOn positions
%
%   [sumInMon,  sumMon]  = seqopsummaskon(IMseq, MaskOn)
%
% Input/output arguments:
%
%   IMseq     ... [m x n x numseq]  sequence of images stored in a matrix
%   MaskOn    ... [m x n x numseq]  mask sequence
%   sumInMon  ... [m x n]  summed images at MaskOn positions
%   sumMon    ... [m x n]  summed mask at on positions
%
% See also seqload, seqopsum, seqopsummaskoff

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

% frame by frame processing to save memmory
sumInMon = 0;
sumMon = 0; 
for I = 1:size(IMseq,3)
  Mon = MaskOn(:,:,I);
  sumInMon = sumInMon + IMseq(:,:,I) .* Mon;
  sumMon = sumMon + Mon;
end 
