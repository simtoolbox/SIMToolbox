function imginfo = imginfoinit(datadir, filemask)
% Initialize data info structure. Data directory must contain
% a decription file with IQ2 grab protocol or user defined YAML.
%
%   imginfo = imginfoinit(datadir)
%   imginfo = imginfoinit(datadir, filemask)
%
% Input/output arguments:
%
%   datadir   ... [string]  string with data directory
%   filemask  ... [string]  search the directory with string filemask*.tif
%   imginfo   ... [struct]  image stack information
%
% Note that filemask is determined from datadir if filemask is empty.
%
% Example:
%
%   imginfo = imginfoinit(filename);
%   im = imgload(imginfo,'z',10,'seq',5,'datatype','double');
%
% See also imgload, imgdirinfo, iq2getinfo

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

if nargin < 2, filemask = []; end;

% read directory info
imginfo = imgdirinfo(datadir, filemask, {'_t','_z','_w','_s'});
  
% read yaml file description
if isfilest([imginfo.data.dir filesep imginfo.data.filemask '.info'])
  inf = YAML.read([imginfo.data.dir filesep imginfo.data.filemask '.info']);
  assert(isfield(inf,'id') && strcmp(inf.id,'SIM_data'), 'imginit:description:wrong', 'Not a description file.');    
% read IQ2 protocol file  
elseif isfilest([imginfo.data.dir filesep imginfo.data.filemask '.txt'])
  inf = iq2getinfo(iq2parse([imginfo.data.dir filesep imginfo.data.filemask '.txt']));
% Error
else
  error('imginit:description:missing','Description file is missing.')
end

% copy basic information
imginfo.data.order = inf.data.order;
imginfo.image = inf.image;
imginfo.camera = inf.camera;
imginfo.camera.norm = 2^imginfo.camera.bitdepth-1;
if isfield(inf, 'ptrn')
  imginfo.ptrn = inf.ptrn;
end

% find order of dimensions
imginfo = dimsorder(imginfo);

% ----------------------------------------------------------------------------
function imginfo = dimsorder(imginfo)
% ----------------------------------------------------------------------------

num = length(imginfo.data.order);

numtot = imginfo.image.size.z * imginfo.image.size.w * imginfo.image.size.t * imginfo.image.size.seq;
imginfo.data.offset = struct('z',numtot,'w',numtot,'t',numtot,'seq',numtot);

% loop within a file
offset = 1;
for I = 1:num
  strdim = imginfo.data.order(I);
  if imginfo.data.numfiles.(strdim) ~= 0, continue; end;
  % if (strdim == 't' && imginfo.image.size.t == 1), continue; end;
  if (strdim == 's'), strdim = 'seq'; end;
  imginfo.data.offset.(strdim) = offset;
  offset = offset * imginfo.image.size.(strdim);
end

% loop over files
for I = 1:num
  strdim = imginfo.data.order(I);
  if imginfo.data.numfiles.(strdim) == 0, continue; end;
  imginfo.data.offset.(strdim) = offset;
  offset = offset * imginfo.image.size.(strdim);
end

%eof