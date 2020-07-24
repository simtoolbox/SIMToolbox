clear; clc;

addpath(genpath('utils'));
load('data.mat');
savename = 'data.tif';
if exist(savename,'file'), delete(savename); end

alph = params.alph;             % Initial Alpha
lamb = params.lamb;             % Lambda (Normalization Coefficient)
maxiter = params.maxiter;       % Maximum number of iterations allowed
thresh = params.thresh;         % Convergence Threshold
% wmerg = params.wmerg;           % Spectral merging weight

[sy,sx,numseq] = size(IMseq);

wmerg_seq = 0.85;%:0.01:0.9;
fc_seq = 0.25:0.01:0.40;  % Cut-off frequency, usually around 0.3
for wmerg = wmerg_seq
    for fc = fc_seq
        % simulate OTF of the microscope
        OTF = createOTF(sy,sx,2*fc);
        
        % blur patterns
        for ns = 1:numseq
            MaskOnB(:,:,ns) = applyOTF(MaskOn(:,:,ns),OTF);
            %         if ~mod(ns,3), figure; imshowpair(IMseq(:,:,ns),MaskOn(:,:,ns)); end
        end
        
        %%% for testing
        % ang = 3; ph = 2;
        % figure;
        % an = 1*ang-ph+1; subplot(221), imshowpair(IMseq(:,:,an),MaskOn(:,:,an));
        % an = 2*ang-ph+1; subplot(222), imshowpair(IMseq(:,:,an),MaskOn(:,:,an));
        % an = 3*ang-ph+1; subplot(223), imshowpair(IMseq(:,:,an),MaskOn(:,:,an));
        % an = 4*ang-ph+1; subplot(224), imshowpair(IMseq(:,:,12),MaskOn(:,:,12));
        
        switch params.meth
            case 'CPU'
                IMmap = mapcore(IMseq,MaskOnB,OTF,maxiter,numseq,lamb,alph,thresh);
            case 'CUDA'
                %%% INIT CUDA ONCE HERE %%%
                MapcoreCudaPrepare([sx,sy,numseq,maxiter,lamb,alph,thresh,fc]);
                %%% INIT CUDA ONCE HERE %%%
                IMmap = MapcoreCudaProcess(double(IMseq),double(OTF),double(MaskOnB));
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
        IM = 2^15*IM./max(IM(:));
        
        %%% AFTER PROCESSING ALL ZPLANES %%%
        MapcoreCudaFinish();
        %%% AFTER PROCESSING ALL ZPLANES %%%
        imgsave16(IM,savename);
        fprintf('fc: %1.2, wm: %1.2\n',fc,wmerg);
    end
end

figure(43); imagesc(IM); axis equal;
