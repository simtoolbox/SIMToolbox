function ptrn = sim_findpeaksassign(imginfo, ptrninfo, calinfo, Z, cfg)
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

% load SIM sequence
[seq, ptrn] = seq2subseq(seqload(imginfo, 'z',Z,'offset',-cfg.ptrn.offset,'datatype','double'), ptrninfo, cfg.ptrn.ro);
ptrn = structcat(ptrn, cfg.ptrn.angles); % concatenate ro + settings

% padding and smoothing of image borders to remove the cross in FFT
seq = seqpadsmooth(seq, cfg.sim.smoothpadsize, cfg.sim.smoothsigma);

% compute FFT
seq = seqfft2(seq);
               
% compute expanded spectra for all illumination angles
seq = sim_extract(seq, ptrn);

% position of peaks will stored in ptrn
ptrn().pos = [];
ptrn().estangle = [];
ptrn().phase = [];

for I = 1:length(ptrn)
  
  % load image data
  im = sim_findpeaksloadimage(imginfo, ptrn(I), cfg);
  siz = size(im);
  
  % find absolute position of peaks (in pixels) with respect to the image center
  [peakpos,angle] = sim_findpeaks(im, cfg.sim.spotfindermethod, ptrn(I), calinfo, cfg);
  
  % find direction of harmonic components based on the first harmonic; higher components are on the same side with respect to image center
  comp = [seq(I).Sk.comp];
  S = seq(I).Sk(comp == 1).S;                % extracted spectra corresponding to positive first harmonics  
  cnt = ceil((siz+1)/2);                     % image center
  pos = round([peakpos(1).y, peakpos(1).x]); % position of the peak for the first harmonic
  box = -1:1;                                % box around the peak
  
  % test intensity values for ctn+pos and cnt-pos in a box
  if isempty(pos)
      msgbox('Peaks were not detected. Please check "Find peaks" dialog menu');
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
  
  % estimate phase of the pattern
  imft = fft2(im);
  peakValue = imft(round(cnt(2)+peakpos(1).x),round(cnt(1)+peakpos(1).y)); % peak value in fourier space for the first harmonic
  phase = atan(imag(peakValue)./real(peakValue))/2;

  ptrn(I).pos =  pos;
  ptrn(I).estangle = angle;
  ptrn(I).phase = phase;  
end


%eof