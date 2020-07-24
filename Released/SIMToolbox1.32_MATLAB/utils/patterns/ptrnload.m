function im = ptrnload(ptrninfo, varargin)
% Load an image of illumination pattern from a repertoire
%
%   im = ptrnload(ptrninfo, 'PropertyName', PropertyValue, ...)
%       
% Input/output arguments:
%
%   ptrninfo         ... [struct]  pattern information created by ptrnopen
%   im               ... [m x n]   matrix with an image of the pattern
%
%   Property Names:
%     'runningorder' ... [scalar]  running order of the pattern (default 0)
%     'number'       ... [scalar]  pattern number in a sequence (default 1)
%     'datatype'     ... [string]  e.g., 'single', 'uint16', 'logical' (default 'single')
%
% Example:
%      
%   ptrninfo = ptrnopen('patterns\lines0o\1\lines0o-1-07-1-08.repz');
%   im = ptrnload(ptrninfo, 'runningorder', 2, 'number', 5);
%   imagesc(im); colormap gray; axis image off;
%   ptrnclose(ptrninfo);
%
% See also ptrnopen, ptrnclose, ptrn2camera

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

[runningorder, number, datatype] = chkinput(varargin{:});

% number of patterns in the running order
numptrns = ptrngetnumseq(ptrninfo, runningorder);

% check number of patterns
assert((number > 0) && (number <= numptrns), 'ptrnload:outofrange', 'Pattern number out of range.');

% list of images in the running order
images = ptrngetimagenames(ptrninfo, runningorder);

% read image
im = feval(datatype,imread([ptrninfo.datadir filesep images{number}]));

% ----------------------------------------------------------------------------

function [runningorder, number, datatype] = chkinput(varargin)

% default options
runningorder = 0; number = 1; datatype = 'single';

% run through input arguments
for I = 1:2:length(varargin) 
  assert(ischar(varargin{I}) && any(strcmp(varargin{I},{'runningorder','number','datatype'})), 'ptrn:chkinput', 'Wrong property name.');
  eval([lower(varargin{I}) '=varargin{I+1};']);
end

%eof