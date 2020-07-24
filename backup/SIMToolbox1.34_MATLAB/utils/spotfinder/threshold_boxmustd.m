function [thr, params] = threshold_boxmustd(IM, params)
% Threshold image by a matrix: thr = boxmu + boxstd * params.thr
%
%   [thr, params] = threshold_boxmustd_matrix(IM, params)
%
% Input/output arguments:
%
%   im              ... [m x n]   input image
%   thr             ... [scalar]  output threshold value
%   params.thr      ... [scalar]  threshold value (default 1)
%   params.dim      ... [scalar]  image dimension (default 1)
%   params.boxsize  ... [scalar]  box size (default 16)
%   params.boxstep  ... [scalar]  box step (default 8)
%
% See also spotfinder, boxmustd

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
if nargin < 2 || ~isfield(params,'thr')
  params.thr = 1;
end

if nargin < 2 || ~isfield(params,'dim')
  params.dim = 1;
end

if nargin < 2 || ~isfield(params,'boxsize')
  params.boxsize = 16;
end

if nargin < 2 || ~isfield(params,'boxstep')
  params.boxstep = 4;
end

% return function info
if nargin < 1
  thr.mfile = fileparts_name([mfilename('fullpath') '.m']);
  thr.type = 'boxmustd';
  thr.name = 'Box mu + Box std * thr';
  thr.params = params;
  return;
end

% pad input image
im = double(IM(:,:,params.dim));
siz_orig = size(im);
pad = ceil(ceil((siz_orig+params.boxsize)./params.boxsize) .* params.boxsize/2 - siz_orig/2);

% box mean and standard deviation
[boxmu, boxstd] = boxmustd(padarray(im,pad,'replicate'), params.boxsize, params.boxstep);

%return same size as input
boxmu  = boxmu(pad(1)+(1:siz_orig(1)),pad(2)+(1:siz_orig(2)));
boxstd = boxstd(pad(1)+(1:siz_orig(1)),pad(2)+(1:siz_orig(2)));

% threshold
thr = boxmu + boxstd * params.thr;

%eof