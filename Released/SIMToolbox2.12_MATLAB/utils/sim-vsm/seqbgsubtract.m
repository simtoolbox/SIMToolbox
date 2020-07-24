function seq = seqbgsubtract(seq,thresh)
% Subtract low values in the background.
%
%   IMseq = seqbgsubtract(IMseq,thresh)
%   seq   = seqbgsubtract(seq,thresh)
%
% Input/output arguments:
%
%   IMseq    ... [m x n x numseq]  sequence of images stored in a matrix
%   seq      ... [struct]  sequence of images created by seq2subseq
%   thresh   ... subtraction threshold (0,1)
%
% Example:
%
%   datadir = 'data\polen\pollen 100X 1.45NA';
%   imginfo = imginfoinit(datadir);
%   ptrninfo = ptrnopen(ptrndirinfo(datadir));
%   IMseq = seqload(imginfo, 'z', 2, 'datatype','single');
%   seq = seq2subseq(IMseq, ptrninfo, 1);
%   seq = seqstriperemoval(seq);
%   seq = seqbgsubtract(seq,0.1);	% cut-off values lower than 10%
%   IM = seqcfhomodyne(seq);
%   figure; imagesc(IM); axis off image; colormap gray;
%
% See also seqload, seq2subseq

% Copyright © 2019 Jakub Pospisil
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

if nargin == 1
    thresh = 0;
end

if isstruct(seq)
    numsubseq = length(seq);
    for I = 1:numsubseq
        tmp = seq(I).IMseq;
        tmp(tmp<thresh) = thresh;
        seq(I).IMseq = tmp;
    end
else
    seq(seq<thresh) = thresh;
end

%eof