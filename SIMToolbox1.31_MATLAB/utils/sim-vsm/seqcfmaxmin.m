function IM = seqcfmaxmin(IMseq)
% Confocal image computed using max-min scheme
%
%   IM = seqcfmaxmin(IMseq)
%
% Input/output arguments:
%
%   IMseq  ... [m x n x numseq]  sequence of images stored in a matrix
%   IM     ... [m x n]  final image computed from image sequence
%
% Example:
%
%   imginfo = imginfoinit('data\polen\pollen 100X 1.45NA');
%   IMseq = seqload(imginfo, 'z', 2, 'datatype','single');
%   IM = seqcfmaxmin(IMseq);
%   figure; imagesc(IM); axis off image; colormap gray;
%
% See also seqload, seqwf, seqcfhomodyne, seqcfscaledsub

% Copyright � 2009-2015 Pavel Krizek
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

if nargin < 1
  IM.mfile = fileparts_name([mfilename('fullpath') '.m']);
  IM.name = 'Max - Min';
  IM.id = 'maxmin';
  IM.applymask = 0;
  return;
end

IM = seqsubseq(@cfmaxmin, IMseq);

function IM = cfmaxmin(IMseq)

IM = seqopmax(IMseq) - seqopmin(IMseq);

%eof