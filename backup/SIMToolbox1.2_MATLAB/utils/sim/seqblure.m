function seq = seqblure(seq, varargin)
% Blure every image in a sequence using imfilterseparable
%
%   IMseq = seqblure(IMseq, parameters)
%   seq   = seqblure(seq, parameters)
%
% Input/output arguments:
%
%   IMseq       ... [m x n x numseq]  sequence of images stored in a matrix
%   seq         ... [struct]  sequence of images created by seq2subseq
%   parameters  ... definition of a bluring kernel, see fspecialseparable
%
% See also seqload, seq2subseq, fspecialseparable, imfilterseparable

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
    seq(I).IMseq = imblure(seq(I).IMseq, varargin{:});
  end
else
  seq = imblure(seq, varargin{:});
end

% ------------------------------------
function IMseq = imblure(IMseq, varargin)
% ------------------------------------

numseq = size(IMseq,3);

mask = fspecialseparable(varargin{:});

for I = 1:numseq
   IMseq(:,:,I) = imfilterseparable(IMseq(:,:,I), mask, 'replicate');
end

%eof