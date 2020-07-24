function IM = mapsim(IMseq, MaskOn,IMhom,params)
% 
% 
%   IM = mapsim(IMseq,MaskOn,IMhom,params)
% 
% Input/output arguments:
% 
%   IMseq  ... [m x n x numseq]  sequence of images stored in a matrix
%   MaskOn ... [m x n x numseq]  mask sequence
%   IMhom ... homodyne detection image for spectral merging
%   params ... parameters for MAP-SIM reconstruction
%   IM     ... [m x n]  final image computed from image sequence
% 

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

hndlwb = waitbar(0,'MAP-SIM processing ...','Name','MAP-SIM processing ...','Tag','WaitBar','WindowStyle','modal');

IMseq = double(cat(3,IMseq(:).IMseq));
MaskOn = double(cat(3,MaskOn(:).IMseq));

fc = params.fc;	% cut off frequency, usually around 0.3;
wmerg = params.wmerg;

[sy,sx,numseq] = size(IMseq);

% simulate OTF of the microscope
OTF = createOTF(sy,sx,fc);

% blur patterns
for i = 1:numseq
    MaskOn(:,:,i) = applyOTF(MaskOn(:,:,i),OTF);
end

% MAP-SIM reconstruction
IMmap = mapcore(IMseq, MaskOn, OTF,fc,hndlwb);

% Spectral merging
fwhm = fc*sx;
sigma = fwhm/(2*sqrt(2*log(2)));

IMmap = imnorm(IMmap);
IMmapf = fftshift(fft2(IMmap));
if params.upsample == 1
IMmapf = fftshift(fft2(fftshift(fftInterpolate(IMmapf,size(IMmapf)*2))));
end

scale = max(IMhom(:));
IMhom = imnorm(IMhom);
lambda = max(0.01,estimateNoise(IMhom));
IMhom = imadjust(IMhom,[3*lambda,1],[0,1]);

IMhomf = fftshift(fft2(IMhom));
if params.upsample
    IMhomf = fftshift(fft2(fftshift(fftInterpolate(IMhomf,size(IMhomf)*2))));
    [sy,sx] = size(IMhomf);
end

m2 = double(spectralMask(sx,sy,fc));
g = fspecial('gaussian',[2*round(fwhm), 2*round(fwhm)],sigma);
m2 = imfilter(m2,g);
m2 = m2./max(m2(:));
m1 = imcomplement(m2);

temp = wmerg*IMmapf.*m1 + (1-wmerg)*IMhomf.*m2;
IM = real(ifft2(ifftshift(temp))); 

waitbar(1, hndlwb, 'MAP-SIM processing ...');
% Apply apodization

IM = apodize(IM,sx,sy,fc,1);

% Normalize output image
IM = scale*imnorm(IM);

if ishandle(hndlwb), delete(hndlwb); end

end

function m = spectralMask(sx,sy,fc,subbcg)
if nargin < 4
    subbcg = 0;
end
fx = linspace(-1,1,sx);
fy = linspace(-1,1,sy);
[Fx,Fy] = meshgrid(fx,fy);

[THETA,RHO]=cart2pol(Fx,Fy); 

if subbcg ==0 
    m = RHO<fc; 
else
    m = RHO>fc & ...
((abs(THETA) > (10/180)*pi & abs(THETA) <(80/180)*pi) |...
 (abs(THETA) > (100/180)*pi & abs(THETA) <(170/180)*pi));
end
end

function OTF = createOTF(sx,sy,fc)

fx = linspace(-1,1,sx);
fy = linspace(-1,1,sy);
[Fy,Fx] = meshgrid(fy,fx);

[THETA,RHO]=cart2pol(Fx,Fy); 

H = 1/pi*(2*(acos(RHO./fc)) - sin(2*acos(RHO/fc)));

OTF = abs(H);
OTF(RHO > fc) = 0;

end

function [im_out] = applyOTF(im_in, OTF)
im_in = double(im_in);

IM = fftshift(fft2(im_in));
im_out = abs(ifft2(ifftshift(IM.*OTF)));
end

function IMmap = mapcore(IMseq, MaskOn, OTF, fc,hndlwb)

maxIter = 5;
lambda = 0.0001;

[sy, sx, numseq] = size(IMseq);

IMmap = sum(IMseq,3); % first estimate - widefield image

for ii = 1:maxIter
    waitbar(ii/(maxIter+1), hndlwb, 'MAP-SIM processing ...');
    grad1=zeros(sy,sx);
    for i = 1: numseq
        D1 = MaskOn(:,:,i);
        grad1 = grad1+ D1.*applyOTF((applyOTF(D1.*IMmap,OTF) - (IMseq(:,:,i).*D1)),OTF); 
    end

    % derivation of the "prior knowledge"
    grad2 = zeros(sy,sx);

    for i = 2 : sy-1
        for j = 2 : sx-1
            grad2(i,j) = 2*( 4*IMmap(i,j)-IMmap(i,j-1)-IMmap(i,j+1)-IMmap(i-1,j)-IMmap(i+1,j) );
        end
    end
    
    grad = grad1 + lambda * grad2;

    % Barzilai-Borwein method
    if ii == 1
        alpha = 0.5; % initial alpha
    else
        y = grad - grad_old;
        s = IMmap - IMmap_old;
        alpha = (y(:)'*s(:))/(y(:)'*y(:)); % new estimate of alpha
    end
    
    if alpha <= 0
        break;
    end
    
    res(ii) = sum(alpha*grad(:).^2);
    if ii > 1
    thresh = res(ii)/res(ii-1); 
    end
    IMmap_old = IMmap;
        
    IMmap = double(IMmap- alpha * grad); 
    grad_old = grad;

    % Break after first agressive step towards minimum
    if ii > 1 && thresh < 0.01
        break;
    end
end
end

function IM=apodize(IM,sx,sy,fc,subbcg)
omega = 2*fc;

[k_x, k_y]=meshgrid(-sx/2+1:sx/2,-sy/2+1:sy/2);
k_r = sqrt(k_x.^2+k_y.^2);
k_max = omega*max(k_r(:));
apdf = cos(pi*k_r/(2*k_max));
indi =  k_r > k_max ;
apdf(indi) = 0;

IMf = fftshift(fft2(IM));

if subbcg ==1
    IMnoise = abs(IMf.*imcomplement(spectralMask(sx,sy,omega,1)));
    IMnoise = mean(IMnoise(:));
    IMfa = abs(IMf) - IMnoise; % subtract noise background
    IMfa(IMfa<0) = 0; 
    IMf = IMfa.*exp(1i*angle(IMf)); 
end
IMf = IMf.*apdf; % apodization

IM = real(ifft2(ifftshift(IMf)));
IM(IM<0) = 0;

end

function IM = imnorm(IM)
IM = IM./max(IM(:));
IM  = IM - min(IM(:));
IM = IM./max(IM(:));
end

function lambda=estimateNoise(im)

[sy, sx]=size(im);
im=double(im);

% compute sum of absolute values of Laplacian
M=[1 -2 1; -2 4 -2; 1 -2 1];
lambda=sum(sum(abs(conv2(im, M))));

% properly scale sigma
lambda=lambda*sqrt(0.5*pi)./(6*(sx-2)*(sy-2));
end



