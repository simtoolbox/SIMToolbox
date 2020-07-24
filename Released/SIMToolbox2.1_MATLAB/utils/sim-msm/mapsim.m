function [IM, varargout] = mapsim(IMseq,MaskOn,IMhom,params)
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

switch params.meth
    case 'CPU'
        IMmap = mapcore(IMseq,MaskOn,OTF,fc,hndlwb);
    case 'CUDA'
        alph = params.cuda.alph;
        lamb = params.cuda.lamb;
        maxiter = params.cuda.maxiter;
        thresh = params.cuda.thresh;
        
        IMmap = MapcoreCuda(IMseq,OTF,MaskOn,[maxiter,numseq,lamb,alph,thresh,fc]);
end

% normalization MAP
if params.vidnorm.enable
    [IMmap,params.vidnorm.mapmax,params.vidnorm.mapmin] = imnorm(IMmap, ...
        params.vidnorm.mapmax,params.vidnorm.mapmin);
else
    IMmap = imnorm(IMmap);
end

IMmapf = fftshift(fft2(IMmap));
if params.upsample
    IMmapf = fftshift(fft2(fftshift(fftInterpolate(IMmapf,size(IMmapf)*2))));
end

% normalization ABSEXP
if params.vidnorm.enable
    [IMhom,params.vidnorm.hommax,params.vidnorm.hommin] = imnorm(IMhom, ...
        params.vidnorm.hommax,params.vidnorm.hommin);
    scale = params.vidnorm.hommax;
else
    [IMhom,scale] = imnorm(IMhom);
end

% noise reduction
lambda = max(0.01,estimateNoise(IMhom));
IMhom = imadjust(IMhom,[3*lambda,1],[0,1]);

IMhomf = fftshift(fft2(IMhom));
if params.upsample
    IMhomf = fftshift(fft2(fftshift(fftInterpolate(IMhomf,size(IMhomf)*2))));
    [sy,sx] = size(IMhomf);
end

% Spectral merging
fwhm = fc*sx;
sigma = fwhm/(2*sqrt(2*log(2)));

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
if params.vidnorm.enable
    [IM,params.vidnorm.msmmax,params.vidnorm.msmmin] = imnorm(IM, ...
        params.vidnorm.msmmax,params.vidnorm.msmmin);
else
    IM = imnorm(IM);
end
IM = scale*IM;

varargout{1} = params;
varargout{2} = IMmap;

if ishandle(hndlwb), delete(hndlwb); end

end
