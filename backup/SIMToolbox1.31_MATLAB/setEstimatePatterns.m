% Copyright © 2014,2015 Tomas Lukes, lukestom@fel.cvut.cz
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

function varargout = setEstimatePatterns(varargin)

try % FEVAL switchyard
  if (nargout)
      [varargout{1:nargout}] = feval(varargin{:});
  else
      feval(varargin{:});
  end
catch err
  printerror(err);
end

%-----------------------------------------------------------------------------
function hmain = createDlg(imginfo, calinfo, cfg)
%-----------------------------------------------------------------------------
global data

dimload;
height = 2*dlgmargin + 4*hTitle + 17*hLine;
width = 475;

% initiate settings
sx = [];sy = []; sz = []; st = []; pxsize = []; pysize = []; pzsize = [];
data.prepdir.numangles = cfg.db.estpat.numangles;
data.prepdir.numphases(1:5) = cfg.db.estpat.numphases;
data.prepdir.dimorders = cfg.db.estpat.dimorders;
data.prepdir.angNames = {'angle1','angle2','angle3','angle4','angle5'};
data.prepdir.angVals(1:5) = [0,60,120,0,0];
data.prepdir.impath = [];
data.prepdir.rearrange = 0;
data.prepdir.dimorderIdx = 1;

% ----------- Prepare directory dialog -----------

psiz = get(0,'ScreenSize');
hmain = figure('Name', 'Estimate patterns from data', 'Tag', 'dlgEstimPatterns', 'Resize','off', 'WindowStyle', 'modal', ...
    'Units', 'pixels', 'Position', [(psiz(3)-width)/2, (psiz(4)-height)/2, width, height], 'HandleVisibility','off', ...
    'MenuBar','none','NumberTitle','off','DeleteFcn', 'setEstimatePatterns(''dlg_onquit'',gcbo,[],guidata(gcbo))','Color', bkgcolor);
psiz = get(hmain,'Position'); psiz(1:2) = [0 height]; top = psiz(4) - hTitle - dlgmargin; 


% ----------- Image data directory  -----------

