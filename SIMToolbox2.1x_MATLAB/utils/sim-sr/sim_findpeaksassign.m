function ptrn = sim_findpeaksassign(imginfo,ptrninfo,calinfo,cfg,hndlwb)
% Order of illumination phases influences sign of extracted harmonic components.
% It is therefore difficult to tell on which side of the image center lies the peak.
% 
% Position of the peaks and their order needs to be determined only once for the whole data set!

% Copyright © 2009-2015 Pavel Krizek
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

cfg.plotpeaks = 0;   % don't show peaks

num = length(cfg.ptrn.angles);

progressbarGUI(hndlwb,0,'Extracting pattern information ...');

% load SIM sequence
tt = 1:min(imginfo.image.size.t,5);
z_cnt = ceil(imginfo.image.size.z/2);
zz = z_cnt-5:z_cnt+5;
zz(zz<1|zz>imginfo.image.size.z) = [];
TZ = length(tt)*length(zz); ktz = 1;
for t = tt
    for z = zz
        seqtmp = seqload(imginfo,'t',t,'z',z,'offset',-cfg.ptrn.offset,'datatype','single');
        if z>zz(1), seq = 0.5.*(seq+seqtmp); else, seq = seqtmp; end
        progressbarGUI(hndlwb,ktz/(TZ+num));
    end
    ktz = ktz+1;
end

% concatenate ro + settings
[seq, ptrn] = seq2subseq(seq,ptrninfo,cfg.ptrn.ro);
ptrn = structcat(ptrn, cfg.ptrn.angles);
% padding and smoothing of image borders to remove the cross in FFT
seq = seqremovemean(seq);
seq = seqpadsmooth(seq,cfg.sim.smoothpadsize,cfg.sim.smoothsigma);
% compute FFT
seq = seqfft2(seq);
% compute expanded spectra for all illumination angles
seq = sim_extract(seq,ptrn);

% position of peaks will stored in ptrn
[ptrn(:).pos] = deal([]);
[ptrn(:).estangle] = deal([]);
[ptrn(:).phsoff] = deal([]);

for I = find([cfg.ptrn.angles.enable])
    
    % load image data
    siz = size(seq(I).IMseqFFT(:,:,1));
    
    % find absolute position of peaks (in pixels) with respect to the image center
    [peakpos,angl,~,phsoff] = sim_findpeaks(seq(I).IMseqFFT,cfg.sim.spotfindermethod,ptrn(I),calinfo,cfg,I);
    
    % find direction of harmonic components based on the first harmonic; higher components are on the same side with respect to image center
    comp = [seq(I).Sk.comp];
    S = seq(I).Sk(comp == 1).S;                % extracted spectra corresponding to positive first harmonics
    cnt = ceil((siz+1)/2);                     % image center
    pos = round([peakpos(1).y, peakpos(1).x]); % position of the peak for the first harmonic
    box = -1:1;                                % box around the peak
    
    % test intensity values for ctn+pos and cnt-pos in a box
    if isempty(pos)
        waitfor(msgbox('Extraction failed. Please check "Find peaks" dialog menu'));
        progressbarGUI(hndlwb,0,'');
        ptrn = [];
        return;
    end
    if mean(m2c(abs(S(box+cnt(1)+pos(1),box+cnt(2)+pos(2))))) > mean(m2c(abs(S(box+cnt(1)-pos(1),box+cnt(2)-pos(2)))))
        direction = 1;
    else
        direction = -1;
    end
    
    % assign peak position and normalize it to image size
    pos = cell(1,ptrn(I).numharmon);
    for harmon = 1:ptrn(I).numharmon
        pos{harmon} =  direction*[peakpos(harmon).y, peakpos(harmon).x]./siz;
    end
    
%     % estimate phase of the pattern
%     if ~strcmp(cfg.sim.spotfindermethod.type,'calibration')
%         %%%%%%%%%%%% estimate phase of the pattern (0) %%%%%%%%%%%%%%%%%%%%%%%%
%         % Original phase estimation by Krizek
%         imft = fft2(imftabs);
%         peakValue = imft(round(cnt(2)+peakpos(1).x),round(cnt(1)+peakpos(1).y)); % peak value in fourier space for the first harmonic
%         phase = atan(imag(peakValue)./real(peakValue))/2;
%         
%         %%%%%%%%%%%% estimate phase of the pattern (1) %%%%%%%%%%%%%%%%%%%%%%%%
%         % (2009) Shroff S. A. - Phase-shift estimation in sinusoidally illuminated
%         %                       images for lateral superresolution
%         % peak value in fourier space for the first harmonic
%         % implemented by Jakub Pospisil (2018)
%         peakValue = squeeze(seq(I).IMseqFFT(round(cnt(1)+peakpos(1).y),round(cnt(2)+peakpos(1).x),:));
%         phasSort = sort(angle(peakValue) - 2*pi*(0:ptrn(I).num-1)'/ptrn(I).num);
%         phasDiff = diff(phasSort);
%         phas = mean(phasSort(find(min(phasDiff)):find(min(phasDiff))+1));
%         phas = mod(phas+2*pi*(0:ptrn(I).num-1)'/ptrn(I).num,2*pi);
%         
%         %%%%%%%%%%%% estimate phase of the pattern (2) %%%%%%%%%%%%%%%%%%%%%%%%
%         % (2013) Wicker K. - Non-iterative determination of pattern phase in
%         %                    structured illumination microscopy using
%         %                    auto-correlations in Fourier space
%         phas = sim_getphase(seq(I).IMseqFFT,peakpos(1).x,peakpos(1).y,cfg);
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         %%% for testing
%         checkPhase(angl,phasTmp,pos,ptrn(I),seq(I));
%         figure; plot(phas); hold on; plot(2*pi*(0:ptrn(I).num-1)'/ptrn(I).num);
%         %%% for testing
%     end
    
    ptrn(I).phsoff = phsoff;
    ptrn(I).estangle = angl;
    ptrn(I).pos =  pos;
    
    progressbarGUI(hndlwb,(TZ+I)/(TZ+num));
end
progressbarGUI(hndlwb,1,'Extraction successfully done');

%eof