function stack = loadtif(fname)
% load a stack of images from a multiple tif file
% fname is a string containing path and name of the file to be loaded

% Copyright © 2015 Tomas Lukes, lukestom@fel.cvut.cz
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

fileinfo = imfinfo(fname);
Nframes=length(fileinfo);

sx=fileinfo(1).Width;
sy=fileinfo(1).Height;
stack=zeros(sy,sx,Nframes,'uint16');

TifLink = Tiff(fname, 'r');

fig = waitbar(0,'Loading stack ...','Name','Loading ...','Tag','WaitBar','WindowStyle','modal');

for ii=1:Nframes
   fig=waitbar(ii/Nframes,fig);
   TifLink.setDirectory(ii);
   stack(:,:,ii)=TifLink.read();
end
TifLink.close();
delete(fig);