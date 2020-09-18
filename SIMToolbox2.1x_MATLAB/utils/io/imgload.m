function im = imgload(imginfo, varargin)
% Load an image from a multilayer TIFF
%
%   im = imgload(imginfo, 'PropertyName', PropertyValue, ...)
%
% Input/output arguments:
%
%   imginfo        ... [struct]  image stack information created by imginfoinit
%   im             ... [m x n] matrix with an image
%
%   Property Names:
%     'z'          ... [scalar]  z-stack coordinate (default 1)
%     'w'          ... [scalar]  channel cordinate (default 1)
%     't'          ... [scalar]  time coordinate (default 1)
%     'seq'        ... [scalar]  sequence coordinate (default 1)
%     'datatype'   ... [string]  e.g., 'single', 'double', ... (default 'uint16')
%
% Example:
%
%   imginfo = imginfoinit(filename);
%   im = imgload(imginfo,'z',10,'seq',5,'datatype','double');
%
% See also imginfoinit, imgdirinfo

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

[z, w, t, seq, datatype] = chkinput(varargin{:});

assert((z > 0) && (z <= imginfo.image.size.z), 'imgload:outofrange', 'Z out of range.');
assert((w > 0) && (w <= imginfo.image.size.w), 'imgload:outofrange', 'W out of range.');
assert((t > 0) && (t <= imginfo.image.size.t), 'imgload:outofrange', 'T out of range.');
assert((seq > 0) && (seq <= imginfo.image.size.seq), 'imgload:outofrange','SEQ out of range.');

% determine frame
frame = 1+(z-1)*imginfo.data.offset.z + ...
    (w-1)*imginfo.data.offset.w + ...
    (t-1)*imginfo.data.offset.t + ...
    (seq-1)*imginfo.data.offset.seq;

% determine file number and frame number within the file
idx = imginfo.data.numframes < frame;
fileno = sum(idx);
frameno = frame - imginfo.data.numframes(fileno);

% read image and convert it to output type
im = feval(datatype, imread([imginfo.data.dir filesep imginfo.data.filelist{fileno}], frameno));
 
% scale to range [0 1]
if strcmp(datatype,'double') || strcmp(datatype,'single')
  im = im/imginfo.camera.norm;
end

% ----------------------------------------------------------------------------

function [z, w, t, seq, datatype] = chkinput(varargin)

% default options
z = 1; w = 1; t = 1; seq = 1; datatype = 'uint16';

% run through input arguments
for I = 1:2:length(varargin) 
  assert(ischar(varargin{I}) && any(strcmp(varargin{I},{'z','w','t','seq','datatype'})), 'imgload:chkinput', 'Wrong property name.');
  eval([lower(varargin{I}) '=varargin{I+1};']);
end

%eof