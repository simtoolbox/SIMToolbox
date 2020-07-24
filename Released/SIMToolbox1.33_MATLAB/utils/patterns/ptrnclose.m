function ptrninfo = ptrnclose(ptrninfo)
% Close pattern repertoire and delete temporary files.
%
%   ptrninfo = ptrnclose(ptrninfo)
%
% Input/output arguments:
%
%   ptrninfo   ... [struct]  pattern information created by ptrnopen
%
% Example:
%
%   ptrninfo = ptrnopen('patterns\lines0o\1\lines0o-1-07-1-08.repz');
%   im = ptrnload(ptrninfo, 'runningorder', 2, 'number', 5);
%   imagesc(im); colormap gray; axis image off;
%   ptrnclose(ptrninfo);
%
% See also ptrnopen, ptrnload

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

if ~isempty(ptrninfo)
    assert(isfield(ptrninfo,'datadir'), 'ptrnclose:noptrn', 'Input does not contain pattern information.');
    if isdir(ptrninfo.datadir)
        delete([ptrninfo.datadir filesep '*']);
        rmdir(ptrninfo.datadir);
        rmdir(fileparts(ptrninfo.datadir));
    end
    ptrninfo = [];
end
