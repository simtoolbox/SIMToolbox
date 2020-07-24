function imginfo = iq2getinfo(iqinf)
% Extract basic information from IQ protocol
%
%   imginfo = iq2getinfo(iqinf)
%
% Input/output arguments:
%
%   iqinf    ... [struct]  information created by iq2parse
%   imginfo  ... [struct]  basic information about the image sequence
%
% See also iq2parse, imginfoinit

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

assert(isfield(iqinf,'Header') && isfield(iqinf,'ProtocolDescription'), 'iq2getinfo:corrupted','IQ2 protocol corrupted, missing sections.');

% image size in x, y, z, w, t, seq
[xsiz,ysiz] = readvals(iqinf.Header,'x','y');
[imginfo.image.size.x, imginfo.image.resolution.x] = parsevals(xsiz);
[imginfo.image.size.y, imginfo.image.resolution.y] = parsevals(ysiz);
[imginfo.image.size.z, imginfo.image.size.w, imginfo.image.size.t, imginfo.image.size.seq] = ...
  readvals(iqinf.Header,'Z','Wavelength','Time','Time1');
imginfo.image.size.z = nan2one(imginfo.image.size.z);
imginfo.image.size.w = nan2one(imginfo.image.size.w);
imginfo.image.size.t = nan2one(imginfo.image.size.t);
imginfo.image.size.seq = nan2one(imginfo.image.size.seq);

%%%% How to recognize T and T1 ???? 
if imginfo.image.size.seq == 1 && imginfo.image.size.t > 1
  tmp = imginfo.image.size.seq; imginfo.image.size.seq = imginfo.image.size.t; imginfo.image.size.t = tmp;
end
%%%% ---

% resolutiuon in z
if imginfo.image.size.z ~= 1  
  zres = readvals(iqinf.ProtocolDescription,'RepeatZ');
  if ~isnan(zres)
    % IQ2 protocol
    [a,b] = parsevals(zres);
    imginfo.image.resolution.z = a/(b-1);
  elseif isfield(iqinf,'TabSequence')
    % this is for older IQ protocol - z control in TabSequence
    imginfo.image.resolution.z = readvals(iqinf.TabSequence,'ZControlStep');
  end
else
  imginfo.image.resolution.z = 0;
end

% camera type and bit depth
if isfield(iqinf,'TabDeviceInfo')
  [code,nbit] = readvals(iqinf.TabDeviceInfo,'Camera','BitDepth');
  imginfo.camera = whichcamera(code);
  imginfo.camera.bitdepth = nbit;
else
  imginfo.camera = whichcamera('unknown');
  imginfo.camera.bitdepth = 16;
end

% roi
if isfield(iqinf,'ImageInfo')
  [xlim(1),xlim(2),ylim(1),ylim(2)] = ...
    readvals(iqinf.ImageInfo,'WindowLeft','WindowRight','WindowTop','WindowBottom');
  imginfo.camera.roi.xlim = cumsum(xlim) + 1;
  imginfo.camera.roi.ylim = cumsum(ylim) + 1;
else
  imginfo.camera.roi.xlim = [1 imginfo.image.size.x];
  imginfo.camera.roi.ylim = [1 imginfo.image.size.y];
end

% % gains
% if isfield(iqinf,'TabExposure')
%   [imginfo.camera.gain.PreAmp,imginfo.camera.gain.EM,imginfo.camera.gain.EMenabled] = ...
%     readvals(iqinf.TabExposure,'GainsPreAmpGain','GainsEMGain','EMGainEnabled');
%   imginfo.camera.gain.PreAmp = parsevals(imginfo.camera.gain.PreAmp);
% end

% snap order from protocol description
imginfo.data.order = getsnaporder(iqinf.ProtocolDescription);

% ----------------------------------------------------------------------------
function x = nan2one(x)
% ----------------------------------------------------------------------------
% Convert NaN values to 1
x(isnan(x)) = 1;

% ----------------------------------------------------------------------------
function varargout = readvals(in,varargin)
% ----------------------------------------------------------------------------
% read values of field names from a structure
nitems = nargin - 1;
varargout = cell(1,nitems);
for I = 1:nitems
  if isfield(in,varargin{I})
    varargout{I} = in.(varargin{I});
  else
    varargout{I} = NaN;
  end
end

% ----------------------------------------------------------------------------
function varargout = parsevals(str)
% ----------------------------------------------------------------------------
if isnumeric(str), varargout{1} = str; return; end;
% parse numbers from a string,  e.g., parsevals('blabla5blabla2.5blabla') = [5 2.5]
idx = isstrprop(str, 'digit')  | str == '.';
idx = diff([0 idx 0]);
ia = find(idx == 1);
ib = find(idx == -1)-1;
if isempty(ia), varargout{1} = NaN; return; end;
num = length(ia);  
varargout = cell(1,num);
for I = 1:num
  varargout{I} = str2double(str(ia(I):ib(I)));
end

% ----------------------------------------------------------------------------
function mode = getsnaporder(protocol)
% ----------------------------------------------------------------------------

% read snap order from protocol description
mode = [];
names = fieldnames(protocol);
for I = 1:length(names)
  if isempty(strfind(names{I},'End')), continue; end;
  str = names{I}(4:end);
  switch str    
    case 'T'
      mode = [mode 't'];
    case 'T1'
      mode = [mode 's'];
    case 'Channel'
      mode = [mode 'w'];
    case 'Z'
      mode = [mode 'z'];
    otherwise
      error('iq2getinfo:dimsorder', 'Description Protocol corrupted');
  end
end

if mode(1) == 't' && length(mode) ~= 1
  mode(1) = 's';
end

%eof