function seq = seqremovemean(seq)
% Subtract image mean value for every image in a stack.
% This is useful for FFT
%
%   IMseq = seqremovemean(IMseq)
%   seq   = seqremovemean(seq)
%
% Input/output arguments:
%
%   IMseq    ... [m x n x numseq]  sequence of images stored in a matrix
%   seq      ... [struct]  sequence of images created by seq2subseq
%
% See also seqload, seq2subseq, seqpadsmooth

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

if isstruct(seq) % image sequence
  for I = 1:length(seq)
    seq(I).IMseq = removemean(seq(I).IMseq); 
  end
else % image stack
  seq = removemean(seq);
end

% ------------------------------------
function IMseq = removemean(IMseq)
% ------------------------------------

numseq = size(IMseq,3);
for I = 1:numseq
  im = IMseq(:,:,I);
  IMseq(:,:,I) = IMseq(:,:,I) - mean(im(:));
end

%eof
