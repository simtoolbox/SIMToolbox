function [seq, ptrn] = seq2subseq(IMseq, ptrninfo, numro)
% Create subsequence of images from image stack based on the running order.
% Note that conversion is limited to line patterns only.
%
%   [seq, ptrn] = seq2subseq(IMseq, ptrninfo)
%   [seq, ptrn] = seq2subseq(IMseq, ptrninfo, numro)
%
% Input/output arguments:
%
%   IMseq     ... [m x n x numseq]  sequence of images stored in a matrix
%   ptrninfo  ... [struct]  pattern information (created by ptrnopen)
%   numro     ... [scalar]  number of the running order (starts from 0, uses repz default if not specified)
%   seq       ... [struct]  sequence of images
%   ptrn      ... [struct]  pattern description contained in the running order
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
% See also seqload, ptrnopen, ptrngetro, ptrnchecklines

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


% number of the running order - uses repz default if not specified
if nargin < 3 || isempty(numro) || isnan(numro)
numro = ptrninfo.default;
end

% test for an empty image sequence
assert(~isempty(IMseq), 'seq2subseq:stackempty', 'Image sequence is empty.');

% check if all patterns are lines
[ptrn, numsubseq, ro] = ptrnchecklines(ptrninfo, numro);

% split sequence to subsequences
count = cumsum([1 ptrn.num]);  % starting indices
assert(count(end)-1 == size(IMseq,3), 'seq2subseq:numimages', 'Number of images does not agree with the running order.' );
for J = 1:numsubseq
    idx = count(J):(count(J+1)-1); % index of subimages
    seq(J) = initdata(IMseq(:,:,idx), ro.data{J});
end

% ---------------------------------------------------------------------------
function seq = initdata(IMseq, ptrnseq)
% ---------------------------------------------------------------------------

seq.angle = ptrnseq.angle;
seq.num = ptrnseq.num;
seq.IMseq = IMseq;

%eof