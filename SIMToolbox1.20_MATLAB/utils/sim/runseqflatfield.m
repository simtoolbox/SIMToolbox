function [seq,calinfo] = runseqflatfield(seq, calinfo, imginfo)
% Wrapper for flat field correction
%
%   IMseq = seqflatfield(IMseq, IMwhite, IMblack)
%   seq   = seqflatfield(seq, IMwhite, IMblack)
%
% Input/output arguments:
%
%   IMseq    ... [m x n x numseq]  sequence of images stored in a matrix
%   seq      ... [struct]  sequence of images created by seq2subseq
%   IMwhite  ... [m x n]  image with full illumination
%   IMblack  ... [m x n]  image with no illumination (default 0)
%   scale    ... scalar for denormalizing input image sequence
%
% See also seqflatfield, imgflatfield

% Copyright © 2015 Pavel Krizek, Tomas Lukes, lukestom@fel.cvut.cz
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
if isfield(calinfo.cal,'fferror') && calinfo.cal.fferror == 1 
    return
end

strpos = strfind(calinfo.dir, '\');
fname = calinfo.dir(strpos(end)+1:end);

if isempty(calinfo.cal.imFFwhite) 
    try
    calinfo.cal.imFFwhite = single(imread([calinfo.dir,filesep,fname,'_FFwhite.tif']));
    catch
        msgbox('White image for flat field correction not found. Please check the calibration folder.');
        calinfo.cal.fferror = 1;
        return
    end
end

if isempty(calinfo.cal.imFFblack)    
    try
    calinfo.cal.imFFblack = single(imread([calinfo.dir,filesep,fname,'_FFblack.tif']));
    catch
        msgbox('Black image for flat field correction not found. Please check the calibration folder.');  
        calinfo.cal.fferror = 1;
        return
    end
end

if isstruct(seq)
    temp = seq(1).IMseq(:,:,1);
else
    temp = seq(:,:,1);
end

try
    temp = temp.* calinfo.cal.imFFblack.*calinfo.cal.imFFwhite;
catch
    
    msgbox('Input images have different size than the calibration images for the flat field correction. Please check the files in the calibration folder.');    
    calinfo.cal.fferror = 1;
    
    clear temp;
    return
end

seq = seqflatfield(seq, calinfo.cal.imFFwhite,calinfo.cal.imFFblack,imginfo.camera.norm);

