function [IM,params,IMmap] = mapsim(IMseq,MaskOn,IMhom,params)
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

IMseq = double(cat(3,IMseq(:).IMseq));
MaskOn = double(cat(3,MaskOn(:).IMseq));

fc = params.fc;             	% Cut-off frequency, usually around 0.3
wmerg = params.wmerg;           % Spectral merging weight

[sy,sx,numseq] = size(IMseq);

% simulate OTF of the microscope
OTF = createOTF(sy,sx,2*fc);

% blur patterns
for ns = 1:numseq
    MaskOn(:,:,ns) = applyOTF(MaskOn(:,:,ns),OTF);
%     if ~mod(ns,3), figure; imshowpair(IMseq(:,:,ns),MaskOn(:,:,ns)); end
end

switch params.meth
    case 'CPU'
        alph = params.alph;             % Initial Alpha
        lamb = params.lamb;             % Lambda (Normalization Coefficient)
        maxiter = params.maxiter;       % Maximum number of iterations allowed
        thresh = params.thresh;         % Convergence Threshold
        IMmap = mapcore(IMseq,MaskOn,OTF,maxiter,numseq,lamb,alph,thresh);
    case 'CUDA'
        IMmap = MapcoreCudaProcess(double(IMseq),double(OTF),double(MaskOn));
end

% normalization MAP, ABSEXP
if params.vidnorm.enable
    [IMmap,params.vidnorm.mapmax,params.vidnorm.mapmin] = imnorm(IMmap, ...
        params.vidnorm.mapmax,params.vidnorm.mapmin);
    [IMhom,params.vidnorm.hommax,params.vidnorm.hommin] = imnorm(IMhom, ...
        params.vidnorm.hommax,params.vidnorm.hommin);
    scale = params.vidnorm.hommax;
else
    IMmap = imnorm(IMmap);
    [IMhom,scale] = imnorm(IMhom);
end

% noise reduction
lambda = max(0.01,estimateNoise(IMhom));
IMhom = imadjust(IMhom,[3*lambda,1],[0,1]);

% upsample before spectral merging
if params.upsample
    IMmapf = imfft(fftInterpolate(imfft(IMmap),2*size(IMmap)));
    IMhomf = imfft(fftInterpolate(imfft(IMhom),2*size(IMhom)));
    sx = 2*sx; sy = 2*sy;
else
    IMmapf = imfft(IMmap);
    IMhomf = imfft(IMhom);
end

% Spectral merging
s = min(sx,sy);
fwhm = fc*s;
sigma = fwhm/(2*sqrt(2*log(2)));

m2 = double(spectralMask(s,s,fc));
g = fspecial('gaussian',2*round(fwhm),sigma);
m2 = imfilter(m2,g);
m2 = imresize(m2,[sy,sx]);
m2 = m2./max(m2(:));
m1 = imcomplement(m2);

temp = wmerg*IMmapf.*m1 + (1-wmerg)*IMhomf.*m2;
IM = real(imifft(temp));

% Apply apodization
IM = apodize(IM,sx,sy,fc,1);

% Normalize output image
if params.vidnorm.enable
    [IM,params.vidnorm.msmmax,params.vidnorm.msmmin] = imnorm(IM,...
        params.vidnorm.msmmax,params.vidnorm.msmmin);
else
    IM = imnorm(IM);
end
IM = scale*IM;

end
