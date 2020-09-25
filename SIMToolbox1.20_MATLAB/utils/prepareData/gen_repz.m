function ptrn = gen_repz(ptrn, cfg)
% Generate pattern repertoire according to ptrn
%
%   ptrn = gen_repz(ptrn, cfg)
%
%   ptrn.name          ... [str] repertoire name
%   ptrn.imagesize     ... struct with pattern image size
%         .x           ... [scalar] number of columns
%         .y           ... [scalar] number of rows
%   ptrn.sequence      ... [str] sequence file *.seq3
%   ptrn.default       ... [scalar] default running order
%   ptrn.runningorder  ... struct with running orders
%         .name        ... [str] name of the running order
%         .trigger     ... 'none' / 'F' / 'TF' : no trigger / falling edge / starting and falling edge
%         .data        ... cell with a sequence
%           .id        ... 'white' / 'black' / 'lines' / 'dotsSQ' / 'dotsTRI' / 'calibr' / 'alignwithlines' / ...
%            ...       ... parameters appropriate to the pattern generator
%           .inverse   ... 'on' make an inverse pattern (optional)
%           .repeat    ... [scalar] number of repeats of the sequence (optional)

% Copyright © 2013-2015 Pavel Krizek,Tomas Lukes, lukestom@fel.cvut.cz
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

% make a temporary directory
fname = ptrn.name;
tmpdir = [cfg.tmpdir fname];
if ~isdir(tmpdir), 
  mkdir(tmpdir);
else
  delete([tmpdir filesep '*']);
end

% add field with total number of images in a sequence + order fields
ptrn.runningorder().numseq = [];
ptrn.runningorder = orderfields(ptrn.runningorder,{'name','trigger','numseq','data'});

% generate images for running orders and update ptrn.runningorder.data
imgnames = {};
IM = false([ptrn.imagesize.y, ptrn.imagesize.x, 0]); %clear
for I = 1:length(ptrn.runningorder)
  
  % generate pattern sequence for one runing order  
  for J = 1:length(ptrn.runningorder(I).data)
    waitbar(J/length(ptrn.runningorder(I).data), cfg.hndlwb,'Creating patterns');
%     if isfield(ptrn,'estimate')
        [ptrn.runningorder(I).data{J}, tmpIM] = gen_ptrnest(ptrn.runningorder(I).data{J}, [ptrn.imagesize.y, ptrn.imagesize.x],cfg.angles(J),cfg.numphases(J));
%     else
%         [ptrn.runningorder(I).data{J}, tmpIM] = gen_ptrn(ptrn.runningorder(I).data{J}, [ptrn.imagesize.y, ptrn.imagesize.x]);    
%     end
    IM = cat(3, IM, tmpIM); % concatenate images
  end
  
  % read image names
  names = get_ptrnimagenames(ptrn.runningorder(I));
  ptrn.runningorder(I).numseq = length(names);
  imgnames = cat(2, imgnames, names);

end

waitbar(1, cfg.hndlwb,'Saving patterns');
% save images
[foo,idx] = unique(imgnames);
for J = idx'
  imwrite(double(IM(:,:,J)),[tmpdir filesep imgnames{J}]);  
end  

waitbar(1, cfg.hndlwb,'Generating repz file');
% generate repertoire & save ptrn info
gen_repfile(ptrn, [tmpdir filesep fname '.rep']);
YAML.write([tmpdir filesep fname '.yaml'], ptrn);

% copy seq file
% copyfile(ptrn.sequence, tmpdir);

% zip all in repz
files = dir(tmpdir);
zip([cfg.ptrndir filesep fname], {files(3:end).name}, tmpdir);

% rename repz
movefile([cfg.ptrndir filesep fname '.zip'], [cfg.ptrndir filesep fname '.repz']);

% remove temporary directory
rmdir(tmpdir,'s');

%eof