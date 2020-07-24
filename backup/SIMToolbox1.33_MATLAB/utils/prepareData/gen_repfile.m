function str = gen_repfile(ptrn, fname)
% Generate repertoire string and/or file
%
%  str = gen_repfile(ptrn, fname)
%
%  ptrn.seqence       ... [str] sequence file name
%  ptrn.default       ... default running order
%  ptrn.runningorder  ... struct with fields
%    .trigger         ... 'none' / 'F' / 'TF' trigger 
%    .data{}.images   ... image file names        
%  fname              ... [str] save to file

% Copyright © 2013-2015 Pavel Krizek
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

if nargin < 2, fname = ''; end

% -- init
str = [];

% -- header
str = [str, sprintf([...
  'SEQUENCES\n' ...
  'A "%s"\n' ...
  'SEQUENCES_END\n\n'], ptrn.sequence)];

% -- images
imagesall = {};
for I = 1:length(ptrn.runningorder)
  imagesall = cat(2, imagesall, get_ptrnimagenames(ptrn.runningorder(I)));
end
% get unique names and sort them
[foo,idx] = unique(imagesall);
imagesall = imagesall(sort(idx));
str = [str, ...
  sprintf('IMAGES\n'), ...
  sprintf('1 "%s"\n',imagesall{:}), ...
  sprintf('IMAGES_END\n\n')];


% -- running orders
for I = 1:length(ptrn.runningorder)
  
  % RO default flag
  if I == ptrn.default + 1
    str = [str, 'DEFAULT '];
  end
  
  % RO name
  str = [str, sprintf('"%s"\n[\n\n', ptrn.runningorder(I).name)];
  
  % find bitplane index for images
  imagesro = get_ptrnimagenames(ptrn.runningorder(I));
  numimages = length(imagesro);
  bitplaneidx = zeros(1,numimages);
  for J = 1:numimages
    bitplaneidx(J) = strmatch(imagesro{J},imagesall,'exact') - 1; % running orders start from 0
  end

  % RO sequence
  switch ptrn.runningorder(I).trigger
    case 'none'
        str = [str, sprintf(' <(A,%d) >\n', bitplaneidx)];
    case 'F'
        str = [str, sprintf(' {f (A,%d) }\n', bitplaneidx)];
    case 'TF'
      for J = 1:numimages
        str = [str,sprintf(' <t(A,%d) >\n {f (A,%d) }\n', bitplaneidx(J), bitplaneidx(J))];
      end
    otherwise
      error('gen_repfile:unknowntrig','Unknown trigger command.')
  end
  str = [str,sprintf(']\n\n')];
end

% -- save to file
if ~isempty(fname) && ischar(fname)
  fid = fopen(fname,'w');
  fprintf(fid,'%s',str);
  fclose(fid);
end
  
%eof