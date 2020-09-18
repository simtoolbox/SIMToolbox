function inf = whichcamera(code)
% This is a database of our Andor cameras. Function
% returns properties of a camera based on the camera code.
%
%   inf = whichcamera(code)
%
% See also iq2getinfo

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

% camera database
db.camera(1) = Andor_Clara_CCD;
db.camera(2) = Andor_iXon_EMCCD;
db.camera(3) = Andor_Neo_sCMOS;
db.camera(4) = Andor_iXon_Ultra_EMCCD;
db.camera(5) = Andor_Zyla_sCMOS;

% match the code
if isempty(code)
    idx = [];
else
    idx = strcmp(code,{db.camera.code});
end

if isempty(idx) || ~any(idx)
    inf = Unknown;
else
    inf = db.camera(idx);
end

% -----------------------------------

function inf = Andor_Clara_CCD

inf.name = 'Clara CCD (Andor)';
inf.code = 'DR328 1436';
inf.size = struct('x', 1392, 'y', 1040);
inf.pixel = struct('pitch', 6.45, 'gap', 0);

function inf = Andor_iXon_EMCCD

inf.name = 'iXon EMCCD (Andor)';
inf.code = 'DU8285_VP 4146';
inf.size = struct('x', 1004, 'y', 1002);
inf.pixel = struct('pitch', 8, 'gap', 0);

function inf = Andor_Neo_sCMOS

inf.name = 'Neo sCMOS (Andor)';
inf.code = 'DC-152Q-C00-FI 1348';
inf.size = struct('x', 2560, 'y', 2160);
inf.pixel = struct('pitch', 6.5, 'gap', 0);

function inf = Andor_iXon_Ultra_EMCCD

inf.name = 'iXon Ultra EMCCD (Andor)';
inf.code = 'DU897_BV 7358';
inf.size = struct('x', 512, 'y', 512);
inf.pixel = struct('pitch', 16, 'gap', 0);

function inf = Andor_Zyla_sCMOS

inf.name = 'Zyla sCMOS (Andor)';
inf.code = 'ZYLA-4.2P-USB3 4026';
inf.size = struct('x', 2048 , 'y', 2048);
inf.pixel = struct('pitch', 6.5, 'gap', 0);

function inf = Unknown

inf.name = 'unknown';
inf.code = '';
inf.size = struct('x', [], 'y', []);
inf.pixel = struct('pitch', [], 'gap', []);

%eof