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

%-----------------------------------------------------------------------------
function hmain = createDlg(imginfo, ptrninfo, calinfo, cfg)
%-----------------------------------------------------------------------------

dimload;
height = 2*dlgmargin + 3*hTitle + 9*hLine;
width = 475;

% add number of harmonics into running order
[data.ptrn, numangles] = ptrnchecklines(ptrninfo, cfg.ptrn.ro);
[data.ptrn(:).enable] = deal([]);
[data.ptrn(:).numharmon] = deal([]);
for I = 1:numangles
    data.ptrn(I).numharmon = cfg.ptrn.angles(I).numharmon;
    data.ptrn(I).enable = cfg.ptrn.angles(I).enable;
end

% ----------- Spot finder dialog -----------

psiz = get(0,'ScreenSize');
hmain = figure('Name', 'Finding peaks in FFT', 'Tag', 'dlgFindPeaks', 'Resize','off', 'WindowStyle', 'modal', ...
    'Units', 'pixels', 'Position', [(psiz(3)-width)/2, (psiz(4)-height)/2, width, height], 'HandleVisibility','off', ...
    'MenuBar','none','NumberTitle','off','DeleteFcn', 'setFindPeaks(''dlg_onquit'',gcbo,[],guidata(gcbo))','Color', bkgcolor);
psiz = get(hmain,'Position'); psiz(1:2) = [0 height]; top = psiz(4) - hTitle - dlgmargin;

% ----------- Method  -----------

height = hTitle+2*dlgmargin+2*hLine;
hndl = uibuttongroup('Parent', hmain, 'Units', 'pixels', 'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], 'Title', 'Method', ...
    'Tag', 'radioMethod', 'SelectionChangeFcn','setFindPeaks(''radialMethod_Callback'',gcbo,''calibration'',guidata(gcbo))');
psiz = get(hndl,'Position'); top = psiz(4) - hTitle - dlgmargin;

uicontrol('Parent',hndl, 'Style', 'radio', 'String', 'Calibration', ...
    'Tag', 'radioCalibr', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-1*hLine, 200, hPopup]);

uicontrol('Parent',hndl, 'Style', 'radio', 'String', 'Spot finder (using data)', ...
    'Tag', 'radioSpotfinder', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-2*hLine, 200, hPopup]);

% ----------- Spot finder  -----------