height = hTitle+2*dlgmargin+1*hLine;
himd = uipanel('Parent', hmain, 'Units', 'pixels', 'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], 'Title', 'Set path of the image file');
psiz = get(himd,'Position'); top = psiz(4) - hTitle - dlgmargin; 

uicontrol('Parent',himd, 'Style', 'pushbutton', 'String', 'Image file:', ...
    'Tag', 'btnImageFilePath', ...
    'Callback', 'setEstimatePatterns(''btnImageFilePath_Callback'',gcbo,[],guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-1*hLine, 100, hBtn]);  

uicontrol('Parent',himd, 'Style', 'edit', ...
    'Tag', 'editImagePath', ...
    'Callback', 'setEstimatePatterns(''editImagePath_Callback'',gcbo,[],guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [dlgmargin+100, top-1*hLine, psiz(3)-3*dlgmargin-100, hEdtBx], ...
    'HorizontalAlignment', 'left', 'BackgroundColor','w'); %,'Enable', 'off'

% ----------- Pattern info  -----------

height = hTitle+2*dlgmargin+4*hLine;
hpati = uipanel('Parent', hmain, 'Tag','EstimatePattern','Units', 'pixels', 'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], 'Title', 'Pattern info');
psiz = get(hpati,'Position'); top = psiz(4) - hTitle - dlgmargin; 

uicontrol('Parent',hpati, 'Style', 'text', 'String', 'Number of different pattern angles:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-1*hLine, 300, hTxt], ...
    'HorizontalAlignment','left');
uicontrol('Parent',hpati, 'Style', 'edit', 'String', data.prepdir.numangles, ...
  'Tag', 'editNumangles', ...
  'Callback', 'setEstimatePatterns(''editNumangles_Callback'',gcbo,''numangles'',guidata(gcbo))',  ...
  'Units', 'pixels', 'Position', [dlgmargin+300, top-1*hLine, 60, hTxt], ...
  'BackgroundColor','w');

% Aproximate value for each angle    
    uicontrol('Parent',hpati, 'Style', 'text', 'String', 'Aproximate angle [degrees]:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-3*hLine, 150, hTxt], ...
    'HorizontalAlignment','left');

for I = 5:-1:1 % max orientations is 5 
    if I > data.prepdir.numangles; vis = 'Off'; else vis = 'On'; end; % choose if the uicontrol will be visible
    uicontrol('Parent',hpati, 'Style', 'text', 'String', data.prepdir.angNames{I}, ...
    'Tag', sprintf('angText%d', I), ...
    'Units', 'pixels', 'Position',  [dlgmargin+100+I*60, top-2*hLine, 50, hTxt], ...
    'HorizontalAlignment','left','Visible',vis);

    uicontrol('Parent',hpati, 'Style','edit','String', data.prepdir.angVals(I), ...
    'Tag', sprintf('editAngEval%d', I), ...
    'Callback', sprintf('setEstimatePatterns(''editAngEval_Callback'',gcbo,%d)', I), ...
    'Units', 'pixels', 'Position', [dlgmargin+100+I*60, top-3*hLine,  50, hTxt],'Visible',vis);

end

% Number of phases per each angle
    uicontrol('Parent',hpati, 'Style', 'text', 'String', 'Number of phases per:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-4*hLine, 150, hTxt], ...
    'HorizontalAlignment','left');

for I = 5:-1:1 % max orientations is 5 
    if I > data.prepdir.numangles; vis = 'Off'; else vis = 'On'; end; % choose if the uicontrol will be visible

    uicontrol('Parent',hpati, 'Style','edit','String', cfg.db.estpat.numphases, ...
    'Tag', sprintf('editNumPhaseEval%d', I), ...
    'Callback', sprintf('setEstimatePatterns(''editNumPhaseEval_Callback'',gcbo,%d)', I), ...
    'Units', 'pixels', 'Position', [dlgmargin+100+I*60, top-4*hLine,  50, hTxt],'Visible',vis);

end

% ----------- Description file  -----------

height = hTitle+2*dlgmargin+7*hLine;
hdescf = uipanel('Parent', hmain, 'Tag','DescriptionFileInfo','Units', 'pixels', 'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], 'Title', 'Description file info');
psiz = get(hdescf,'Position'); top = psiz(4) - hTitle - dlgmargin; 

% Image width
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'Image width (number of pixels along x)', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-1*hLine, 300, hTxt], ...
    'HorizontalAlignment','left');
uicontrol('Parent',hdescf, 'Style', 'edit', 'String', sx, ...
  'Tag', 'editSx', ...
  'Callback', 'setEstimatePatterns(''editSx_Callback'',gcbo,''sx'',guidata(gcbo))',  ...
  'Units', 'pixels', 'Position', [dlgmargin+300, top-1*hLine, 60, hTxt], ...
  'BackgroundColor','w');
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'px', ...
    'Units', 'pixels', 'Position',  [dlgmargin+365, top-1*hLine, 60, hTxt], ...
    'HorizontalAlignment','left');

% Image height
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'Image height (number of pixels along y)', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-2*hLine, 300, hTxt], ...
    'HorizontalAlignment','left');
uicontrol('Parent',hdescf, 'Style', 'edit', 'String', sy, ...
  'Tag', 'editSy', ...
  'Callback', 'setEstimatePatterns(''editSy_Callback'',gcbo,''sy'',guidata(gcbo))',  ...
  'Units', 'pixels', 'Position', [dlgmargin+300, top-2*hLine, 60, hTxt], ...
  'BackgroundColor','w');
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'px', ...
    'Units', 'pixels', 'Position',  [dlgmargin+365, top-2*hLine, 60, hTxt], ...
    'HorizontalAlignment','left');

