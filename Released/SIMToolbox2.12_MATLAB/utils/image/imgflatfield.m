function IM = imgflatfield(IM,IMw,IMb,scale)
% Flat field correction of an image
%
%   IM = imgflatfield(IM, IMw, IMb)
%
% Input/output arguments:
%
%   IM      ... [m x n]  image
%   IMw     ... [m x n]  image with full illumination
%   IMb     ... [m x n]  image with no illumination (default 0)

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

if nargin < 3
    IMb = 0;
    scale = 1;
elseif nargin < 4
    scale = 1;
    if isempty(IMb)
        IMb = 0;
    end
end

% if nargin < 3 || isempty(IMb)
%     IMb = 0;
% end

if (nargin > 1) && ~isempty(IMw)
    D = IMw-IMb;
    IM = mean(D(:))*(scale*IM-IMb)./D;
end
