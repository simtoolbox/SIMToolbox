function seq = seqifft2(seq,apodize)
% Inverse fast Fourier transform applied to every image in a sequence
%
%   IMseq = seqifft2(IMseqFFT, apodize)
%   seq   = seqifft2(seq, apodize)
%
% Input/output arguments:
%
%   IMseq    ... [m x n x numseq]  sequence of images stored in a matrix
%   IMseqFFT ... [m x n x numseq]  Fourier transformed images
%   seq      ... [struct]  sequence of images created by seq2subseq
%   apodize  ... [m x n]   matrix with apodizing filter (default: no apodizing)
%
% See also seqfft2, seqload, seq2subseq, seqremovemean, seqpadsmooth

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

if nargin < 2 || isempty(apodize)
    apodize = 1;
end

if isstruct(seq)
    [seq(:).IMseq] = deal([]);
    for I = 1:length(seq)
        seq(I).IMseq = makeifft2(seq(I).IMseqFFT,apodize);
    end
else
    seq = makeifft2(seq,apodize);
end

% ------------------------------------
function IMseq = makeifft2(IMseq,apodize)
% ------------------------------------
numseq = size(IMseq,3);
for I = 1:numseq
    IMseq(:,:,I) = fftshift(ifft2(fftshift(IMseq(:,:,I).*apodize)));
end

%eof