% Number of z planes
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'Number of z planes', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-3*hLine, 300, hTxt], ...
    'HorizontalAlignment','left');
uicontrol('Parent',hdescf, 'Style', 'edit', 'String', sz, ...
  'Tag', 'editSz', ...
  'Callback', 'setEstimatePatterns(''editSz_Callback'',gcbo,''sz'',guidata(gcbo))',  ...
  'Units', 'pixels', 'Position', [dlgmargin+300, top-3*hLine, 60, hTxt], ...
  'BackgroundColor','w');

% Number of time points
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'Number of time points', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-4*hLine, 300, hTxt], ...
    'HorizontalAlignment','left');
uicontrol('Parent',hdescf, 'Style', 'edit', 'String', st, ...
  'Tag', 'editSt', ...
  'Callback', 'setEstimatePatterns(''editSt_Callback'',gcbo,''st'',guidata(gcbo))',  ...
  'Units', 'pixels', 'Position', [dlgmargin+300, top-4*hLine, 60, hTxt], ...
  'BackgroundColor','w');

% Projected pixel size (width)
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'Projected pixel size x (width)', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-5*hLine, 300, hTxt], ...
    'HorizontalAlignment','left');
uicontrol('Parent',hdescf, 'Style', 'edit', 'String', pxsize, ...
  'Tag', 'editPxsize', ...
  'Callback', 'setEstimatePatterns(''editPxsize_Callback'',gcbo,''psxsize'',guidata(gcbo))',  ...
  'Units', 'pixels', 'Position', [dlgmargin+300, top-5*hLine, 60, hTxt], ...
  'BackgroundColor','w');
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'um', ...
    'Units', 'pixels', 'Position',  [dlgmargin+365, top-5*hLine, 60, hTxt], ...
    'HorizontalAlignment','left');

% Projected pixel size (height)
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'Projected pixel size y (height)', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-6*hLine, 300, hTxt], ...
    'HorizontalAlignment','left');
uicontrol('Parent',hdescf, 'Style', 'edit', 'String', pysize, ...
  'Tag', 'editPysize', ...
  'Callback', 'setEstimatePatterns(''editPysize_Callback'',gcbo,''psysize'',guidata(gcbo))',  ...
  'Units', 'pixels', 'Position', [dlgmargin+300, top-6*hLine, 60, hTxt], ...
  'BackgroundColor','w');
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'um', ...
    'Units', 'pixels', 'Position',  [dlgmargin+365, top-6*hLine, 60, hTxt], ...
    'HorizontalAlignment','left');

% Projected pixel size z
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'Projected pixel size z (voxel depth)', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-7*hLine, 300, hTxt], ...
    'HorizontalAlignment','left');
uicontrol('Parent',hdescf, 'Style', 'edit', 'String', pzsize, ...
  'Tag', 'editPzsize', ...
  'Callback', 'setEstimatePatterns(''editPzsize_Callback'',gcbo,''pzsize'',guidata(gcbo))',  ...
  'Units', 'pixels', 'Position', [dlgmargin+300, top-7*hLine, 60, hTxt], ...
  'BackgroundColor','w');
uicontrol('Parent',hdescf, 'Style', 'text', 'String', 'um', ...
    'Units', 'pixels', 'Position',  [dlgmargin+365, top-7*hLine, 60, hTxt], ...
    'HorizontalAlignment','left');

% ----------- Rearrange stack  -----------

