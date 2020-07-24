function [sumInMoff,  sumMoff]  = seqopsummaskoff(IMseq, MaskOn)
% Sum sequence of images at MaskOff positions
%
%   [sumInMoff,  sumMoff]  = seqopsummaskoff(IMseq, MaskOn)
%
% Input/output arguments:
%
%   IMseq     ... [m x n x numseq]  sequence of images stored in a matrix
%   MaskOn    ... [m x n x numseq]  mask sequence
%   sumInMoff ... [m x n]  summed images at MaskOff positions
%   sumMoff   ... [m x n]  summed mask at off positions
%
% See also seqload, seqopsum, seqopsummaskon

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
sumInMoff = 0;
sumMoff = 0;  
for I = 1:size(IMseq,3)
  Moff = 1 - MaskOn(:,:,I);
  sumInMoff = sumInMoff + IMseq(:,:,I) .* Moff;
  sumMoff = sumMoff + Moff;
end
