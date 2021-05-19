function seq = sim_extract(seq,ptrn)
% Extract spectral components from a sequence of images according to Gustafsson
%
%   seq = sim_extract(seq, ptrn)
%
% Input/output arguments:
%
%   seq         ... [struct]  image sequence (created by seq2subseq)
%   ptrn        ... [struct]  running order data (created by ptrnchecklines)
%
% See also seqload, seq2subseq, ptrnload, ptrnchecklines

% Copyright © 2009-2015 Pavel Krizek, Tomas Lukes, lukestom@fel.cvut.cz
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

% extract spectra for every angle separately
[seq(:).Sk] = deal([]);
for I = find([ptrn.enable])
    if isfield(ptrn,'phsoff'), phsoff = ptrn(I).phsoff; else, phsoff = 0; end
    seq(I).Sk = extractspectra(seq(I),ptrn(I).numharmon,phsoff);
end

% ----------------------------------------------------------------------------

function Sk = extractspectra(seq,numharmon,phsoff)
% Extract spectra S(k), S(k-p), S(k-2p), ...
% by solving system of equations
%
%   D(k) = sum_m [ Om(k) * exp(i*m*fi) * S(k-m*p) ]
%
% for unknowns S(k-m*p). See Eq. (9) in Gustafsson et al. Biophysical Journal (2008).
% Here Om(k) and p are known, D(k) are images with different pattern position.

numphases = seq.num;              % # of illumination positions (phases)
numcomp = 2*numharmon+1;          % # of extracted pattern components

assert(numcomp <= numphases, 'sim_extract: Underdetermined system of equations.');

% define order of output spectra and precompute separation matrix
comp = -numharmon:numharmon;    % [ ... -3 -2 -1 0 1 2 3 ... ]

if numel(phsoff)>1 
    fi = phsoff;
else
    fi = phsoff+2*pi*(0:numphases-1)/numphases;
end
W = exp(1i * fi' * comp);

% FFTs of D(k)
if isfield(seq,'IMseqFFT')
    D = seq.IMseqFFT;
else
    D = seq.IMseq;
end

siz = size(D(:,:,1));

% Compute S(k) = pinv(W) * D(k)
S = reshape(D,[prod(siz),numphases])*pinv(W)';
S = reshape(S,[siz, numcomp]);

Sk(numcomp) = struct('S',{[]},'comp',{[]});
for I = 1:numcomp
    % save output
    Sk(I).S = S(:,:,I);
    Sk(I).comp = comp(I);
end
