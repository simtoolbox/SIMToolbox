function [seq, weights] = seqstriperemoval(seq)
% Correct fluctuations of illumination such that all images
% (and/or image sequences) have the same mean intensity value.
%
%   [IMseq, weights] = seqstriperemoval(IMseq)
%   [seq, weights]   = seqstriperemoval(seq)
%
% Input/output arguments:
%
%   IMseq    ... [m x n x numseq]  sequence of images stored in a matrix
%   seq      ... [struct]  sequence of images created by seq2subseq
%   weights  ... [1 x numseq]  weights for particular images
%
% Example:
%
%   datadir = 'data\polen\pollen 100X 1.45NA';
%   imginfo = imginfoinit(datadir);
%   ptrninfo = ptrnopen(ptrndirinfo(datadir));
%   IMseq = seqload(imginfo, 'z', 2, 'datatype','single');
%   seq = seq2subseq(IMseq, ptrninfo, 1);
%   seq = seqstriperemoval(seq);
%   IM = seqcfhomodyne(seq);
%   figure; imagesc(IM); axis off image; colormap gray;
%
% See also seqload, seq2subseq

% Copyright © 2014-2015 Pavel Krizek
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

if isstruct(seq)
    numsubseq = length(seq);
    weights = ones(1,numsubseq);
    for I = 1:numsubseq
        seq(I).IMseq = striperemoval(seq(I).IMseq);
        weights(I) =  mean(double(seq(I).IMseq(:)));
    end
    weights = mean(weights)./weights;
    for I = 1:numsubseq
        seq(I).IMseq = weights(I) * seq(I).IMseq;
    end
else
    [seq, weights] = striperemoval(seq);
end

% ------------------------------------
function [IMseq, weights] = striperemoval(IMseq)
% ------------------------------------
% estimate weights
numseq = size(IMseq,3);
weights = ones(1,numseq);
for I = 1:numseq
    im = IMseq(:,:,I);
    weights(I) = mean(double(im(:)));
end
weights = mean(weights)./weights;
% remove stripes
for I = 1:numseq
    IMseq(:,:,I) = weights(I) * IMseq(:,:,I);
end

%eof