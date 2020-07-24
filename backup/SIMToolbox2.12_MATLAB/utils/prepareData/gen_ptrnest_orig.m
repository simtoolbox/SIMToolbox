function [ptrn, IM] = gen_ptrnest(ptrn, imsize,angle,numphases)
% Generate a pattern sequence
%
%  [ptrn, IM] = gen_ptrn(ptrn, imsize,numphases,numangles)
%
%   ptrn.*         ... pattern paramerers
%
%
%   ptrn.*         ... other pattern paramerers ....
%   ptrn.images    ... cell with image names
%   IM             ... [m x n x t] image sequence

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


% Generate sinusoidal patterns
[xx,yy] = meshgrid(1:imsize(1),1:imsize(2));

%     freq = norm(ptrn(itheta).pos{end}); % estimate pattern frequency from the peak of the highest harmonics
    fc = 0.5;
    freq = 0.2*2*pi*(fc*(imsize(1)/2))/imsize(1);
    
    phases =  2*pi*(0:numphases-1)/numphases;
    pattern = zeros(imsize(1),imsize(2),numphases);
    
    for iphase=1:numphases

        k=rotxy(angle)*[freq; 0];
        kx = k(1); 
        ky = k(2);

        temp = (1-cos(kx*xx+ky*yy+phases(iphase)));
        
        temp = temp./max(temp(:));
        temp(temp<(1-1/numphases))=0;
        temp(temp>0)=1;
        pattern(:,:,iphase) = temp;  
        
    end

    MaskOn.IMseq = pattern;

sum1 = sum(MaskOn.IMseq,3)-1;
for ii = 1:numphases 
ispat(:,:,ii) = sum1.*MaskOn.IMseq(:,:,ii);
end

for ii = 1:imsize(1)
    for jj = 1:imsize(2)

    isone = find(ispat(ii,jj,:)); 
    if ~isempty(isone) 
    isone = isone(round(1 + (length(isone)-1)*rand(1)));

    MaskOn.IMseq(ii,jj,[1:isone-1, isone+1:numphases]) = 0;
    end
    end
end

% check pattern sequence for homogenity
IM = cat(3,MaskOn(:).IMseq);
imsum = sum(IM,3);
if any(mean(imsum(:)) ~= imsum)
  fprintf('\n %s - pattern sequence is not homogenous', ptrn.id);
  figure(1); imagesc(imsum); axis ij off; title(ptrn.images{1}(9:end-4));
  drawnow;
end

% generate images
ptrn.images = cell(1,numphases);
phasenum = 1:numphases;
ptrn.num = numphases;
for I = 1:ptrn.num
  ptrn.images{I} = sprintf('ptrn%03d_sin%.0fo-phase%d-%02d.bmp', I, ptrn.angle, phasenum(I), ptrn.num);
end

end

function a=rotxy(angle)
a=[cos(angle)  -sin(angle); 
    sin(angle)  cos(angle)];
end