height = hTitle+2*dlgmargin+2*hLine;
hresta = uipanel('Parent', hmain, 'Tag','RearrangeStack','Units', 'pixels', 'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], 'Title', 'Rearrange input tif stack');
psiz = get(hresta,'Position'); top = psiz(4) - hTitle - dlgmargin;

% Enable input stack rearrangement
uicontrol('Parent',hresta, 'Style','checkbox','String', 'Rearrange input stack', ...
    'Tag', 'chkbxRearrange', ...
    'Callback', 'setEstimatePatterns(''chkbxRearrange_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-1*hLine, 300, hChkBx]);

% Specify arrangement of the current tif stack 
uicontrol('Parent',hresta, 'Style', 'text', 'String', 'Specify arrangement of the current tif stack', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-2*hLine, 300, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hresta, 'Style', 'popupmenu', 'String', cfg.db.estpat.dimorders, ...
    'Tag', 'popRearrange', ...
    'Callback', 'setEstimatePatterns(''popRearrange_Callback'',gcbo,''dimorder'',guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [dlgmargin+300, top-2*hLine, 150, hPopup], ...
    'BackgroundColor', 'w');


% ----------- Cancel, OK -----------

uicontrol('Parent',hmain, 'Style', 'pushbutton', 'String', 'Cancel', ...
    'Tag', 'btnCancel', ...
    'Callback', 'setEstimatePatterns(''btnCancel_Callback'',gcbo,[],guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [width-dlgmargin-200, dlgmargin, 100, hBtn]);
 
uicontrol('Parent',hmain, 'Style', 'pushbutton', 'String', 'OK', ...
    'Tag', 'btnOK',...
    'Callback', 'setEstimatePatterns(''btnOK_Callback'',gcbo,[],guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [width-dlgmargin-100, dlgmargin, 100, hBtn]);

% ----------- Init -----------
  
% init handles
datalocal.hndl = guihandles(hmain);

% make a local copy of variables and settings from dlgMain
datalocal.imginfo = imginfo;
datalocal.cfg = cfg;

guidata(datalocal.hndl.dlgEstimPatterns, datalocal);

%-----------------------------------------------------------------------------
function btnImageFilePath_Callback(h, eventdata,datalocal)
%-----------------------------------------------------------------------------
global data

% open dialog
[fileName,datadir,filterIndex] = uigetfile('*.tif; *.tiff; *.TIF; *.TIFF; *.jpg; *.jpeg; *.JPG; *.JPEG','MultiSelect','off');

if filterIndex ~=0
imName = fileName(1:strfind(fileName, '.')-1); % find position of a dot and image name
data.prepdir.impath = [datadir,fileName]; 
data.prepdir.imdir = [datadir,imName]; 
data.prepdir.fileName = fileName;

fileinfo = imfinfo(data.prepdir.impath);
data.prepdir.sx = fileinfo(1).Width;
data.prepdir.sy = fileinfo(1).Height;
data.prepdir.szt = numel(fileinfo);
set(datalocal.hndl.editSx, 'String', data.prepdir.sx);
set(datalocal.hndl.editSy, 'String', data.prepdir.sy);

set(datalocal.hndl.editImagePath, 'String', [datadir,fileName]);
end
  

%-----------------------------------------------------------------------------
function editImagePath_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

% read text field (before menu is updated)
impath = get(h, 'String');

if ~isempty(impath)
% extract path and filename
[datadir, fileName] = extractPathAndFilename(impath, data.prepdir.impath);
imName = fileName(1:strfind(fileName, '.')-1); % find position of a dot and image name
data.prepdir.impath = [datadir,fileName]; 
data.prepdir.imdir = [datadir,imName];
data.prepdir.fileName = fileName;

fileinfo = imfinfo(fileName);
data.prepdir.sx = fileinfo(1).Width;
data.prepdir.sy = fileinfo(1).Height;
data.prepdir.szt = numel(fileinfo);
set(datalocal.hndl.editSx, 'String', data.prepdir.sx);
set(datalocal.hndl.editSy, 'String', data.prepdir.sy);
end

%-----------------------------------------------------------------------------
function editAngEval_Callback(h, idx)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.angVals(idx) = num;

%-----------------------------------------------------------------------------
function editNumPhaseEval_Callback(h, idx)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.numphases(idx) = num;

%-----------------------------------------------------------------------------
function editNumangles_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.numangles = num;
for I = 1:5 % max orientations is 5
    if I>data.prepdir.numangles 
        set(eval(sprintf('datalocal.hndl.editAngEval%d', I)),'Visible','Off');
        set(eval(sprintf('datalocal.hndl.editNumPhaseEval%d', I)),'Visible','Off');
        set(eval(sprintf('datalocal.hndl.angText%d', I)),'Visible','Off');
    else
        set(eval(sprintf('datalocal.hndl.editAngEval%d', I)),'Visible','On');
        set(eval(sprintf('datalocal.hndl.editNumPhaseEval%d', I)),'Visible','On');
        set(eval(sprintf('datalocal.hndl.angText%d', I)),'Visible','On');
    end
end

%-----------------------------------------------------------------------------
function editNumphases_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.numphases = num;

%-----------------------------------------------------------------------------
function editSx_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.sx = num;

%-----------------------------------------------------------------------------
function editSy_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.sy = num;

%-----------------------------------------------------------------------------
function editSz_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.sz = num;

%-----------------------------------------------------------------------------
function editSt_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.st = num;

%-----------------------------------------------------------------------------
function editPxsize_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.pxsize = num;

%-----------------------------------------------------------------------------
function editPysize_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.pysize = num;

%-----------------------------------------------------------------------------
function editPzsize_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

num = str2double(strrep(get(h, 'String'),',','.'));
data.prepdir.pzsize = num;

%-----------------------------------------------------------------------------
function chkbxRearrange_Callback(h, eventdata)
%-----------------------------------------------------------------------------
global data

data.prepdir.rearrange = get(h, 'Value');

%-----------------------------------------------------------------------------
function popRearrange_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data
% get selection
idx = get(h, 'Value');
% change input data dimension order
data.prepdir.dimorder = data.prepdir.dimorders(idx);
data.prepdir.dimorderIdx = idx;

%-----------------------------------------------------------------------------
function btnOK_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
global data

% create folder in the current directory
% rearrange input tif file is this option is selected
% create repz file with patterns 
% move or copy image file into this folder
% create info file in txt

numangles = data.prepdir.numangles;
numphases = data.prepdir.numphases(1:numangles);% take into account only phases for the given number of angles
angles = data.prepdir.angVals(1:numangles);

% check inputs
try all([data.prepdir.sx,data.prepdir.sy,data.prepdir.sz,data.prepdir.st...
         data.prepdir.pxsize,data.prepdir.pysize,data.prepdir.pzsize])
    if ~all([data.prepdir.sx,data.prepdir.sy,data.prepdir.sz,data.prepdir.st...
            data.prepdir.pxsize,data.prepdir.pysize,data.prepdir.pzsize])
        msgbox('Please fill in all the image stack dimensions and pixel sizes');
        return;
    end
catch 
    msgbox('Please fill in all the image stack dimensions and pixel sizes');
    return;
end

t1 = sum(numphases);
szt1t = data.prepdir.sz*t1*data.prepdir.st;

if szt1t~=data.prepdir.szt
     msgbox('The inserted image stack parameters do not correspond with the dimensions of the input image file. Please check the input file.');
    return;
end  

fileinfo = imfinfo(data.prepdir.impath);
data.prepdir.bdepth = fileinfo(1).BitDepth; 

% create pattern stucture

cfg.imsize = struct('x',data.prepdir.sx,'y',data.prepdir.sy);
cfg.seq = '48449 300us 1-bit Balanced.seq3';
% cfg.ptrndir = 'patterns/lines0o60o120o';
cfg.tmpdir = 'temp/';

if isempty(data.prepdir.impath)
    msgbox('Please select the image file');
    return;
else
    cfg.ptrndir = data.prepdir.imdir;
end

% create data directory 
if ~isdir(cfg.ptrndir), 
  mkdir(cfg.ptrndir); 
end

%----------- Rearrange input tif stack  -----------

% check if each angle has the same number of phases
if data.prepdir.rearrange == 1
    if sum(angles - mean(angles)) ~= 0
         msgbox('Stack rearrangement is supported only for stacks with the same number of phases for each angle.');
        return;
    end
    stack = loadtif([data.prepdir.imdir,'.tif']);

    [sy,sx,frames] = size(stack); 

    switch data.prepdir.dimorderIdx
        case 1 % ZAP - Nikon
            stack = reshape(stack,sy,sx,data.prepdir.sz,numangles,mean(numphases),data.prepdir.st);
            stack = permute(stack,[1 2 5 4 3 6]);
        case 2 % ZPA - Zeiss
            stack = reshape(stack,sy,sx,data.prepdir.sz,mean(numphases),numangles,data.prepdir.st);
            stack = permute(stack,[1 2 4 5 3 6]);
        case 3 % PZA - OMX
            stack = reshape(stack,sy,sx,mean(numphases),data.prepdir.sz,numangles,data.prepdir.st);
            stack = permute(stack,[1 2 3 5 4 6]);
        case 4 
            stack = reshape(stack,sy,sx,numangles,mean(numphases),data.prepdir.sz,data.prepdir.st);
            stack = permute(stack,[1 2 4 3 5 6]);
    end
    stack = reshape(stack,sy,sx,frames);
    
    fig = waitbar(0,'Saving rearranged stack ...','Name','Saving ...','Tag','WaitBar','WindowStyle','modal');
    for jj = 1:frames
        waitbar(jj/frames, fig);
        imwrite(stack(:,:,jj),[data.prepdir.imdir,filesep,data.prepdir.fileName],'WriteMode', 'append',  'Compression','none');
    end
    
    if ishandle(fig), delete(fig); end; % close saving stack status bar
end
%--------------------------------------------------

cfg.hndlwb = waitbar(0,'Preparing data directory ...','Name','Processing ...','Tag','WaitBar','WindowStyle','modal');

I_step = 1;
I_on = 1;
I_off = numphases -1;
 
formatSpec = '-%u';
strAng = sprintf(formatSpec,angles);
ptrns = {};

name = sprintf('sin%so-seq%02d_estimated', strAng ,t1);
ptrns = [ptrns, {struct('name', name, 'imagesize', cfg.imsize, 'sequence', cfg.seq, 'default', 0, ...
              'runningorder',[ ...
                 ro_lines(name, 'none', angles, I_on, I_off, I_step, I_on, I_off, I_step) ...
              ])}];

ptrns{1}.estimate = 1;

%----------- Save pattern into repz file  -----------

cfg.numangles = numangles;
cfg.numphases = numphases;
cfg.angles = angles;
  
waitbar(1/20, cfg.hndlwb,'Creating patterns');
gen_repz(ptrns{1}, cfg);

% if the stack was not rearranged - use the input file and move it into the new directory
if data.prepdir.rearrange == 0
movefile([data.prepdir.impath], [data.prepdir.imdir,filesep,data.prepdir.fileName]);
end

% create description text file
imName = data.prepdir.fileName(1:strfind(data.prepdir.fileName, '.')-1);
outputFile = [data.prepdir.imdir,filesep,filesep,imName,'.txt'];

waitbar(1/2, cfg.hndlwb,'Generating description file');
gen_descfile(outputFile, data)

% close status bar
if ishandle(cfg.hndlwb), delete(cfg.hndlwb); end;
msgbox(['Data directories were successfuly generated']);

% close dialog
close(datalocal.hndl.dlgEstimPatterns);

%-----------------------------------------------------------------------------
function btnCancel_Callback(h, eventdata, data)
%-----------------------------------------------------------------------------
close(data.hndl.dlgEstimPatterns);

%-----------------------------------------------------------------------------
function dlg_onquit(h, eventdata, data)
%-----------------------------------------------------------------------------
% close(data.hndl.figPreview(ishandle(data.hndl.figPreview)));
rmappdata(data.hndl.dlgEstimPatterns, 'UsedByGUIData_m');
