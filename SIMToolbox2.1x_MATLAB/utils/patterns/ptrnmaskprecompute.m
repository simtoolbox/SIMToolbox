function MaskOn = ptrnmaskprecompute(imginfo, ptrninfo, calinfo, varargin)
% Precompute illumination mask for a sequence
%
%   MaskOn = ptrnmaskprecompute(imginfo, ptrninfo, calinfo, 'PropertyName', PropertyValue, ...)
%
% Input/output arguments:
%
%   imginfo          ... [struct]  image information created by imginfoinit
%   ptrninfo         ... [struct]  pattern information created by ptrnopen
%   calinfo          ... [struct]  calibration information created by calload
%   MaskOn           ... [m x n x numseq] matrix with pattern image
%
%   Property Names:
%     'runningorder' ... [scalar]  running order of the pattern - starts from 0 (default 0)
%     'sigma'        ... [scalar]  bluring of the illumination pattern before mapping (default 1)
%     'datatype'     ... [string]  e.g., 'single', 'uint16', 'logical' (default 'single')
%     'progressbar'  ... [handle]  handle to progress bar dialog
%
% Example:
%
%   imginfo = imginfoinit('data/polen/pollen 100X 1.45NA');
%   ptrninfo = ptrnopen(ptrndirinfo('data/polen/pollen 100X 1.45NA'));
%   calinfo = calload('data\polen\calibration\calibration_LIN.yaml');
%   MaskOn = ptrnmaskprecompute(imginfo, ptrninfo, calinfo, 'runningorder', 1, 'sigma', 1.3);
%   imagesc(MaskOn(:,:,1)); colormap gray; axis image off;
%   ptrnclose(ptrninfo);
%
% See also ptrnopen, ptrn2camera, imginfoinit, calload

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

if isempty(calinfo) || isempty(ptrninfo)
  MaskOn = [];
  return
end

% extract input variables
[numro, sigma, datatype, hndlwb] = chkinput(varargin{:});

% update progress bar
if ishandle(hndlwb)
%     waitbar(0, hndl_progressbar, 'Creating illumination mask');
    progressbarGUI(hndlwb,0,'Creating illumination mask ...','cyan');
end

% This is to suppress high frequency artifacts caused by interpolation
% 0/1 microdisplay mask has to be blured first before mapping to camera!
if sigma > 0.5
  maskblure = fspecialseparable('gauss', 2*fix(3*sigma)+1, sigma);
else
  maskblure = [];
end

% create look-up table
ptrn2camera(imginfo, ptrninfo, calinfo);

% allocate memmory according to number of patterns in the running order
num = ptrngetnumseq(ptrninfo, numro);
MaskOn = zeros([imginfo.image.size.y, imginfo.image.size.x, num], datatype);

% for all pattern positions
for I = 1:num
    
    % update progress bar
    if ~isempty(hndlwb)
        if ishandle(hndlwb)
%             waitbar(I/num, hndl_progressbar);
            progressbarGUI(hndlwb,I/num);
        else
            MaskOn = [];
            return;
        end
    end
    
    % load pattern
    imptrn = ptrnload(ptrninfo, 'runningorder', numro, 'number', I, 'datatype', datatype);
    
    % blure illumination pattern with PSF of the microscope
    if ~isempty(maskblure)
        imptrn = imfilterseparable(imptrn, maskblure, 'replicate');
    end
    
    % transform microdisplay illumination mask into camera coordinates
    MaskOn(:,:,I) = ptrn2camera(imptrn);
    
end
progressbarGUI(hndlwb,1,'Illumination mask is successfully created.','cyan');

% ----------------------------------------------------------------------------

function [runningorder, sigma, datatype, progressbar] = chkinput(varargin)

% default options
runningorder = 0; sigma = 1; datatype = 'single'; progressbar = [];

% run through input arguments
for I = 1:2:length(varargin) 
  assert(ischar(varargin{I}) && any(strcmp(varargin{I},{'runningorder','sigma','datatype','progressbar'})), 'ptrnmaskprecompute:chkinput', 'Wrong property name.');
  eval([lower(varargin{I}) '=varargin{I+1};']);
end

%eof