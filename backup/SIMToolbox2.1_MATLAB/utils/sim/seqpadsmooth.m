function seq = seqpadsmooth(seq, padsize, sigma)
% Pad image sequence and smooth edges by a sigmoid function.
% This is useful for removal of a central cross in FFT.
%
%   IMseq = seqpadsmooth(IMseq, padsize, sigma)
%   seq   = seqpadsmooth(seq, padsize, sigma)
%
% Input/output arguments:
%
%   IMseq    ... [m x n x numseq]  sequence of images stored in a matrix
%   seq      ... [struct]  sequence of images created by seq2subseq
%   padsize  ... [scalar]  size of padding
%   sigma    ... [scalar]  smoothing of image edges
%
% See also seqload, seq2subseq, imgrmpadding, seqremovemean

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

if isstruct(seq)
    for I = 1:length(seq)
        seq(I).IMseq = padsmooth(seq(I).IMseq, padsize, sigma);
    end
else
    seq = padsmooth(seq, padsize, sigma);
end

% ------------------------------------
function IMseqout = padsmooth(IMseqin, padsize, sigma)
% ------------------------------------
[m,n,num] = size(IMseqin);
% create mask with sigmoid smoothing edges
x = 1:(n+2*padsize);
y = (1:(m+2*padsize))';
mask = repmat(sigmoid(sigma*(x-padsize)) - sigmoid(sigma*(x-n-padsize-1)), m+2*padsize, 1) .* ...
    repmat(sigmoid(sigma*(y-padsize)) - sigmoid(sigma*(y-m-padsize-1)), 1, n+2*padsize);
% smooth padded image by sigmoid function
IMseqout = zeros([m,n]+2*padsize,class(IMseqin));
for I = 1:num
    IMseqout(:,:,I) = padarray(IMseqin(:,:,I), [padsize padsize], 'replicate') .* mask;
end

%eof