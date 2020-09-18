function ptrninfo = ptrnopen(filename)
% Open a pattern repertoire. This means that the repertoire
% is unziped to a temporary directory and information about
% its content is extracted.
%
%   ptrninfo = ptrnopen(filename)
%
% Input/output arguments:
%
%   filename   ... [string]  path to pattern repertoire
%   ptrninfo   ... [struct]  pattern information
%
% Example:
%      
%   ptrninfo = ptrnopen('patterns\lines0o\1\lines0o-1-07-1-08.repz');
%   im = ptrnload(ptrninfo, 'runningorder', 2, 'number', 5);
%   imagesc(im); colormap gray; axis image off;
%   ptrnclose(ptrninfo);
%
%   See also ptrnload, ptrnclose, ptrn2camera

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

% test if repz file exists
assert(isfile(filename), 'ptrnopen:filenotfound', 'Pattern repertoire not found.');

% extract repertoire into a temporary directory
fn = fileparts_name(filename);
dirname = [pwd '\temp\' fn];
if ~isdir(dirname) && (mkdir(dirname) == 1)
  unzip(filename,dirname);
end

% test if repz contains description file
assert(isfile([dirname filesep fn '.yaml']), 'ptrnopen:repzempty', 'Pattern repertoire is empty.');

try
  % read description
  ptrninfo = YAML.read([dirname filesep fn '.yaml']);
  ptrninfo.datadir = dirname;
  assert(isfield(ptrninfo,'runningorder'));
  % convert struct to cell
  for I = 1:ptrngetnumro(ptrninfo)
    data = ptrninfo.runningorder(I).data;
    % subsequences in one running order
    if isstruct(data)
      tmp = cell(length(data),1);
      offset = 0; % offset of the subsequence
      for J = 1:length(data)
         tmp{J} = data(J);
         tmp{J}.offset = offset;
         offset = offset + data(J).num;
      end
      ptrninfo.runningorder(I).data = tmp;
    end
  end
catch err
  error('ptrnopen:descriptionerror', 'Error reading description file.');
end

%eof