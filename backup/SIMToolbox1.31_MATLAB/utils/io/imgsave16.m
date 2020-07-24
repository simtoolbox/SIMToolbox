function imgsave16(IM, filename)
% Save image to a 16bit TIFF file.
% Note that image is appended if filename exists.
%
%   imgsave16(IM, filename)
%
% Input arguments:
%
%   IM         ...   [m x n]   image
%   filename   ...   [string]  file name
%
% See also imgsave32

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

imwrite(uint16(round(IM)), filename, 'Compression','none', 'WriteMode','append');