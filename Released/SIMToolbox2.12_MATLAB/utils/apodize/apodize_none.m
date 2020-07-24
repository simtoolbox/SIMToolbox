function [A, params] = apodize_none(siz, params)
% 2D no filter
%
%   [A, params] = apodize_none(siz, params)
%
% Input/output arguments:
%
%   siz                 ... [m,n]     filter size
%   params              ... []
%   A                   ... [m x n]   filter profile
%
% Filter definition:
%
%   A = ones(siz)
%
% Example:
%
%   A = apodize_none([255 255]);
%   figure; imagesc(-1:1, -1:1, A); axis image;

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

% default values
if nargin < 2
  params = [];
end

% return function info
if nargin < 1
  A.mfile = fileparts_name([mfilename('fullpath') '.m']);
  A.type = 'none';
  A.name = 'None';
  A.params = params;
  return;
end

assert(numel(siz) == 2 && any(siz > 0), 'apodize:siz', 'Wrong filter size.');

% filter definition
A = ones(siz);

%eof