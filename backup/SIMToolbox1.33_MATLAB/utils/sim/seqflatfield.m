function seq = seqflatfield(seq, IMwhite, IMblack, scale)
% Flat field correction of illumination for every image in a sequence
%
%   IMseq = seqflatfield(IMseq, IMwhite, IMblack)
%   seq   = seqflatfield(seq, IMwhite, IMblack)
%
% Input/output arguments:
%
%   IMseq    ... [m x n x numseq]  sequence of images stored in a matrix
%   seq      ... [struct]  sequence of images created by seq2subseq
%   IMwhite  ... [m x n]  image with full illumination
%   IMblack  ... [m x n]  image with no illumination (default 0)
%   scale    ... scalar for denormalizing input image sequence
%
% See also seqload, seq2subseq, imgflatfield

% Copyright © 2019-2015 Pavel Krizek, Tomas Lukes, lukestom@fel.cvut.cz
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

if nargin < 2, IMwhite = []; end
if nargin < 3, IMblack = []; end

if isstruct(seq)
  for I = 1:length(seq)
    seq(I).IMseq = flatfield(seq(I).IMseq, IMwhite, IMblack, scale);
  end
else
  seq = flatfield(seq, IMwhite, IMblack, scale);
end

% ------------------------------------
function IMseq = flatfield(IMseq, IMwhite, IMblack, scale)
% ------------------------------------

numseq = size(IMseq,3);

for I = 1:numseq
  IMseq(:,:,I) = imgflatfield(IMseq(:,:,I), IMwhite, IMblack, scale);
end

%eof