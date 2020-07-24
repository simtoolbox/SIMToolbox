function IM = seqsubseq(fnc, varargin)
% Process sequence as an average of all subsequences
%
%   IM = seqsubseq(fnc, IMseq)
%   IM = seqsubseq(fnc, IMseq, MaskOn)
%   IM = seqsubseq(fnc, seq)
%   IM = seqsubseq(fnc, seq, mask)
%
% Input/output arguments:
%
%   IMseq     ... [m x n x numseq]  sequence of images stored in a matrix
%   MaskOn    ... [m x n x numseq]  mask sequence
%   seq       ... [struct]  sequence of images created by seq2subseq
%   mask      ... [struct]  sequence of masks created by seq2subseq
%   fnc       ... [handle]  processing function
%
% See also seqload, seq2subseq, ptrnopen, ptrngetro

% Copyright © 2009-2015 Pavel Krizek
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

if isstruct(varargin{1})
  IM = 0;
  numsubseq = length(varargin{1});
  for I = 1:numsubseq
    if nargin > 2
      IM = IM + fnc(varargin{1}(I).IMseq, varargin{2}(I).IMseq);
    else
      IM = IM + fnc(varargin{1}(I).IMseq);
    end
  end
  IM = IM / numsubseq;
else
  if nargin > 2
    IM = fnc(varargin{1}, varargin{2});
  else
    IM = fnc(varargin{1});
  end
end

%eof