height = hTitle+2*dlgmargin+4*hLine;
hndl = uipanel('Parent', hmain, 'Tag','SpotFinder','Units', 'pixels', 'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], 'Title', 'Spot Finder');
psiz = get(hndl,'Position'); top = psiz(4) - hTitle - dlgmargin;

uicontrol('Parent',hndl, 'Style', 'text', 'String', 'Filter:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-1*hLine, 60, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hndl, 'Style', 'popupmenu', 'String', {cfg.db.spotfinder.filter.name}, ...
    'Tag', 'popFilter', ...
    'Callback', 'setFindPeaks(''popSpotFinder_Callback'',gcbo,''filter'',guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [dlgmargin+60, top-1*hLine, 120, hPopup], ...
    'BackgroundColor', 'w');

uicontrol('Parent',hndl, 'Style', 'text', 'String', 'Detector:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-2*hLine, 60, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hndl, 'Style', 'popupmenu', 'String', {cfg.db.spotfinder.detector.name}, ...
    'Tag', 'popDetector', ...
    'Callback', 'setFindPeaks(''popSpotFinder_Callback'',gcbo,''detector'',guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [dlgmargin+60, top-2*hLine, 120, hPopup], ...
    'BackgroundColor', 'w');

uicontrol('Parent',hndl, 'Style', 'text', 'String', 'Estimator:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-3*hLine, 60, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hndl, 'Style', 'popupmenu', 'String', {cfg.db.spotfinder.estimator.name}, ...
    'Tag', 'popEstimator', ...
    'Callback', 'setFindPeaks(''popSpotFinder_Callback'',gcbo,''estimator'',guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [dlgmargin+60, top-3*hLine, 120, hPopup], ...
    'BackgroundColor', 'w');

uicontrol('Parent',hndl, 'Style', 'text', 'String', 'Radius:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-4*hLine, 60, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hndl, 'Style', 'edit', 'String', cfg.db.spotfinder.radius, ...
    'Tag', 'editRadius', ...
    'Callback', 'setFindPeaks(''editRadius_Callback'',gcbo,''radius'',guidata(gcbo))',  ...
    'Units', 'pixels', 'Position', [dlgmargin+60, top-4*hLine, 60, hTxt], ...
    'BackgroundColor','w');


% ----------- Harmonics  -----------

height = hTitle+2*dlgmargin+1*hLine;
hndl = uipanel('Parent', hmain, 'Units', 'pixels', 'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], 'Title', 'Number of harmonics');
psiz = get(hndl,'Position'); top = psiz(4) - hTitle - dlgmargin;

% weights on harmonics
for I = numangles:-1:1
    % harmonic
    uicontrol('Parent',hndl, 'Style', 'text', 'String', sprintf('%.0f:', data.ptrn(I).angle), ...
        'Units', 'pixels', 'Position',  [dlgmargin+(I-1)*60, top-hLine,  25, hTxt], ...
        'HorizontalAlignment','right');
    % edit box for weight
    uicontrol('Parent',hndl, 'Style', 'edit', 'String', '', ...
        'Tag', 'editNumHarmon', ...
        'Callback', sprintf('setFindPeaks(''editNumHarmon_Callback'',gcbo,%d,guidata(gcbo))',I),  ...
        'Units', 'pixels', 'Position', [dlgmargin+(I-1)*60+28, top-hLine, 30, hEdtBx], ...
        'BackgroundColor','w');
end

% ----------- Preview, Cancel, OK -----------

uicontrol('Parent',hmain, 'Style','checkbox','String', 'Preview', ...
    'Tag', 'chkbxPreview', ...
    'Callback', 'setFindPeaks(''chkbxPreview_Callback'',gcbo,[],guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [dlgmargin, dlgmargin, 100, hChkBx],'Value',0);

% use defaults from main menu
uicontrol('Parent',hmain, 'Style', 'pushbutton', 'String', 'Defaults', ...
    'Tag', 'btnDefaults', ...
    'Callback', 'setFindPeaks(''btnDefaults_Callback'',gcbo,[],guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [width-dlgmargin-330, dlgmargin, 100, hBtn]);

uicontrol('Parent',hmain, 'Style', 'pushbutton', 'String', 'Cancel', ...
    'Tag', 'btnCancel', ...
    'Callback', 'setFindPeaks(''btnCancel_Callback'',gcbo,[],guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [width-dlgmargin-200, dlgmargin, 100, hBtn]);

uicontrol('Parent',hmain, 'Style', 'pushbutton', 'String', 'OK', ...
    'Tag', 'btnOK',...
    'Callback', 'setFindPeaks(''btnOK_Callback'',gcbo,[],guidata(gcbo))', ...
    'Units', 'pixels', 'Position', [width-dlgmargin-100, dlgmargin, 100, hBtn]);

% ----------- Init -----------

% init handles
data.hndl = guihandles(hmain);
data.hndl.figPreview = repmat(-1,1,numangles);
% make a local copy of variables and settings from dlgMain
data.imginfo = imginfo;
data.calinfo = calinfo;
data.ptrninfo = ptrninfo;
data.cfg = cfg;

data.preview = 0;
data.IM = []; % reset image

% update
updateDlg(data,'on');

%-----------------------------------------------------------------------------
function radialMethod_Callback(h, eventdata, data)
%-----------------------------------------------------------------------------
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
% reset image
data.IM = [];
% preview
data = showPreview(data,'method');
% update
updateDlg(data,'on');

%-----------------------------------------------------------------------------
function popSpotFinder_Callback(h, eventdata, data)
%-----------------------------------------------------------------------------
% get selection
idx = get(h, 'Value');
% change method
data.cfg.db.spotfinder.selection.(eventdata) = data.cfg.db.spotfinder.(eventdata)(idx).type;
data.cfg.sim.spotfindermethod = spotfinder_method_spotfinder(data.cfg.db.spotfinder);
% show preview
data = showPreview(data,'spotfinder');
% update
updateDlg(data,'on');

%-----------------------------------------------------------------------------
function editParamVal_Callback(h, eventdata, parname, data)
%-----------------------------------------------------------------------------
idx = strcmp(data.cfg.db.spotfinder.selection.(eventdata), {data.cfg.db.spotfinder.(eventdata).type});
if strcmp(parname,'threshold')
    str = get(h, 'String');
    data.cfg.db.spotfinder.(eventdata)(idx).params.threshold.params.fnc = str;
    data.cfg.sim.spotfindermethod.params.(eventdata).params.threshold.params.fnc = str;
    data = showPreview(data,'spotfinderparam');
else
    num = str2double(strrep(get(h, 'String'),',','.'));
    if ~isnan(num)
        if strcmp(parname,'strel')
            data.cfg.db.spotfinder.(eventdata)(idx).params.(parname){2} = num;
        else
            data.cfg.db.spotfinder.(eventdata)(idx).params.(parname) = num;
        end
        data.cfg.sim.spotfindermethod.params.(eventdata).params.(parname) = num;
        data = showPreview(data,'spotfinderparam');
    end
    % update field
    %   set(h, 'String', data.cfg.db.spotfinder.(eventdata)(idx).params.(parname));
end
updateDlg(data,'on');

%-----------------------------------------------------------------------------
function data = setSpotFinderparams(h, eventdata, data)
%-----------------------------------------------------------------------------

data.hndl.(eventdata).txtParamName = [];
data.hndl.(eventdata).editParamVal = [];

% show parameters settings
dimload;

pos = get(h,'Position');
hparent = get(h,'Parent');

idx = strcmp(data.cfg.db.spotfinder.selection.(eventdata), {data.cfg.db.spotfinder.(eventdata).type});

if ~isempty(data.cfg.db.spotfinder.(eventdata)(idx).params)
    parname = setdiff(fieldnames(data.cfg.db.spotfinder.(eventdata)(idx).params), {'dim','ge','samples'});
    if any(strcmp(data.cfg.db.spotfinder.(eventdata)(idx).type,{'dao','daoint','dog','dogint','gauss','gaussint','wavelet'}))
        parname = setdiff(parname, {'size'});
    end
    for I = 1:length(parname)
        % param name
        data.hndl.(eventdata).txtParamName = [ ...
            uicontrol('Parent',hparent, 'Style', 'text', 'String', [parname{I} ':'], ...
            'Tag', 'txtParamName', ...
            'Units', 'pixels', 'Position',  [190+(I-1)*90, pos(2), 50, hTxt], ...
            'HorizontalAlignment','right'), ...
            data.hndl.(eventdata).txtParamName];
        % param value
        if strcmp(parname{I},'threshold')
            data.hndl.(eventdata).editParamVal = [ ...
                uicontrol('Parent',hparent, 'Style', 'edit', 'String', data.cfg.db.spotfinder.(eventdata)(idx).params.(parname{I}).params.fnc, ...
                'Tag', 'editParamVal', ...
                'Callback', sprintf('setFindPeaks(''editParamVal_Callback'',gcbo,''%s'',''%s'',guidata(gcbo))',eventdata,parname{I}),  ...
                'Units', 'pixels', 'Position', [245+(I-1)*90, pos(2), 120, hEdtBx], ...
                'BackgroundColor','w', 'HorizontalAlignment','left'), ...
                data.hndl.(eventdata).editParamVal];
        else
            if strcmp(parname{I},'strel')
                str = data.cfg.db.spotfinder.(eventdata)(idx).params.(parname{I}){2};
            else
                str = data.cfg.db.spotfinder.(eventdata)(idx).params.(parname{I});
            end
            data.hndl.(eventdata).editParamVal = [ ...
                uicontrol('Parent',hparent, 'Style', 'edit', 'String', str, ...
                'Tag', 'editParamVal', ...
                'Callback', sprintf('setFindPeaks(''editParamVal_Callback'',gcbo,''%s'',''%s'',guidata(gcbo))',eventdata,parname{I}),  ...
                'Units', 'pixels', 'Position', [245+(I-1)*90, pos(2), 30, hEdtBx], ...
                'BackgroundColor','w'), ...
                data.hndl.(eventdata).editParamVal];
        end
    end
end

%-----------------------------------------------------------------------------
function editRadius_Callback(h, eventdata, data)
%-----------------------------------------------------------------------------
num = str2double(strrep(get(h, 'String'),',','.'));
if ~isnan(num) && num > 0
    data.cfg.sim.spotfindermethod.params.(eventdata) = num;
    data.cfg.db.spotfinder.(eventdata) = num;
    data = showPreview(data,'radius');
end
set(h, 'String', data.cfg.sim.spotfindermethod.params.(eventdata));
updateDlg(data,'on');

%-----------------------------------------------------------------------------
function editNumHarmon_Callback(h, idx, data)
%-----------------------------------------------------------------------------
num = str2double(strrep(get(h, 'String'),',','.'));
if ~isnan(num) && num >= 0 && num <= 4 && num <= fix((data.ptrn(idx).num-1)/2)
    data.ptrn(idx).numharmon = fix(num);
    data = showPreview(data,'numharmon');
end
set(h, 'String', data.ptrn(idx).numharmon);
updateDlg(data,'on');

%-----------------------------------------------------------------------------
function chkbxPreview_Callback(h, eventdata, data)
%-----------------------------------------------------------------------------
data.preview = get(h, 'Value');
if data.preview
    data = showPreview(data,'preview');
else
    close(data.hndl.figPreview(ishandle(data.hndl.figPreview)));
end
updateDlg(data,'on');

%-----------------------------------------------------------------------------
function data = showPreview(data, eventdata)
%-----------------------------------------------------------------------------

if ~data.preview
    return
end

% disable buttons
updateDlg(data, 'off');

%show peaks
data.cfg.plotpeaks = 1;

% for all pattern orientations  (data.ptrn = ro + angle desription)
for I = 1:length(data.ptrn)
    
    if ~data.ptrn(I).enable
        continue
    end
    
    % create figure
    if ~ishandle(data.hndl.figPreview(I))
        data.hndl.figPreview(I) = figure('Name', sprintf('Spot finder preview (%.0f°)', data.ptrn(I).angle), ...
            'Tag', 'figPreview', 'NumberTitle', 'off');%,...
        %'DeleteFcn', sprintf('setFindPeaks(''figPreview_onquit'',%f,%d,guidata(%f))',data.hndl.dlgFindPeaks, I, data.hndl.dlgFindPeaks));
    else
        figure(data.hndl.figPreview(I)); clf
    end
    
    % load image data and compute FFT spectra
    if isempty(data.IM)  || length(data.IM) < I
        data.IM{I} = sim_findpeaksloadimage(data.imginfo, data.ptrn(I), data.cfg);
    end
    
    % find peaks
    sim_findpeaks(data.IM{I}, data.cfg.sim.spotfindermethod, data.ptrn(I), data.calinfo, data.cfg);
    
    drawnow;
end

%-----------------------------------------------------------------------------
function figPreview_onquit(h, idx, data)
%-----------------------------------------------------------------------------
data.hndl.figPreview(idx) = -1;
updateDlg(data);

%-----------------------------------------------------------------------------
function btnDefaults_Callback(h, eventdata, data)
%-----------------------------------------------------------------------------
cfg = config;

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
data.IM = [];
data = showPreview(data,'defaults');
updateDlg(data,'on');

%-----------------------------------------------------------------------------
function btnOK_Callback(h, eventdata, datalocal)
%-----------------------------------------------------------------------------
% load main data
global data
% set method
data.cfg.sim.spotfindermethod = datalocal.cfg.sim.spotfindermethod;
data.cfg.db.spotfinder = datalocal.cfg.db.spotfinder;
% set # harmonics
for I = 1:length(datalocal.ptrn)
    data.cfg.ptrn.angles(I).numharmon = datalocal.ptrn(I).numharmon;
end
% close dialog
close(datalocal.hndl.dlgFindPeaks);

%-----------------------------------------------------------------------------
function btnCancel_Callback(h, eventdata, data)
%-----------------------------------------------------------------------------
close(data.hndl.dlgFindPeaks);

%-----------------------------------------------------------------------------
function dlg_onquit(h, eventdata, data)
%-----------------------------------------------------------------------------
close(data.hndl.figPreview(ishandle(data.hndl.figPreview)));
rmappdata(data.hndl.dlgFindPeaks, 'UsedByGUIData_m');

%-----------------------------------------------------------------------------
function data = btnEnable(data, state)
%-----------------------------------------------------------------------------

% enable calibration if applicable
if ~isempty(data.calinfo)
    set(data.hndl.radioCalibr, 'Enable', state);
else
    set(data.hndl.radioCalibr, 'Enable', 'off');
end
set(data.hndl.radioSpotfinder, 'Enable', state);
% select method
if strcmp(data.cfg.sim.spotfindermethod.type,'calibration')
    set(data.hndl.radioMethod,'SelectedObject',data.hndl.radioCalibr);
else
    set(data.hndl.radioMethod,'SelectedObject',data.hndl.radioSpotfinder);
end

% fill spotfinder settings
set(data.hndl.popFilter, 'Value', find(strcmp(data.cfg.db.spotfinder.selection.filter,{data.cfg.db.spotfinder.filter.type})));
set(data.hndl.popDetector, 'Value', find(strcmp(data.cfg.db.spotfinder.selection.detector,{data.cfg.db.spotfinder.detector.type})));
set(data.hndl.popEstimator, 'Value', find(strcmp(data.cfg.db.spotfinder.selection.estimator,{data.cfg.db.spotfinder.estimator.type})));
if strcmp(state,'on')
    % remove parameters from menu
    delete(findobj(data.hndl.SpotFinder,'-depth',1,'Tag','txtParamName'))
    delete(findobj(data.hndl.SpotFinder,'-depth',1,'Tag','editParamVal'))
    % and create new
    data = setSpotFinderparams(data.hndl.popFilter, 'filter', data);
    data = setSpotFinderparams(data.hndl.popDetector, 'detector', data);
    data = setSpotFinderparams(data.hndl.popEstimator, 'estimator', data);
end

% enable/disable spotfinder
if strcmp(data.cfg.sim.spotfindermethod.type,'calibration')
    set(data.hndl.popFilter, 'Enable', 'off');
    set(data.hndl.popDetector, 'Enable', 'off');
    set(data.hndl.popEstimator, 'Enable', 'off');
    set(data.hndl.filter.editParamVal, 'Enable', 'off');
    set(data.hndl.detector.editParamVal, 'Enable', 'off');
    set(data.hndl.estimator.editParamVal, 'Enable', 'off');
    set(data.hndl.editRadius, 'Enable', 'off');
else
    set(data.hndl.popFilter, 'Enable', state);
    set(data.hndl.popDetector, 'Enable', state);
    set(data.hndl.popEstimator, 'Enable', state);
    set(data.hndl.filter.editParamVal, 'Enable', state);
    set(data.hndl.detector.editParamVal, 'Enable', state);
    set(data.hndl.estimator.editParamVal, 'Enable', state);
    set(data.hndl.editRadius, 'Enable', state);
end

% weights on harmonics
for I = 1:length(data.ptrn)
    set(data.hndl.editNumHarmon(I), 'String', data.ptrn(I).numharmon);
end

set(data.hndl.editNumHarmon, 'Enable', state);
set(data.hndl.chkbxPreview, 'Enable', state);
set(data.hndl.btnDefaults, 'Enable', state);
set(data.hndl.btnCancel, 'Enable', state);
set(data.hndl.btnOK, 'Enable', state);

% update menu
drawnow;

%-----------------------------------------------------------------------------
function updateDlg(data, state)
%-----------------------------------------------------------------------------
if nargin < 2, state = 'on'; end

if nargin > 1
    data = btnEnable(data, state);
end

if strcmp(state,'on')
    guidata(data.hndl.dlgFindPeaks, data);
end

%eof