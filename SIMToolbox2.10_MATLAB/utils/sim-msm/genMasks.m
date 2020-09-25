function MaskOn = genMasks(seq,ptrn)
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

numangles = numel(seq);

% Generate sinusoidal patterns for mapsim processing
hndlwb = waitbar(0,'Initializing ...','Name','Generating illumination masks ...','Tag','WaitBar','WindowStyle','modal');

[siz(1),siz(2),~] = size(seq(1).IMseq);
[xx,yy] = meshgrid(1:siz(2),1:siz(1));

angles = cat(1,ptrn(:).estangle);
MaskOn = struct('angle',[],'IMseq',[]);
for itheta = 1:numangles
    waitbar(itheta/(2*numangles), hndlwb, 'Generating illumination masks ...');
    
    [~,~,numphases] = size(seq(itheta).IMseq);
    fi =  2*pi*(0:numphases-1)/numphases;
    phases = repmat(fi,numangles,1);
    pattern = zeros(siz(1),siz(2),numphases);
    
    % estimate pattern frequency from the peak of the highest harmonics
    freq = norm(ptrn(itheta).pos{end});
    
    for iphi = 1:numphases
        k = rotxy(angles(itheta))*[freq; 0];
        kx = k(1);
        ky = k(2);
        
        temp = (1-cos(kx*xx+ky*yy+phases(itheta,iphi)));
        
        temp = temp./max(temp(:));
        temp(temp<(1-1/numphases)) = 0;
        temp(temp>0) = 1;
        pattern(:,:,iphi) = temp;
    end
    MaskOn(itheta).angle = ptrn(itheta).angle;
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

if ishandle(hndlwb), delete(hndlwb); end
end

function a = rotxy(angle)
a = [cos(angle)  -sin(angle);
    sin(angle)	cos(angle)];
end
