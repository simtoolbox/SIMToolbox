clear; clc;

addpath(genpath('utils'));
load('testing_fc.mat');
savename = 'testing_fc.tif';
if exist(savename,'file'), delete(savename); end

params.upsample = 0;
alph = params.alph;             % Initial Alpha
lamb = params.lamb;             % Lambda (Normalization Coefficient)
maxiter = params.maxiter;       % Maximum number of iterations allowed
thresh = params.thresh;         % Convergence Threshold
% wmerg = params.wmerg;           % Spectral merging weight

[sy,sx,numseq] = size(IMseq);

wmerg_seq = 0.9; %0.80:0.05:0.95;
fc_seq = 0.2:0.01:0.3;  % Cut-off frequency, usually around 0.3
for wmerg = wmerg_seq
    for fc = fc_seq
        % simulate OTF of the microscope
%         OTF = createOTF(sy,sx,0.6*fc);
        OTF = createOTF(sy,sx,0.5*fc);
        
        % blur patterns
        for ns = 1:numseq
%             MaskOnB(:,:,ns) = applyOTF(MaskOn(:,:,ns),OTF);
            MaskOnB(:,:,ns) = MaskOn(:,:,ns);
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
                %%% AFTER PROCESSING ALL ZPLANES %%%
                MapcoreCudaFinish();
                %%% AFTER PROCESSING ALL ZPLANES %%%
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
        
%         % upsample before spectral merging
%         if params.upsample
%             IMmapf = seqfft2(fftInterpolate(seqfft2(IMmap),2*size(IMmap)));
%             IMhomf = seqfft2(fftInterpolate(seqfft2(IMhom),2*size(IMhom)));
%             sx = 2*sx; sy = 2*sy;
%         else
            IMmapf = seqfft2(IMmap);
            IMhomf = seqfft2(IMhom);
%         end
        
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
        IM = real(seqifft2(temp));
        
        if params.upsample
            IM = fftInterpolate(seqfft2(IM),2*size(IM));
            % Apply apodization
            IM = apodize(IM,2*sx,2*sy,fc,1);
        else
            % Apply apodization
            IM = apodize(IM,sx,sy,fc,1);
        end
        
        % Normalize output image
        if params.vidnorm.enable
            [IM,params.vidnorm.msmmax,params.vidnorm.msmmin] = imnorm(IM,...
                params.vidnorm.msmmax,params.vidnorm.msmmin);
        else
            IM = imnorm(IM);
        end
%         IM = 2^15*IM./max(IM(:));
        
        imgsave32(IM,savename);
        fprintf('fc: %1.2f, wm: %1.2f\n',fc,wmerg);
    end
end

% figure(43); imagesc(IM); axis equal;
