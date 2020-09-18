function IM = imgzload(imginfo,varargin)
% Load a z-stack from a multilayer TIFF
%
%   im = imgzload(imginfo, 'PropertyName', PropertyValue, ...)
%
% Input/output arguments:
%
%   imginfo        ... [struct]  image stack information created by imginfoinit
%   IM             ... [m x n x numz] matrix with an image
%
%   Property Names:
%     'w'          ... [scalar]  channel cordinate (default 1)
%     't'          ... [scalar]  time coordinate (default 1)
%     'seq'        ... [scalar]  sequence coordinate (default 1)
%     'datatype'   ... [string]  e.g., 'single', 'double', ... (default 'uint16')
%
% Example:
%
%   imginfo = imginfoinit(filename);
%   IM = imgzload(imginfo,'w',1,'t',5,'datatype','double');
%
% See also imginfoinit, imgload

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

[w, t, seq, datatype] = chkinput(varargin{:});

IM = zeros([imginfo.image.size.y,imginfo.image.size.x,imginfo.image.size.z], datatype);
for I = 1:imginfo.image.size.z
  IM(:,:,I) = imgload(imginfo,'w',w,'t',t,'seq',seq,'z',I,'datatype',datatype);
end
    
% ----------------------------------------------------------------------------

function [w, t, seq, datatype] = chkinput(varargin)

% default options
w = 1; t = 1; seq = 1; datatype = 'uint16';

% run through input arguments
for I = 1:2:length(varargin)
  assert(ischar(varargin{I}) && any(strcmp(varargin{I},{'w','t','seq','datatype'})), 'imgload:chkinput', 'Wrong property name.');
  eval([lower(varargin{I}) '=varargin{I+1};']);
end

%eof