function MaskOn = genMasks(imginfo,ptrn,hndlwb)
% Generate illumination masks using estimated pattern parameters
%
%
% Input/output arguments:
%
%   seq     ... [m x n x numseq]
%   ptrn	... [numangles x numphases]
%   MaskOn  ...

% Copyright © 2014-2015 Tomas Lukes, lukestom@fel.cvut.cz
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

% Generate sinusoidal patterns for mapsim processing
% hndlwb = waitbar(0,'Initializing ...','Name','Generating illumination masks ...','Tag','WaitBar','WindowStyle','modal');
progressbarGUI(hndlwb,0,'Creating illumination mask ...','cyan');

sx = imginfo.image.size.x;
sy = imginfo.image.size.y;
[xx,yy] = meshgrid(1:sx,1:sy);

nAngles = sum([ptrn.enable]); th = 1;
MaskOn = struct('angle',[],'IMseq',[]);
for itheta = find([ptrn.enable])
%     waitbar(itheta/(2*numangles), hndlwb, 'Generating illumination masks ...');
    numphases = ptrn(itheta).num;
    fi = ptrn(itheta).phsoff+2*pi*(0:numphases-1)/numphases;
    pattern = zeros(sy,sx,numphases);
    
    % estimate pattern frequency from the peak of the 1st harmonics
    freq = norm(ptrn(itheta).pos{1});
    
    for iphi = 1:numphases
        k = rotxy(ptrn(itheta).estangle)*[freq; 0];
        kx = k(1);
        ky = k(2);
        
        temp = sin(2*pi*kx*xx+2*pi*ky*yy+fi(iphi));
%         temp(temp<0) = 0;
%         temp(temp>0) = 1;
        pattern(:,:,iphi) = (temp+1)./(2*numphases);
        
        progressbarGUI(hndlwb,(iphi+(th-1)*numphases)/(numphases*nAngles));
    end
    th = th + 1;
    MaskOn(itheta).angle = ptrn(itheta).angle;
    MaskOn(itheta).num = numphases;
    MaskOn(itheta).IMseq = pattern;
end

% sum of the patterns for each angle has to lead to homegeneous illumination
% for kk = 1:numangles
%     waitbar((itheta+kk)/(2*numangles), hndlwb, 'Generating illumination masks ...');
%     sum1 = sum(MaskOn(kk).IMseq,3)-1;
%     
%     numphases = size(seq(kk).IMseq,3);
%     ispat = nan(siz(1),siz(2),numphases);
%     for k = 1:numphases
%         ispat(:,:,k) = sum1.*MaskOn(kk).IMseq(:,:,k);
%     end
%     
%     for m = 1:siz(1)
%         for n = 1:siz(2)
%             isone = find(ispat(m,n,:));
%             if ~isempty(isone)
%                 isone = isone(round(1 + (length(isone)-1)*rand(1)));
%                 
%                 MaskOn(kk).IMseq(m,n,[1:isone-1, isone+1:numphases]) = 0;
%             end
%         end
%     end
% end

% if ishandle(hndlwb), delete(hndlwb); end

progressbarGUI(hndlwb,1,'Illumination mask is successfully created.','cyan');
end

function a = rotxy(angle)
a = [cos(angle)  -sin(angle);
    sin(angle)	cos(angle)];
end
