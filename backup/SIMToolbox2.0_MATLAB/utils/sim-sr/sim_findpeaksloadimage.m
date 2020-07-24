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

function im = sim_findpeaksloadimage(imginfo, ptrn, cfg)

switch cfg.sim.spotfindermethod.type
  case 'calibration'
    zidx = round(imginfo.image.size.z/2); % just one image for preview
  case 'spotfinder'
    zidx = 1:imginfo.image.size.z; % use average zstack projection of abs(fft(IMseq)) to find peak position in FFT
  otherwise
    error('sim:findpeaks:method','Unknown method to find peaks.');
end

%  compute FFT spectra for chosen image/stack
im = log(zstackfft(imginfo, ptrn.offset+1, 1, zidx, cfg.sim.smoothpadsize, cfg.sim.smoothsigma));

% ----------------------------------------------------------------------------

function IMfft = zstackfft(imginfo, seq, t, zidx, smoothpadsize, smoothsigma)
% average FFT through the z-stack
IMfft = 0; 
for I = zidx
  % load data
  IM = imgload(imginfo,'t',t,'seq',seq,'z',I,'datatype','single');
  % remove ugly cross in FFT
  IM = seqremovemean(IM);
  IM = seqpadsmooth(IM, smoothpadsize, smoothsigma);
  % compute FFT magnitude
  IMfft = IMfft + abs(seqfft2(IM));
end
IMfft = IMfft/length(zidx);

