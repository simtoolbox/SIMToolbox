function IMseq = seqrewind(IMseq, offset)
% Circular shift of images along the third dimension
%
%   IMseq = seqrewind(IMseq, offset)
%
% Input/output arguments:
%
%   IMseq    ... [m x n x numseq]  sequence of images stored in a matrix
%
% See also seqload, seq2subseq

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

numseq = size(IMseq,3);
rewind = @(x,number)(mod(x-1,number)+1);
IMseq = IMseq(:,:,rewind(offset+(1:numseq),numseq));
