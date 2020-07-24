function IM = seqopmin(IMseq)
% Minimum intensity projection of an image sequence.
%
%   IM = seqopmin(IMseq)
%
% Input/output arguments:
%
%   IMseq  ... [m x n x numseq]  sequence of images stored in a matrix
%   IM     ... [m x n]  average of image sequence
%
% Example:
%
%   imginfo = imginfoinit('data\polen\pollen 100X 1.45NA');
%   IMseq = seqload(imginfo, 'z', 2, 'datatype','single');
%   IM = seqopmin(IMseq);
%   figure; imagesc(IM); axis off image; colormap gray;
%
% See also seqload, seqopav, seqopsum, seqopmax

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

% frame by frame processing to save memmory
IM = Inf;
for I = 1:size(IMseq,3)
  IM = min(IM,IMseq(:,:,I));
end
