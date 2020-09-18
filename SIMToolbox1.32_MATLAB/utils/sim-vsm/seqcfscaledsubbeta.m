function IM = seqcfscaledsubbeta(IMseq, MaskOn)
% Confocal image computed using scaled subtraction scheme with beta correction scheme
%
%   IM = seqcfscaledsubbeta(IMseq, MaskOn)
%
% Input/output arguments:
%
%   IMseq  ... [m x n x numseq]  sequence of images stored in a matrix
%   MaskOn ... [m x n x numseq]  mask sequence
%   IM     ... [m x n]  final image computed from image sequence
%
% Example:
%
%   datadir = 'data\polen\pollen 100X 1.45NA';
%   imginfo = imginfoinit(datadir);
%   ptrninfo = ptrnopen(ptrndirinfo(datadir));
%   calinfo = calload([datadir '\..\calibration\calibration_LIN.yaml']);
%   IMseq = seqload(imginfo, 'z', 2, 'datatype','single');
%   IMseq = seqstriperemoval(IMseq);
%   MaskOn = ptrnmaskprecompute(imginfo, ptrninfo, calinfo, 'runningorder', 1, 'sigma', 1.3);
%   IM = seqcfscaledsubbeta(IMseq, MaskOn);
%   figure; imagesc(IM); axis off image; colormap gray;
%
% See also seqload, seqwf, seqcfmaxmin, seqcfhomodyne, seqcfscaledsub

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

if nargin < 1
  IM.mfile = fileparts_name([mfilename('fullpath') '.m']);
  IM.name = 'Scaled subtraction B';
  IM.id = 'maskbeta';
  IM.applymask = 1;
  return;
end

IM = seqsubseq(@cfscaledsubbeta, IMseq, MaskOn);

function IM = cfscaledsubbeta(IMseq, MaskOn)

numseq = size(IMseq,3);
[sumInMon,  sumMon]  = seqopsummaskon(IMseq, MaskOn);
[sumInMoff, sumMoff] = seqopsummaskoff(IMseq, MaskOn);
sum2Mon = sumMon.^2;

% frame by frame processing to save memmory
sumMon2 = 0;
for I = 1:numseq
  Mon = MaskOn(:,:,I);
  sumMon2 = sumMon2 + Mon.^2;
end    

beta = (numseq*sumMon - sum2Mon) ./ (numseq*sumMon2 - sum2Mon);
IM = beta .* (sumInMon./sumMon - sumInMoff./sumMoff);

%eof