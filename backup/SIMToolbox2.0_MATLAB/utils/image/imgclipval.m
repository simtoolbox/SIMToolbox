function val = imgclipval(IM, saturate)
% Compute intensity values used for cliping
%
%   val = imgclipval(IM, [low,high])
%
% Input/output arguments:
%
%   IM       ... [m x n]  image
%   saturate ... [1 x 2]  [low,high] percentage interval of image intensities
%   val      ... [1 x 2]  [low,high] corresponding intensity values
%
% Example:
%
%   imagesc(IM, imgclipval(IM, [0.01 0.99]))
%
% See also imagesc

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

vals = sort(IM(~isnan(IM(:))));
num = length(vals);
if isempty(vals) || num < 2
  val = [0 1];
else
  %val = quantile(vals, saturate);
  val = vals(round(saturate*(num-1))+1)';
  val(1) = max(val(1),0); % don't use negative numbers
  if abs(diff(val)) < 100*eps || val(2) < val(1)
    val(2) = val(1)+100*eps;
  end
end
