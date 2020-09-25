function [imb, params] = filter_none(imraw, params)
% No filter
%
%   [imb, params] = filter_none(imraw, params)
%
% Input/output arguments:
%
%   imraw             ... [m x n]  input image
%   imb               ... [m x n]  filtered image
%   params            ... []

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

% default parameters
if  nargin < 2 || ~isempty(params)
  params = [];
end

% return function info
if nargin < 1
  imb.mfile = fileparts_name([mfilename('fullpath') '.m']);
  imb.type = 'none';
  imb.name = 'None';
  imb.params = params;
  return;
end

% filter definition
imb = imraw;

%eof