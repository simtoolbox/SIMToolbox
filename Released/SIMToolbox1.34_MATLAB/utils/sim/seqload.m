function IMseq = seqload(imginfo, varargin)
% Load an image sequence at given position
%
%   IMseq = seqload(imginfo, 'PropertyName', PropertyValue, ...)
%
% Input/output arguments:
%
%   imginfo        ... [struct]  image information created by imginfoinit
%   IMseq          ... [m x n x numseq]  sequence of images stored in a matrix
%
%   Property Names:
%     'z'          ... [scalar]  z-stack coordinate (default 1)
%     'w'          ... [scalar]  channel cordinate (default 1)
%     't'          ... [scalar]  time coordinate (default 1)
%     'offset'     ... [scalar]  circular shift of the sequence (default 0)
%     'datatype'   ... [string]  e.g., 'single', 'double', ... (default 'uint16')
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
% See also imginfoinit, imgload, seqrewind, seq2subseq

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

[z,w,t,offset,datatype] = chkinput(varargin{:});

IMseq = zeros([imginfo.image.size.y,imginfo.image.size.x,imginfo.image.size.seq],datatype);
for I = 1:imginfo.image.size.seq
    IMseq(:,:,I) = imgload(imginfo,'z',z,'t',t,'w',w,'seq',I,'datatype',datatype);
end

if offset ~= 0
    IMseq = seqrewind(IMseq, offset);
end

% ----------------------------------------------------------------------------
function [z,w,t,offset,datatype] = chkinput(varargin)
% default options
z = 1; w = 1; t = 1; offset = 0; datatype = 'uint16';
% run through input arguments
for I = 1:2:length(varargin)
    assert(ischar(varargin{I}) && any(strcmp(varargin{I},{'z','w','t','offset','datatype'})),'seqload:chkinput','Wrong property name.');
    eval([lower(varargin{I}) '=varargin{I+1};']);
end

%eof