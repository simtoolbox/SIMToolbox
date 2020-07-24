% Copyright © 2013,2014,2015 Pavel Krizek
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

function varargout = setFindPeaks(varargin)

try % FEVAL switchyard
    if (nargout)
        [varargout{1:nargout}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
catch err
    printerror(err);
end

%--------------------------------------------------------------------------
function hmain = createDlg(imginfo,ptrninfo,calinfo,cfg,axPrgBar)
%--------------------------------------------------------------------------

% ----------- Init -----------
% make a local copy of variables and settings from dlgMain
datalocal.imginfo = imginfo;
datalocal.calinfo = calinfo;
datalocal.ptrninfo = ptrninfo;
datalocal.cfg = cfg;
datalocal.preview = 0;

% temp preview of Fourier spaces
if isfield(datalocal.cfg,'imfft') && ~isempty(datalocal.cfg.imfft)
    datalocal.imfft = datalocal.cfg.imfft;
end

% add number of harmonics into running order
[datalocal.ptrn,numangles] = ptrnchecklines(ptrninfo,datalocal.cfg.ptrn.ro);
[datalocal.ptrn(:).numharmon] = deal([]);
[datalocal.ptrn(:).idx] = deal([]);

% spotfinder method
if ~isempty(cfg.sim.spotfindermethod.params)
    datalocal.cfg.db.spotfinder.radius = cfg.sim.spotfindermethod.params.radius;
end
if strcmp(cfg.sim.spotfindermethod.type,'calibration') && ~isempty(calinfo) 
    datalocal.cfg.sim.spotfindermethod = spotfinder_method_calibration;
else
    datalocal.cfg.sim.spotfindermethod = spotfinder_method_spotfinder(datalocal.cfg.db.spotfinder);
end

for I = 1:numangles
    datalocal.ptrn(I).offset = mod(datalocal.ptrn(I).offset+datalocal.cfg.ptrn.offset,imginfo.image.size.seq);
    datalocal.ptrn(I).numharmon = datalocal.cfg.ptrn.angles(I).numharmon;
    datalocal.ptrn(I).idx = I;
    if length(datalocal.cfg.db.spotfinder.radius)<I
        datalocal.cfg.db.spotfinder.radius(I) = datalocal.cfg.db.spotfinder.radius(1);
    end
    % load image data and compute FFT spectra
    if ~isfield(datalocal,'imfft') || length(datalocal.imfft)<length(datalocal.ptrn)
        datalocal.imfft{I} = sim_findpeaksloadimage(datalocal.imginfo,datalocal.ptrn(I),datalocal.cfg);
        progressbarGUI(axPrgBar,I/numangles,'Loading images');
    end
end
datalocal.cfg.sim.spotfindermethod.params.radius = datalocal.cfg.db.spotfinder.radius;
progressbarGUI(axPrgBar);
datalocal.ptrn = datalocal.ptrn(find([datalocal.cfg.ptrn.angles.enable]));
numangles = sum([datalocal.cfg.ptrn.angles.enable]);

dimload;
height = 2*dlgmargin + 3*hTitle + 10*hLine;
width = 475;

% ----------- Spot finder dialog -----------
psiz = get(0,'ScreenSize');
hmain = figure('Name','Finding peaks in FFT','Tag','dlgFindPeaks','Resize','off','WindowStyle','modal',...
    'Units','pixels','Position',[(psiz(3)-width)/2,(psiz(4)-height)/2,width,height],'HandleVisibility','off',...
    'MenuBar','none','NumberTitle','off','DeleteFcn','setFindPeaks(''dlg_onquit'',gcbo,[],guidata(gcbo))','Color',bkgcolor);
psiz = get(hmain,'Position'); psiz(1:2) = [0 height];

% ----------- Method  -----------
height = hTitle+2*dlgmargin+2*hLine;
hndl = uibuttongroup('Parent',hmain,'Units','pixels','Position',[dlgmargin,psiz(2)-height,width-2*dlgmargin,height],'Title','Method',...
    'Tag','radioMethod','SelectionChangeFcn','setFindPeaks(''radialMethod_Callback'',gcbo,''calibration'',guidata(gcbo))');
psiz = get(hndl,'Position'); top = psiz(4) - hTitle - dlgmargin;

uicontrol('Parent',hndl,'Style','radio','String','Calibration',...
    'Tag','radioCalibr',...
    'Units','pixels','Position',[dlgmargin,top-1*hLine,200,hPopup]);

uicontrol('Parent',hndl,'Style','radio','String','Spot finder (using data)',...
    'Tag','radioSpotfinder',...
    'Units','pixels','Position',[dlgmargin,top-2*hLine,200,hPopup]);

% ----------- Spot finder  -----------
height = hTitle+2*dlgmargin+5*hLine;
hndl = uipanel('Parent',hmain,'Tag','SpotFinder','Units','pixels','Position',[dlgmargin,psiz(2)-height,width-2*dlgmargin,height],'Title','Spot Finder');
psiz = get(hndl,'Position'); top = psiz(4) - hTitle - dlgmargin;

uicontrol('Parent',hndl,'Style','text','String','Filter:',...
    'Units','pixels','Position',[dlgmargin,top-1*hLine,60,hTxt],...
    'HorizontalAlignment','left');

uicontrol('Parent',hndl,'Style','popupmenu','String',{datalocal.cfg.db.spotfinder.filter.name},...
    'Tag','popFilter',...
    'Callback','setFindPeaks(''popSpotFinder_Callback'',gcbo,''filter'',guidata(gcbo))',...
    'Units','pixels','Position',[dlgmargin+60,top-1*hLine,120,hPopup],...
    'BackgroundColor','w');

uicontrol('Parent',hndl,'Style','text','String','Detector:',...
    'Units','pixels','Position',[dlgmargin,top-2*hLine,60,hTxt],...
    'HorizontalAlignment','left');

uicontrol('Parent',hndl,'Style','popupmenu','String',{datalocal.cfg.db.spotfinder.detector.name},...
    'Tag','popDetector',...
    'Callback','setFindPeaks(''popSpotFinder_Callback'',gcbo,''detector'',guidata(gcbo))',...
    'Units','pixels','Position',[dlgmargin+60,top-2*hLine,120,hPopup],...
    'BackgroundColor','w');

uicontrol('Parent',hndl,'Style','text','String','Estimator:',...
    'Units','pixels','Position',[dlgmargin,top-3*hLine,60,hTxt],...
    'HorizontalAlignment','left');

uicontrol('Parent',hndl,'Style','popupmenu','String',{datalocal.cfg.db.spotfinder.estimator.name},...
    'Tag','popEstimator',...
    'Callback','setFindPeaks(''popSpotFinder_Callback'',gcbo,''estimator'',guidata(gcbo))',...
    'Units','pixels','Position',[dlgmargin+60,top-3*hLine,120,hPopup],...
    'BackgroundColor','w');

% Radius text
uicontrol('Parent',hndl,'Style','text','String','Radius/Pattern spacing (nm):',...
    'Units','pixels','Position',[dlgmargin,top-4*hLine,145,hTxt],...
    'HorizontalAlignment','left');

for I = 1:numangles
    uicontrol('Parent',hndl,'Style','text','String',sprintf('%.0f:',datalocal.ptrn(I).angle),...
        'Units','pixels','Position',[dlgmargin+(I-1)*60,top-5*hLine,25,hTxt],...
        'HorizontalAlignment','right');
    % editbox
    uicontrol('Parent',hndl,'Style','edit','String','',...
        'Tag','editRadius',...
        'Callback',sprintf('setFindPeaks(''editRadius_Callback'',gcbo,''radius'',%d,guidata(gcbo))',I),...
        'Units','pixels','Position',[dlgmargin+(I-1)*60+28,top-5*hLine,30,hEdtBx],...
        'BackgroundColor','w');
end
datalocal.cfg.db.spotfinder.radiusequal = ~any(diff([datalocal.cfg.db.spotfinder.radius]));
uicontrol('Parent',hndl,'Style','checkbox',...
    'Tag','chkRadius','String','Equal for all angles',...
    'Units','pixels','Position',[dlgmargin+I*60+10,top-5*hLine+2,150,hTxt],...
    'Callback','setFindPeaks(''chkRadius_Callback'',gcbo,guidata(gcbo))',...
    'HorizontalAlignment','left');

% ----------- Harmonics  -----------
height = hTitle+2*dlgmargin+1*hLine;
hndl = uipanel('Parent',hmain,'Units','pixels','Position',[dlgmargin,psiz(2)-height,width-2*dlgmargin,height],'Title','Number of harmonics');
psiz = get(hndl,'Position'); top = psiz(4) - hTitle - dlgmargin;

% weights on harmonics
for I = 1:numangles
    % harmonic
    uicontrol('Parent',hndl,'Style','text','String',sprintf('%.0f:',datalocal.ptrn(I).angle),...
        'Units','pixels','Position',[dlgmargin+(I-1)*60,top-hLine,25,hTxt],...
        'HorizontalAlignment','right');
    % edit box for weight
    uicontrol('Parent',hndl,'Style','edit','String','',...
        'Tag','editNumHarmon',...
        'Callback',sprintf('setFindPeaks(''editNumHarmon_Callback'',gcbo,%d,guidata(gcbo))',I),...
        'Units','pixels','Position',[dlgmargin+(I-1)*60+28,top-hLine,30,hEdtBx],...
        'BackgroundColor','w');
end

% ----------- Preview,Cancel,OK -----------
wBtn = 80;
uicontrol('Parent',hmain,'Style','pushbutton','String','Preview',...
    'Tag','btnPreview','Enable','off',...
    'Callback','setFindPeaks(''btnPreview_Callback'',gcbo,[],guidata(gcbo))',...
    'Units','pixels','Position',[dlgmargin,dlgmargin,wBtn,hBtn]);

% use defaults from main menu
uicontrol('Parent',hmain,'Style','pushbutton','String','Defaults',...
    'Tag','btnDefaults',...
    'Callback','setFindPeaks(''btnDefaults_Callback'',gcbo,[],guidata(gcbo))',...
    'Units','pixels','Position',[2*dlgmargin+wBtn,dlgmargin,wBtn,hBtn]);

uicontrol('Parent',hmain,'Style','pushbutton','String','Cancel',...
    'Tag','btnCancel',...
    'Callback','setFindPeaks(''btnCancel_Callback'',gcbo,[],guidata(gcbo))',...
    'Units','pixels','Position',[width-2*(dlgmargin+wBtn),dlgmargin,wBtn,hBtn]);

uicontrol('Parent',hmain,'Style','pushbutton','String','OK',...
    'Tag','btnOK',...
    'Callback','setFindPeaks(''btnOK_Callback'',gcbo,[],guidata(gcbo))',...
    'Units','pixels','Position',[width-dlgmargin-wBtn,dlgmargin,wBtn,hBtn]);

% init handles
datalocal.hndl = guihandles(hmain);
datalocal.hndl.figPreview = repmat(-1,1,numangles);
datalocal.hndl.figPreviewSub = repmat(-1,1,numangles);

% update
updateDlg(datalocal,'on');

%--------------------------------------------------------------------------
function radialMethod_Callback(h,eventdata,data)
%--------------------------------------------------------------------------
% get option
hRadioBtn = get(h,'SelectedObject');
switch get(hRadioBtn,'Tag')
    
    case 'radioCalibr'
        data.cfg.sim.spotfindermethod = spotfinder_method_calibration;
    case 'radioSpotfinder'
        data.cfg.sim.spotfindermethod = spotfinder_method_spotfinder(data.cfg.db.spotfinder);
    otherwise
        error('setFindPeaks:method','Unknown method.');
end
% preview
% data = showPreview(data,'method');
% update
updateDlg(data,'on');

%--------------------------------------------------------------------------
function popSpotFinder_Callback(h,eventdata,data)
%--------------------------------------------------------------------------
% get selection
idx = get(h,'Value');
% change method
data.cfg.db.spotfinder.selection.(eventdata) = data.cfg.db.spotfinder.(eventdata)(idx).type;
data.cfg.sim.spotfindermethod = spotfinder_method_spotfinder(data.cfg.db.spotfinder);
% show preview
% data = showPreview(data,'spotfinder');
% update
updateDlg(data,'on');

%--------------------------------------------------------------------------
function editParamVal_Callback(h,eventdata,parname,data)
%--------------------------------------------------------------------------
idx = strcmp(data.cfg.db.spotfinder.selection.(eventdata),{data.cfg.db.spotfinder.(eventdata).type});
if strcmp(parname,'threshold')
    num = strrep(get(h,'String'),',','.');
%     str = get(h,'String');
    if ~isnan(num)
        str = [num '*std(F)'];
        data.cfg.db.spotfinder.(eventdata)(idx).params.threshold.params.fnc = str;
        data.cfg.sim.spotfindermethod.params.(eventdata).params.threshold.params.fnc = str;
    end
%     data = showPreview(data,'spotfinderparam');
else
    num = str2double(strrep(get(h,'String'),',','.'));
    if ~isnan(num)
        if strcmp(parname,'strel')
            data.cfg.db.spotfinder.(eventdata)(idx).params.(parname){2} = num;
        else
            data.cfg.db.spotfinder.(eventdata)(idx).params.(parname) = num;
        end
        data.cfg.sim.spotfindermethod.params.(eventdata).params.(parname) = num;
%         data = showPreview(data,'spotfinderparam');
    end
    % update field
%     set(h,'String',data.cfg.db.spotfinder.(eventdata)(idx).params.(parname));
end
% update
updateDlg(data);

%--------------------------------------------------------------------------
function data = setSpotFinderparams(h,eventdata,data)
%--------------------------------------------------------------------------

data.hndl.(eventdata).txtParamName = [];
data.hndl.(eventdata).editParamVal = [];

% show parameters settings
dimload;

pos = get(h,'Position');
hparent = get(h,'Parent');

idx = strcmp(data.cfg.db.spotfinder.selection.(eventdata),{data.cfg.db.spotfinder.(eventdata).type});

if ~isempty(data.cfg.db.spotfinder.(eventdata)(idx).params)
    parname = setdiff(fieldnames(data.cfg.db.spotfinder.(eventdata)(idx).params),{'dim','ge','samples'});
    if any(strcmp(data.cfg.db.spotfinder.(eventdata)(idx).type,{'dao','daoint','dog','dogint','gauss','gaussint','wavelet'}))
        parname = setdiff(parname,{'size'});
    end
    for I = 1:length(parname)
        % param name
        data.hndl.(eventdata).txtParamName = [ ...
            uicontrol('Parent',hparent,'Style','text','String',[parname{I} ':'],...
            'Tag','txtParamName',...
            'Units','pixels','Position',[190+(I-1)*90,pos(2),50,hTxt],...
            'HorizontalAlignment','right'),...
            data.hndl.(eventdata).txtParamName];
        % param value
        if strcmp(parname{I},'threshold')
            str = data.cfg.db.spotfinder.(eventdata)(idx).params.(parname{I}).params.fnc;
            idx = strfind(str,'*');
            data.hndl.(eventdata).editParamVal = [ ...
                uicontrol('Parent',hparent,'Style','edit','String',str(1:idx-1),...
                'Tag','editParamVal',...
                'Callback',sprintf('setFindPeaks(''editParamVal_Callback'',gcbo,''%s'',''%s'',guidata(gcbo))',eventdata,parname{I}),...
                'Units','pixels','Position',[245+(I-1)*90,pos(2),30,hEdtBx]),...
                data.hndl.(eventdata).editParamVal];
            uicontrol('Parent',hparent,'Style','text','String',str(idx:end),...
                'Units','pixels','Position',[275+(I-1)*90,pos(2),70,hTxt],...
                'HorizontalAlignment','left');
        else
            if strcmp(parname{I},'strel')
                str = data.cfg.db.spotfinder.(eventdata)(idx).params.(parname{I}){2};
            else
                str = data.cfg.db.spotfinder.(eventdata)(idx).params.(parname{I});
            end
            data.hndl.(eventdata).editParamVal = [ ...
                uicontrol('Parent',hparent,'Style','edit','String',str,...
                'Tag','editParamVal',...
                'Callback',sprintf('setFindPeaks(''editParamVal_Callback'',gcbo,''%s'',''%s'',guidata(gcbo))',eventdata,parname{I}),...
                'Units','pixels','Position',[245+(I-1)*90,pos(2),30,hEdtBx],...
                'BackgroundColor','w'),...
                data.hndl.(eventdata).editParamVal];
        end
    end
end

%--------------------------------------------------------------------------
function chkRadius_Callback(h,data)
%--------------------------------------------------------------------------
N = length(data.hndl.editRadius);
data.cfg.db.spotfinder.radiusequal = h.Value;
state = {'on','off'};
for n = 1:N-1
    set(data.hndl.editRadius(n),'Enable',state{h.Value+1});
end
editRadius_Callback(data.hndl.editRadius(N),'radius',N,data);

%--------------------------------------------------------------------------
function editRadius_Callback(h,eventdata,idx,data)
%--------------------------------------------------------------------------
num = str2double(strrep(get(h,'String'),',','.'));
num = num/(1e3*data.cfg.sim.otf.params.resolution);
if data.cfg.db.spotfinder.radiusequal
    N = length(data.ptrn);
    if ~isnan(num) && num > 0
        for idx = 1:N
            data.cfg.sim.spotfindermethod.params.(eventdata)(idx) = num;
            data.cfg.db.spotfinder.(eventdata)(idx) = num;
%             data = showPreview(data,'radius');
        end
    end
    for idx = 1:N
        tmp = 1e3*data.cfg.sim.otf.params.resolution*data.cfg.sim.spotfindermethod.params.(eventdata)(idx);
        set(data.hndl.editRadius(idx),'String',tmp);
    end
else
    if ~isnan(num) && num > 0
        data.cfg.sim.spotfindermethod.params.(eventdata)(idx) = num;
        data.cfg.db.spotfinder.(eventdata)(idx) = num;
%         data = showPreview(data,'radius');
    end
    tmp = 1e3*data.cfg.sim.otf.params.resolution*data.cfg.sim.spotfindermethod.params.(eventdata)(idx);
    set(h,'String',tmp);
end
updateDlg(data);

%--------------------------------------------------------------------------
function editNumHarmon_Callback(h,idx,data)
%--------------------------------------------------------------------------
num = str2double(strrep(get(h,'String'),',','.'));
if ~isnan(num) && num >= 0 && num <= 4 && num <= fix((data.ptrn(idx).num-1)/2)
    data.ptrn(idx).numharmon = fix(num);
    data.cfg.ptrn.angles(idx).numharmon = fix(num);
%     data = showPreview(data,'numharmon');
end
set(h,'String',data.ptrn(idx).numharmon);
updateDlg(data);

%--------------------------------------------------------------------------
function btnPreview_Callback(h,eventdata,data)
%--------------------------------------------------------------------------
data.preview = h.Value;
switch h.String
    case 'Preview'
        data = showPreview(data,'preview');
        h.String = 'Refresh';
    case 'Refresh'
        data = showPreview(data,'refresh');
end
updateDlg(data,'on');

%--------------------------------------------------------------------------
function data = showPreview(data,eventdata)
%--------------------------------------------------------------------------
if ~data.preview
    return
end

% disable buttons
updateDlg(data,'off');

% show peaks
data.cfg.plotpeaks = 1;

% figures position
sc = get(0,'screensize');
nRows = ceil(length(data.ptrn)/3);
nCols = ceil(length(data.ptrn)/nRows);
sbpSize = round(sc(4)/3);
H = nRows*sbpSize+(nRows+1)*35;
W = nCols*sbpSize+(nCols+1)*10;
figSize = [round((sc(3)-W)/2),sc(4)-H-93,W,H];

% create figure
if ~ishandle(data.hndl.figPreview)
    data.hndl.figPreview = figure('Name','Spot finder preview',...
        'Tag','figPreview','NumberTitle','off','Position',figSize,'Resize','off',...
        'DeleteFcn',sprintf('setFindPeaks(''figPreview_onquit'',%f,guidata(%f))',...
        data.hndl.dlgFindPeaks,data.hndl.dlgFindPeaks));
end

% for all pattern orientations  (data.ptrn = ro + angle desription)
figure(data.hndl.figPreview);
for I = 1:length(data.ptrn)
    % find peaks
    [x,y] = ind2sub([nCols,nRows],I);
    ax = subplot(nRows,nCols,I);
%     title(sprintf('Angle: (%.0f°)',data.ptrn(I).angle));
    set(ax,'Units','Pixels','Position',...
        [x*10+(x-1)*sbpSize,...
        10+(nRows-y)*round(H/nRows),...
        sbpSize,sbpSize]);
    
    sim_findpeaks(data.imfft{data.ptrn(I).idx},data.cfg.sim.spotfindermethod,...
        data.ptrn(I),data.calinfo,data.cfg,I,ax);
    
    % update preview and data
    drawnow;
end

%--------------------------------------------------------------------------
function figPreview_onquit(h,data)
%--------------------------------------------------------------------------
data.hndl.figPreview = -1;
data.hndl.btnPreview.String = 'Preview';
updateDlg(data);

%--------------------------------------------------------------------------
function btnDefaults_Callback(h,eventdata,data)
%--------------------------------------------------------------------------
cfg = config;
cfg.db.spotfinder.radius = repmat(cfg.db.spotfinder.radius,length(data.ptrn),1);

% spotfinder method
data.cfg.db.spotfinder = cfg.db.spotfinder;
if ~isempty(data.calinfo)
    data.cfg.sim.spotfindermethod = spotfinder_method_calibration;
else
    data.cfg.sim.spotfindermethod = spotfinder_method_spotfinder(data.cfg.db.spotfinder);
end

% weights on harmonics
numharmondefault = min(fix(([data.ptrn.num] - 1)/2));
for I = 1:length(data.ptrn)
    data.ptrn(I).numharmon = numharmondefault;
end

% update preview and data
updateDlg(data,'on');

%--------------------------------------------------------------------------
function btnOK_Callback(h,eventdata,datalocal)
%--------------------------------------------------------------------------
% load main data
global data
updateDlg(datalocal,'off');

if (~isfield(data.cfg,'imfft') || isempty(data.cfg.imfft)) && ...
        isfield(datalocal,'imfft')
    data.cfg.imfft = datalocal.imfft;
end

% set method
if ~isequaln(data.cfg.sim.spotfindermethod,datalocal.cfg.sim.spotfindermethod)
    data.ptrninfo.MaskOn = [];
    if isfield(data,'ptrn'), data = rmfield(data,'ptrn'); end
    
    data.cfg.sim.spotfindermethod = datalocal.cfg.sim.spotfindermethod;
    data.cfg.db.spotfinder = datalocal.cfg.db.spotfinder;
    
    % set # harmonics
    
    for I = 1:length(datalocal.ptrn)
        data.cfg.ptrn.angles(I).numharmon = datalocal.ptrn(I).numharmon;
    end
end

% close dialog
close(datalocal.hndl.dlgFindPeaks);

%--------------------------------------------------------------------------
function btnCancel_Callback(h,eventdata,data)
%--------------------------------------------------------------------------
close(data.hndl.dlgFindPeaks);

%--------------------------------------------------------------------------
function dlg_onquit(h,eventdata,data)
%--------------------------------------------------------------------------
close(data.hndl.figPreview(ishandle(data.hndl.figPreview)));
rmappdata(data.hndl.dlgFindPeaks,'UsedByGUIData_m');

%--------------------------------------------------------------------------
function data = btnEnable(data,state)
%--------------------------------------------------------------------------

% enable calibration if applicable
if ~isempty(data.calinfo)
    set(data.hndl.radioCalibr,'Enable',state);
else
    set(data.hndl.radioCalibr,'Enable','off');
end
set(data.hndl.radioSpotfinder,'Enable',state);
% select method
if strcmp(data.cfg.sim.spotfindermethod.type,'calibration')
    set(data.hndl.radioMethod,'SelectedObject',data.hndl.radioCalibr);
else
    set(data.hndl.radioMethod,'SelectedObject',data.hndl.radioSpotfinder);
end

% fill spotfinder settings
set(data.hndl.popFilter,'Value',find(strcmp(data.cfg.db.spotfinder.selection.filter,{data.cfg.db.spotfinder.filter.type})));
set(data.hndl.popDetector,'Value',find(strcmp(data.cfg.db.spotfinder.selection.detector,{data.cfg.db.spotfinder.detector.type})));
set(data.hndl.popEstimator,'Value',find(strcmp(data.cfg.db.spotfinder.selection.estimator,{data.cfg.db.spotfinder.estimator.type})));
if strcmp(state,'on')
    % remove parameters from menu
    delete(findobj(data.hndl.SpotFinder,'-depth',1,'Tag','txtParamName'))
    delete(findobj(data.hndl.SpotFinder,'-depth',1,'Tag','editParamVal'))
    % and create new
    data = setSpotFinderparams(data.hndl.popFilter,'filter',data);
    data = setSpotFinderparams(data.hndl.popDetector,'detector',data);
    data = setSpotFinderparams(data.hndl.popEstimator,'estimator',data);
end

% enable/disable spotfinder
if strcmp(data.cfg.sim.spotfindermethod.type,'calibration')
    set(data.hndl.popFilter,'Enable','off');
    set(data.hndl.popDetector,'Enable','off');
    set(data.hndl.popEstimator,'Enable','off');
    set(data.hndl.filter.editParamVal,'Enable','off');
    set(data.hndl.detector.editParamVal,'Enable','off');
    set(data.hndl.estimator.editParamVal,'Enable','off');
    for I = 1:length(data.ptrn)
    	set(data.hndl.editRadius(I),'Enable','off');
    end
    set(data.hndl.chkRadius,'Enable','off');
else
    set(data.hndl.popFilter,'Enable',state);
    set(data.hndl.popDetector,'Enable',state);
    set(data.hndl.popEstimator,'Enable',state);
    set(data.hndl.filter.editParamVal,'Enable',state);
    set(data.hndl.detector.editParamVal,'Enable',state);
    set(data.hndl.estimator.editParamVal,'Enable',state);
    for I = 1:length(data.ptrn)
        if data.cfg.db.spotfinder.radiusequal && I>1
            set(data.hndl.editRadius(length(data.ptrn)-I+1),'Enable','off');
        else
            set(data.hndl.editRadius(length(data.ptrn)-I+1),'Enable',state);
        end
    end
    set(data.hndl.chkRadius,'Enable',state);
end

for I = 1:length(data.ptrn)
    tmp = 1e3*data.cfg.sim.otf.params.resolution*data.cfg.db.spotfinder.radius(I);
    set(data.hndl.editRadius(length(data.ptrn)-I+1),'String',tmp);
    % set(data.hndl.editRadius(length(data.ptrn)-I+1),'String',data.cfg.db.spotfinder.radius(I));
    set(data.hndl.editNumHarmon(length(data.ptrn)-I+1),'String',data.ptrn(I).numharmon);
end

set(data.hndl.chkRadius,'Value',data.cfg.db.spotfinder.radiusequal);
set(data.hndl.editNumHarmon,'Enable',state);
set(data.hndl.btnPreview,'Enable',state);
set(data.hndl.btnDefaults,'Enable',state);
set(data.hndl.btnCancel,'Enable',state);
set(data.hndl.btnOK,'Enable',state);

% update menu
drawnow;

%--------------------------------------------------------------------------
function updateDlg(data,state)
%--------------------------------------------------------------------------
if nargin < 2,state = 'on'; end

if nargin > 1
    data = btnEnable(data,state);
end

if strcmp(state,'on')
    guidata(data.hndl.dlgFindPeaks,data);
end

%eof