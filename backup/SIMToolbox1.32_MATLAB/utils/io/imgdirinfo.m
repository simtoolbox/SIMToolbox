function imginfo = imgdirinfo(datadir, filemask, ptrns)
% Read directory information.
%
%   imginfo = imgdirinfo(datadir, filemask, ptrns)
%
% Input/output arguments:
%
%   datadir   ... [string] data directory
%   filemask  ... [string] search the directory with 'filemask*.tif'
%   ptrns     ... [cell]   patterns contained in files, e.g., {'_z','_w','_t'}
%   imginfo   ... [struct] information about files in the datadir
%
% Note that filemask is determined from datadir if filemask is empty.
%
% See also imginfoinit, imgload

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

% datadir 
assert(isdir(datadir), 'imgdirinfo:nodatadir', 'Data directory does not exist.');
datadir = fileparts_dir([datadir filesep]);

% set filemask: if it is empty, then take filemask from the dir name
if isempty(filemask)
  idx = find(datadir == filesep,1,'last');
  filemask = datadir((idx+1):end);
end

% read dir info - only files in datadir named "filemask*.tif"
dirinfo = [dir([datadir filesep filemask '.tif']); dir([datadir filesep filemask '_*.tif'])];

% find files with patterned numbers in name
numfiles = length(dirinfo);
numptrns = length(ptrns);
IDX = zeros(numfiles,numptrns+1); K = 0;
for I = 1:numfiles  
  fn = dirinfo(I).name;
  if sum(strfindptrns(fn,[ptrns{:},{[filemask '.tif']}])) == 0, continue; end;
  K = K+1;
  IDX(K,end) = I;
  for J = 1:numptrns
    IDX(K,J) = parsenum(fn,ptrns{J});
  end
end
assert(K > 0, 'imgdirinfo:nodatafile', 'Data file(s) not found in the directory.');
IDX = IDX(1:K,:);
IDX(isnan(IDX)) = 0;

% count number of files in each dimension
numfiles = zeros(1,numptrns);
for J = 1:numptrns
  numfiles(J) = length(unique(IDX(:,J)));
end
numfiles(numfiles <= 1) = 0;

% sort files and create a list
IDX = sortrows(IDX);
filelist = {dirinfo(IDX(:,end)).name};

% count number of images in each data file
numpg(1) = tiffnumpg([datadir filesep filelist{1}]);  % count first file
nfiles = length(filelist);
if nfiles > 1
  fsiz = cat(1,dirinfo(IDX(:,end)).bytes);
  if abs(fsiz(end)-median(fsiz(1:nfiles-1))) > 0.1*fsiz(1)/numpg(1)
    % count number of images in last file if size of the last file is different
    numpg(2:nfiles-1) = numpg(1);
    numpg(nfiles) = tiffnumpg([datadir filesep filelist{nfiles}]);
  else
    % assume equal number of images in each file
    numpg(2:nfiles) = numpg(1);
  end
end

% output
imginfo.data.dir = datadir;
imginfo.data.filemask = filemask;
imginfo.data.filelist = filelist;
imginfo.data.numframes = [0 cumsum(numpg)];
for J = 1:numptrns
  imginfo.data.numfiles.(fixname(ptrns{J})) = numfiles(J);
end

% ----------------------------------------------------------------------------
function num = parsenum(str, id)
% ----------------------------------------------------------------------------
% parse number according to identifier from a string, e.g., parsenum('aaa_t0005_z0002','_t') = 5
strlen = length(str);
% find beginning
idx1 = strfind(str,id) + length(id);
if isempty(idx1), num = NaN; return; end;
% find end
idx2 = find(str(idx1:end) < '0' | str(idx1:end) > '9', 1, 'first') + idx1 - 2;
if isempty(idx2), idx2 = length(strlen); end;
% convert string
num = str2double(str(idx1:idx2));

% ----------------------------------------------------------------------------
function str = fixname(str)
% ----------------------------------------------------------------------------
% string contains only letters
str( (str < 'A' | str > 'Z') & (str < 'a' | str > 'z')) = [];

% ----------------------------------------------------------------------------
function idxmatch = strfindptrns(str,ptrns)
% ----------------------------------------------------------------------------
% Find first occurence of a pattern in a string for all patterns
% idx = strfindptrns('minmax',{'min','max','mmm'})

numptrns = length(ptrns);
idxmatch = zeros(1,numptrns);
for I = 1:numptrns
  idx = strfind(str,ptrns{I});  
  if isempty(idx)
    idxmatch(I) = 0;
  else
    idxmatch(I) = idx(1);
  end;  
end

%eof