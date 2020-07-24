% Copyright © 2013,2014,2015 Pavel Krizek, Tomas Lukes, lukestom@fel.cvut.cz
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

function varargout = SIMToolbox(varargin)

if nargin == 0 % LAUNCH GUI
    
    if ~exist('config.m','file')
        errordlg('Configuration file is missing!','File not found','modal');
        return;
    end
    
    % run just one copy of the program
    if isappdata(0,'SIMrun')
        disp('SIMToolbox is running');
        %      return;
    else
        if (~isdeployed) % protect calls to ADDPATH - do not execute by compiled standalone applications
            
            addpath(path);
            addpath(genpath('utils'));
            javaaddpath(['utils' filesep 'yaml' filesep 'java' filesep 'snakeyaml-1.9.jar']);
        end
        setappdata(0,'SIMrun',1);
    end
    
    % load default configuration
    cfg = config();
    
    % default path settings for datadir
    if ~isdir(cfg.datadir)
        cfg.datadir = pwd;
    end;
    
    % default path settings for calibration file
    if ~(isdir(cfg.cal.calibr) || isfile(cfg.cal.calibr))
        cfg.cal.calibr = cfg.datadir;
    end
    
    % default path settings for pattern repz
    if ~(isdir(cfg.ptrn.repz) || isfile(cfg.ptrn.repz))
        cfg.ptrn.repz = cfg.datadir;
    end
    
    % turn off some strange message when oppening tiff
    warning off MATLAB:imagesci:tiffmexutils:libtiffErrorAsWarning
    
    createDlgMain(cfg);
    
else % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try % FEVAL switchyard
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:});
        else
            feval(varargin{:});
        end
    catch err
        printerror(err);
    end
    
end

%-----------------------------------------------------------------------------
function dlgMain_onquit(~,~)
%-----------------------------------------------------------------------------
global data
% remove repertoire
ptrnclose(data.ptrninfo);
closePreview();
% clear user data
clear global data
rmpath(genpath('utils'));
rmappdata(0,'SIMrun');
% rmappdata(h, 'UsedByGUIData_m');

%=============================================================================
function createDlgMain(cfg)
%============================================================================
global data

% height
dimload;
numvsm = max(4,length(cfg.db.vsm));
mainheight = 460+numvsm*hLine;

% ----------- CREATE MAIN DIALOG --------------

psiz = get(0,'ScreenSize');
hmain = figure('Name', sprintf('SIM Toolbox (ver. %s)',cfg.ver), 'Tag', 'dlgMain', 'Resize','off', ...
    'Units', 'pixels', 'Position', [(psiz(3)-2*width)/2, (psiz(4)-mainheight)/2, 2*width, mainheight], 'HandleVisibility','off', ...
    'MenuBar','none','NumberTitle','off','DeleteFcn', 'SIMToolbox(''dlgMain_onquit'',gcbo,[])','Color', bkgcolor);
psiz = get(hmain,'Position'); psiz(1:2) = [0 mainheight];

% ----------- LOGO ----------------------------

logoMTG = imread(['license' filesep 'sim_logo.bmp']);
[imHeight, imWidth, ~] = size(logoMTG);
hlogo = axes('Parent',hmain, ...
    'Tag', 'axesLogo', ...
    'Units', 'pixels', 'Position', [(width-imWidth)/2, (psiz(2)-imHeight-20), imWidth, imHeight]);
image(logoMTG,'Parent',hlogo);
set(hlogo,'xtick',[],'ytick',[]);
psiz = get(hlogo,'Position'); psiz(2) = psiz(2)-20;

% ----------- DATA ----------------------------

height = hTitle+3*dlgmargin+2*hLine+4*hTxtInf;
hdata = uipanel('Parent', hmain, 'Units', 'pixels', ...
    'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], ...
    'Title', 'Data');
psiz = get(hdata,'Position'); top = psiz(4) - hTitle - dlgmargin;

% prepare data dir
uicontrol('Parent',hdata, 'Style', 'pushbutton', 'String', 'Prepare data dir', ...
    'Tag', 'btnPtrnEstimate', ...
    'Callback', 'SIMToolbox(''btnPtrnEstimate_Callback'',gcbo,''[]'')', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-hLine, 100, hBtn]);

% data dir
uicontrol('Parent',hdata, 'Style', 'pushbutton', 'String', 'Data directory:', ...
    'Tag', 'btnDataChangeDir', ...
    'Callback', 'SIMToolbox(''btnDataChangeDir_Callback'',gcbo,''data'')', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-2*hLine, 100, hBtn]);

uicontrol('Parent',hdata, 'Style', 'edit', ...
    'Tag', 'editDataDir', ...
    'Callback', 'SIMToolbox(''editDataDir_Callback'',gcbo,''data'')', ...
    'Units', 'pixels', 'Position', [dlgmargin+100, top-2*hLine, psiz(3)-3*dlgmargin-100, hEdtBx], ...
    'HorizontalAlignment', 'left', 'BackgroundColor','w');

% file info
uicontrol('Parent',hdata, 'Style', 'text', ...
    'Tag', 'txtDataInfo', ...
    'Units', 'pixels', 'Position', [2*dlgmargin, top-2*hLine-4*hTxtInf-dlgmargin,  psiz(3)-2*dlgmargin-65, 4*hTxtInf], ...
    'HorizontalAlignment','left', 'FontName','Courier');

uicontrol('Parent',hdata, 'Style', 'text', 'String', '', ...
    'Tag', 'txtDataDim', ...
    'Units', 'pixels', 'Position', [psiz(3)-65-dlgmargin, top-2*hLine-4*hTxtInf-dlgmargin, 60, 3*hTxtInf], ...
    'HorizontalAlignment','left', 'FontName','Courier');

% ----------- PATTERNS & CALIBRATION ----------

height = hTitle+3*dlgmargin+5*hLine;
hptrn = uipanel('Parent', hmain, 'Units', 'pixels', ...
    'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], ...
    'Title', 'Illumination pattern and calibration');
psiz = get(hptrn,'Position'); top = psiz(4) - hTitle - dlgmargin;

% calibration
uicontrol('Parent',hptrn, 'Style', 'pushbutton', 'String', 'Calibration file:', ...
    'Tag', 'btnPtrnChangeCalibration', ...
    'Callback', 'SIMToolbox(''btnPtrnChangeCalibration_Callback'',gcbo,''cal'')', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-hLine, 100, hBtn]);

uicontrol('Parent',hptrn, 'Style', 'edit', ...
    'Tag', 'editPtrnCalibration', ...
    'Callback', 'SIMToolbox(''editPtrnCalibration_Callback'',gcbo,''cal'')', ...
    'Units', 'pixels', 'Position', [dlgmargin+100, top-hLine, 250, hEdtBx], ...
    'HorizontalAlignment', 'left', 'BackgroundColor','w');

% pattern
uicontrol('Parent',hptrn, 'Style', 'pushbutton', 'String', 'Pattern repz file:', ...
    'Tag', 'btnPtrnChangeRepz', ...
    'Callback', 'SIMToolbox(''btnPtrnChangeRepz_Callback'',gcbo,''ptrn'')', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-2*hLine, 100, hBtn]);

uicontrol('Parent',hptrn, 'Style', 'edit', ...
    'Tag', 'editPtrnRepz', ...
    'Callback', 'SIMToolbox(''editPtrnRepz_Callback'',gcbo,''ptrn'')', ...
    'Units', 'pixels', 'Position', [dlgmargin+100, top-2*hLine, 250, hEdtBx], ...
    'HorizontalAlignment', 'left', 'BackgroundColor','w');

% Running order
uicontrol('Parent',hptrn, 'Style', 'text', 'String', 'Running order:', ...
    'Units', 'pixels', 'Position', [2*dlgmargin, top-3*hLine,  100, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hptrn, 'Style', 'popupmenu', 'String', {''}, ...
    'Tag', 'popPtrnRunningOrder', ...
    'Callback', 'SIMToolbox(''popPtrnRunningOrder_Callback'',gcbo,''ro'')', ...
    'Units', 'pixels', 'Position', [dlgmargin+100, top-3*hLine, 250, hBtn], ...
    'BackgroundColor', 'w');

% angles
uicontrol('Parent',hptrn, 'Style', 'text', 'String', 'Use angles:', ...
    'Tag', 'txtPtrnAngles', ...
    'Units', 'pixels', 'Position', [2*dlgmargin, top-4*hLine+2,  80, hTxt], ...
    'HorizontalAlignment','left');

% pattern error
uicontrol('Parent',hptrn, 'Style', 'text', 'String', 'Pattern does not match the data!', ...
    'Tag', 'txtPtrnRepzError', ...
    'Units', 'pixels', 'Position', [2*dlgmargin, top-4*hLine+2,  psiz(3)-4*dlgmargin, hTxtInf], ...
    'HorizontalAlignment','left', 'FontName','Courier', 'ForegroundColor','red');

% pattern info
uicontrol('Parent',hptrn, 'Style', 'text', ...
    'Tag', 'txtPtrnRepzInfo', ...
    'Units', 'pixels', 'Position', [2*dlgmargin, top-5*hLine-dlgmargin,  psiz(3)-4*dlgmargin, 2*hTxtInf], ...
    'HorizontalAlignment','left', 'FontName','Courier');

% run chess board calibration
uicontrol('Parent',hptrn, 'Style', 'pushbutton', 'String', 'Run calibration', ...
    'Tag', 'btnPtrnRunCalibration', ...
    'Callback', 'SIMToolbox(''btnPtrnRunCalibration_Callback'',gcbo,''calprocess'')', ...
    'Units', 'pixels', 'Position', [width-4*dlgmargin-100, top-hLine, 100, hBtn]);

% Offset
uicontrol('Parent',hptrn, 'Style', 'text', 'String', 'Offset:', ...
    'Units', 'pixels', 'Position',  [psiz(3)-2*dlgmargin-70, top-2*hLine,  50, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hptrn, 'Style', 'edit', ...
    'Tag', 'editPtrnOffset', ...
    'Callback', 'SIMToolbox(''editPtrnOffset_Callback'',gcbo,[])',  ...
    'Units', 'pixels', 'Position', [psiz(3)-2*dlgmargin-30, top-2*hLine, 30, hBtn],...
    'HorizontalAlignment', 'left','BackgroundColor','w');

% Mask blurring
uicontrol('Parent',hptrn, 'Style', 'text', 'String', 'Blur:', ...
    'Units', 'pixels', 'Position',  [psiz(3)-2*dlgmargin-70, top-3*hLine,  50, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hptrn, 'Style', 'edit', ...
    'Tag', 'editPtrnSigmaBlure', ...
    'Callback', 'SIMToolbox(''editPtrnSigmaBlure_Callback'',gcbo,[])',  ...
    'Units', 'pixels', 'Position', [psiz(3)-2*dlgmargin-30, top-3*hLine, 30, hBtn],...
    'HorizontalAlignment', 'left','BackgroundColor','w');

% ----------- REFINE PATTERN ESTIMATION -------

height = hTitle+3*dlgmargin+1*hLine;
hptre = uipanel('Parent', hmain, 'Units', 'pixels', ...
    'Position', [dlgmargin, psiz(2)-height, width-2*dlgmargin, height], ...
    'Title', 'Refine pattern estimation');
psiz = get(hptre,'Position'); top = psiz(4) - hTitle - dlgmargin;

% Weights for spectral merging
uicontrol('Parent',hptre, 'Style', 'text', 'String', ...
    'Check if all peaks that correspond to the patterns are properly detected:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-1*hLine,  350, hTxt], ...
    'HorizontalAlignment','left');

% Peaks
uicontrol('Parent',hptre, 'Style', 'pushbutton', 'String', 'Find peaks', ...
    'Tag', 'btnSimFindPeaks', ...
    'Callback', 'SIMToolbox(''btnSimFindPeaks_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [width-4*dlgmargin-100, top-1*hLine, 100, hBtn]);

% ----------- Right side ----------------------
psiz = get(hmain,'Position'); psiz(1:2) = [0 mainheight];

% ----------- SIM PROCESSING OPTIONS ----------

txtwidth = 150;
height = hTitle+3*dlgmargin+5*hLine;
hsim = uipanel('Parent', hmain, 'Units', 'pixels', ...
    'Position',[width+dlgmargin, psiz(2)-height-10, width-2*dlgmargin, height], ...
    'Title', 'SR-SIM processing (Gustafsson)');
psiz = get(hsim,'Position'); top = psiz(4) - hTitle - dlgmargin;

% OTF
uicontrol('Parent',hsim, 'Style', 'text', 'String', 'OTF:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-1*hLine,  txtwidth, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hsim, 'Style', 'popupmenu', 'String', {cfg.db.otf.name}, ...
    'Tag', 'popSimOTF', ...
    'Callback', 'SIMToolbox(''popSim_Callback'',gcbo,''otf'')', ...
    'Units', 'pixels', 'Position', [dlgmargin+txtwidth, top-1*hLine, 120, hPopup], ...
    'BackgroundColor', 'w');

% apodizing function
uicontrol('Parent',hsim, 'Style', 'text', 'String', 'Apodizing function:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-2*hLine,  txtwidth, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hsim, 'Style', 'popupmenu', 'String', {cfg.db.apodize.name}, ...
    'Tag', 'popSimApodize', ...
    'Callback', 'SIMToolbox(''popSim_Callback'',gcbo,''apodize'')', ...
    'Units', 'pixels', 'Position', [dlgmargin+txtwidth, top-2*hLine, 120, hPopup], ...
    'BackgroundColor', 'w');

% weights on harmonics
uicontrol('Parent',hsim, 'Style', 'text', 'String', 'Weights on harmonics:', ...
    'Tag', 'textHarmonWeights', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-3*hLine,  txtwidth, hTxt], ...
    'HorizontalAlignment','left');

% wiener parameter
uicontrol('Parent',hsim, 'Style', 'text', 'String', 'Wiener parameter:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-4*hLine, txtwidth, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hsim, 'Style', 'edit', ...
    'Tag', 'editSimWiener', ...
    'Callback', 'SIMToolbox(''editSimWiener_Callback'',gcbo,[])',  ...
    'Units', 'pixels', 'Position', [dlgmargin+txtwidth, top-4*hLine, wEdtBx, hEdtBx], ...
    'BackgroundColor','w');

% Up-sampling 2x
uicontrol('Parent',hsim, 'Style','checkbox','String', 'Up-sampling 2x', ...
    'Tag', 'chkbxUpsampleSim', ...
    'Callback', 'SIMToolbox(''chkbxUpsampleSim_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [dlgmargin+180, top-5*hLine, txtwidth, hChkBx]);

% Enable SIM processing
uicontrol('Parent',hsim, 'Style','checkbox','String', 'Enable SR-SIM processing', ...
    'Tag', 'chkbxSimEnable', ...
    'Callback', 'SIMToolbox(''chkbxSimEnable_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-5*hLine, txtwidth, hChkBx]);

% ----------- MAP-SIM PROCESSING OPTIONS ------

height = hTitle+2*dlgmargin+6*hLine;
hmsm = uipanel('Parent', hmain, 'Units', 'pixels', ...
    'Position', [width+dlgmargin, psiz(2)-height, width-2*dlgmargin, height], ...
    'Title', 'MAP-SIM processing');
psiz = get(hmsm,'Position'); top = psiz(4) - hTitle - dlgmargin;

% Set the theoretical cut-off frequency (according to the acquisition settings)
uicontrol('Parent',hmsm, 'Style', 'text', 'String', 'Cut-off frequency:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-hLine,  100, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hmsm, 'Style', 'edit', ...
    'Tag', 'editMsmFc', ...
    'Callback', 'SIMToolbox(''editMsmFc_Callback'',gcbo,[])',  ...
    'Units', 'pixels', 'Position', [dlgmargin+txtwidth, top-hLine, wEdtBx, hBtn],...
    'HorizontalAlignment', 'left','BackgroundColor','w');

% Weights for spectral merging
uicontrol('Parent',hmsm, 'Style', 'text', 'String', 'Spectral merging:', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-2*hLine,  100, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hmsm, 'Style', 'edit', ...
    'Tag', 'editMsmMerging', ...
    'Callback', 'SIMToolbox(''editMsmMerging_Callback'',gcbo,[])',  ...
    'Units', 'pixels', 'Position', [dlgmargin+txtwidth, top-2*hLine, wEdtBx, hBtn],...
    'HorizontalAlignment', 'left','BackgroundColor','w');

% Enable MAP-SIM processing
uicontrol('Parent',hmsm, 'Style','checkbox','String', 'Enable MAP-SIM processing', ...
    'Tag', 'chkbxMapEnable', ...
    'Callback', 'SIMToolbox(''chkbxMsmEnable_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-3*hLine, 2*txtwidth, hChkBx]);

% Up-sampling 2x
uicontrol('Parent',hmsm, 'Style','checkbox','String', 'Up-sampling 2x', ...
    'Tag', 'chkbxUpsampleMap', ...
    'Callback', 'SIMToolbox(''chkbxUpsampleMap_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [dlgmargin+180, top-3*hLine, txtwidth, hChkBx]);

% Note for estimating patterns
uicontrol('Parent',hmsm, 'Style', 'text', 'String', ...
    'Note: MAP-SIM performs best if the calibration is known. Please check the pattern estimation "Find peaks".', ...
    'Units', 'pixels', 'Position',  [width-4*dlgmargin-150, top-3*hLine-3, 150, 4*hTxt], ...
    'HorizontalAlignment','left','Visible', 'off','Tag', 'txtMapNote');

% CPU vs. GPU (CUDA)
uicontrol('Parent',hmsm, 'Style','checkbox','String', 'CUDA (GPU)', ...
    'Tag', 'chkbxCudaMap', ...
    'Callback', 'SIMToolbox(''chkbxCudaMap_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-4*hLine, txtwidth, hChkBx]);

% CUDA test information
uicontrol('Parent',hmsm, 'Style', 'text', 'String', '', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-6.3*hLine, txtwidth, 3*hTxt], ...
    'HorizontalAlignment','left','Visible','on','Tag','txtCudaInfo');

% Set the initial Alpha
% uicontrol('Parent',hmsm, 'Style', 'text', 'String', 'Initial Alpha:', ...
%     'Units', 'pixels', 'Position',  [dlgmargin, top-5*hLine,  100, hTxt], ...
%     'HorizontalAlignment','left');
%
% uicontrol('Parent',hmsm, 'Style', 'edit', ...
%     'Tag', 'editMsmCudaAlpha', ...
%     'Callback', 'SIMToolbox(''editMsmCudaAlpha_Callback'',gcbo,[])',  ...
%     'Units', 'pixels', 'Position', [dlgmargin+txtwidth, top-5*hLine, wEdtBx, hBtn],...
%     'HorizontalAlignment', 'left','BackgroundColor','w');

% Set the maximum number of iterations allowed
% uicontrol('Parent',hmsm, 'Style', 'text', 'String', 'Max Iterations:', ...
%     'Units', 'pixels', 'Position',  [dlgmargin, top-6*hLine,  100, hTxt], ...
%     'HorizontalAlignment','left');
%
% uicontrol('Parent',hmsm, 'Style', 'edit', ...
%     'Tag', 'editMsmCudaMaxiter', ...
%     'Callback', 'SIMToolbox(''editMsmCudaMaxiter_Callback'',gcbo,[])',  ...
%     'Units', 'pixels', 'Position', [dlgmargin+txtwidth, top-6*hLine, wEdtBx, hBtn],...
%     'HorizontalAlignment', 'left','BackgroundColor','w');

% ----------- VSM PROCESSING OPTIONS ----------

height = hTitle+2*dlgmargin+numvsm*hLine;
hvsm = uipanel('Parent', hmain, 'Units', 'pixels', ...
    'Position', [width+dlgmargin, psiz(2)-height, width-2*dlgmargin, height], ...
    'Title', 'OS-SIM processing');
psiz = get(hvsm,'Position'); top = psiz(4) - hTitle - dlgmargin;

% VSM processing methods
for I = length(cfg.db.vsm):-1:1
    uicontrol('Parent',hvsm, 'Style','checkbox','String', cfg.db.vsm(I).name, ...
        'Tag', 'chkbxVsmEval', ...
        'Callback', sprintf('SIMToolbox(''chkbxVsmEval_Callback'',gcbo,%d)', I), ...
        'Units', 'pixels', 'Position', [dlgmargin, top-I*hLine, txtwidth, hChkBx]);
end

% Flat field correction
uicontrol('Parent',hvsm, 'Style','checkbox','String', 'Flat field correction', ...
    'Tag', 'chkbxVsmFlatField', ...
    'Callback', 'SIMToolbox(''chkbxVsmOptions_Callback'',gcbo,''flatfield'')', ...
    'Units', 'pixels', 'Position', [dlgmargin+txtwidth, top-hLine, txtwidth, hChkBx]);

% Stripe removal
uicontrol('Parent',hvsm, 'Style','checkbox','String', 'Stripe removal', ...
    'Tag', 'chkbxVsmStripeRemoval', ...
    'Callback', 'SIMToolbox(''chkbxVsmOptions_Callback'',gcbo,''striperemoval'')', ...
    'Units', 'pixels', 'Position', [dlgmargin+txtwidth, top-2*hLine, txtwidth, hChkBx]);

% Angles
uicontrol('Parent',hvsm, 'Style', 'text', 'String', 'Average angles:', ...
    'Tag', 'txtVsmAngles', ...
    'Units', 'pixels', 'Position',  [dlgmargin+txtwidth, top-3.3*hLine, txtwidth, hTxt], ...
    'HorizontalAlignment','left', 'Visible', 'off');

% ----------- SAVE OPTIONS --------------------

height = hTitle+2*dlgmargin+2*hLine;
hsave = uipanel('Parent', hmain, 'Units', 'pixels', ...
    'Position', [width+dlgmargin, psiz(2)-height, width-2*dlgmargin, height], ...
    'Title', 'Save options');
psiz = get(hsave,'Position'); top = psiz(4) - hTitle - dlgmargin;

% Image bit depth
uicontrol('Parent',hsave, 'Style', 'text', 'String', 'Bit depth:', ...
    'Tag', 'txtColorDepth', ...
    'Units', 'pixels', 'Position',  [dlgmargin, top-hLine, txtwidth, hTxt], ...
    'HorizontalAlignment','left', 'Visible', 'on');

% 16-bit
uicontrol('Parent',hsave, 'Style','checkbox','String', '16-bit', ...
    'Tag', 'chkbx16bit', ...
    'Callback', 'SIMToolbox(''chkbx16bit_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [dlgmargin+txtwidth/2, top-1*hLine, txtwidth, hChkBx]);

% 32-bit
uicontrol('Parent',hsave, 'Style','checkbox','String', '32-bit', ...
    'Tag', 'chkbx32bit', ...
    'Callback', 'SIMToolbox(''chkbx32bit_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [dlgmargin+5*txtwidth/6, top-1*hLine, txtwidth, hChkBx]);

% data dir
uicontrol('Parent',hsave, 'Style', 'pushbutton', 'String', 'Save directory:', ...
    'Tag', 'btnSaveChangeDir', ...
    'Callback', 'SIMToolbox(''btnSaveChangeDir_Callback'',gcbo,''data'')', ...
    'Units', 'pixels', 'Position', [dlgmargin, top-2*hLine, 100, hBtn]);

uicontrol('Parent',hsave, 'Style', 'edit', ...
    'Tag', 'editSaveDir', ...
    'Callback', 'SIMToolbox(''editSaveDir_Callback'',gcbo,''data'')', ...
    'Units', 'pixels', 'Position', [dlgmargin+100, top-2*hLine, psiz(3)-3*dlgmargin-100, hEdtBx], ...
    'HorizontalAlignment', 'left', 'BackgroundColor','w');

% ----------- COMMANDS -----------

% Reset button
uicontrol('Parent',hmain, 'Style', 'pushbutton', 'String', 'Reset', ...
    'Tag', 'btnReset', ...
    'Callback', 'SIMToolbox(''btnReset_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [width+dlgmargin, psiz(2)-3*dlgmargin-hBtn, 70, hBtn]);

% Preview button
uicontrol('Parent',hmain, 'Style', 'pushbutton', 'String', 'Preview', ...
    'Tag', 'btnPreview', ...
    'Callback', 'SIMToolbox(''btnPreview_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [width+dlgmargin+90, psiz(2)-3*dlgmargin-hBtn, 70, hBtn]);

% Preview - z
uicontrol('Parent',hmain, 'Style', 'text', 'String', 'z:', ...
    'Units', 'pixels', 'Position',  [width+dlgmargin+165, psiz(2)-3*dlgmargin-hBtn, 15, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hmain, 'Style', 'edit', ...
    'Tag', 'editPreviewZ', ...
    'Callback', 'SIMToolbox(''editPreview_Callback'',gcbo,''z'')',  ...
    'Units', 'pixels', 'Position', [width+dlgmargin+178, psiz(2)-3*dlgmargin-hBtn, 30, hEdtBx], ...
    'BackgroundColor','w');

% Preview - time
uicontrol('Parent',hmain, 'Style', 'text', 'String', 't:', ...
    'Units', 'pixels', 'Position',  [width+dlgmargin+210, psiz(2)-3*dlgmargin-hBtn, 15, hTxt], ...
    'HorizontalAlignment','left');

uicontrol('Parent',hmain, 'Style', 'edit', ...
    'Tag', 'editPreviewTime', ...
    'Callback', 'SIMToolbox(''editPreview_Callback'',gcbo,''t'')',  ...
    'Units', 'pixels', 'Position', [width+dlgmargin+223, psiz(2)-3*dlgmargin-hBtn, 30, hEdtBx], ...
    'BackgroundColor','w');

% Run button
uicontrol('Parent',hmain, 'Style', 'pushbutton', 'String', 'Run', ...
    'Tag', 'btnRun', ...
    'Callback', 'SIMToolbox(''btnRun_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [width+dlgmargin+270, psiz(2)-3*dlgmargin-hBtn, 100, hBtn]);

% Quit button
uicontrol('Parent',hmain, 'Style', 'pushbutton', 'String', 'Quit', ...
    'Tag', 'btnQuit',...
    'Callback', 'SIMToolbox(''btnQuit_Callback'',gcbo,[])', ...
    'Units', 'pixels', 'Position', [2*width-dlgmargin-80, psiz(2)-3*dlgmargin-hBtn, 80, hBtn]);

% ----------- INITIALIZATION -----------

% get handles of active objects
data.hndl = guihandles(hmain);
data.hndl.preview.sim = nan(1,2);  % sr image + FFT
data.hndl.preview.vsm = nan(1,length(cfg.db.vsm)); % all vsm methods
data.hndl.preview.msm = nan(1,1);  % map-sim image

% configuration
data.cfg = cfg;

% data info
data.imginfo = [];
data.calinfo = [];
data.ptrninfo = [];

% check data dir, calibration file and repz & update menu
set(data.hndl.editDataDir, 'String', cfg.datadir);
editDataDir_Callback(data.hndl.editDataDir, 'init');

% ============================================================================
% Data
% ============================================================================

%-----------------------------------------------------------------------------
function btnDataChangeDir_Callback(~,eventdata)
%-----------------------------------------------------------------------------
global data

% open dialog
datadir = uigetdir(data.cfg.datadir, 'Choose data directory');

% set new file name
if ~isequal(datadir, 0)
    set(data.hndl.editDataDir,'String', datadir);
    editDataDir_Callback(data.hndl.editDataDir, eventdata);
end

%-----------------------------------------------------------------------------
function editDataDir_Callback(h,eventdata)
%-----------------------------------------------------------------------------
global data

% read text field (before menu is updated)
datadir = get(h, 'String');

% close preview images
closePreview();

% display wait message + disable buttons
updateDlgMain('off', 'data');

% extract path and filename
[datadir, ~] = extractPathAndFilename([datadir filesep], [data.cfg.datadir filesep]);

try
    
    % initialize images
    data.imginfo = imginfoinit(datadir);
    assert(data.imginfo.image.size.w == 1, 'Data can contain one channel only.');
    data.cfg.datadir = data.imginfo.data.dir;
    data.cfg.setup.camera = rmfields(data.imginfo.camera,{'code','bitdepth','roi','gain'});
    
catch err
    
    % clear imginfo, set datadir to previous working
    data.imginfo = [];
    data.cfg.setup.camera = [];
    if strcmp(err.identifier, 'imgdirinfo:nodatadir')
        data.cfg.datadir = pwd;
    else
        data.cfg.datadir = datadir;
    end
    
    if ~strcmp(eventdata, 'init')
        waitfor(warndlg(err.message, 'Warning', 'modal'));
    end
    
end

% load defaults or previously saved settings
data.cfg = cfgload(data.imginfo, data.cfg);

% set calibration
set(data.hndl.editPtrnCalibration, 'String', data.cfg.cal.calibr);
editPtrnCalibration_Callback(data.hndl.editPtrnCalibration, eventdata);

% set ptrn fields and load pattern repertoire
set(data.hndl.editPtrnRepz, 'String', data.cfg.ptrn.repz);
editPtrnRepz_Callback(data.hndl.editPtrnRepz, eventdata);

% synchronize gui
updateDlgMain('on','all');

% %-----------------------------------------------------------------------------
% function [pathstr, filename] = extractPathAndFilename(filename, filenameold)
% %-----------------------------------------------------------------------------
% pathstr = fileparts_dir(filename);
% fname = fileparts_nameext(filename);
% if isempty(pathstr)
%   pathstr = fileparts_dir(filenameold);
%   filename = [pathstr filesep fname];
% end

% ============================================================================
% Calibration
% ============================================================================

%-----------------------------------------------------------------------------
function btnPtrnChangeCalibration_Callback(~,eventdata)
%-----------------------------------------------------------------------------
global data
% open dialog
tmp = pwd;
if ~isempty(data.cfg.cal.calibr)
    dirname = fileparts_dir(data.cfg.cal.calibr);
    if isdir(dirname)
        cd(dirname);
    end
end
[filename, dirname] = uigetfile('*.yaml', 'Choose calibration file');
cd(tmp);

% set new file name
if ~isequal(filename,0)
    set(data.hndl.editPtrnCalibration, 'String', [dirname, filename]);
    editPtrnCalibration_Callback(data.hndl.editPtrnCalibration, eventdata);
end

%-----------------------------------------------------------------------------
function editPtrnCalibration_Callback(h,eventdata)
%-----------------------------------------------------------------------------
global data

% read text field
filename = get(h, 'String');

% dispaly wait message + disable buttons
updateDlgMain('off', 'cal');

% extract path and filename
[pathstr, filename] = extractPathAndFilename(filename, data.cfg.cal.calibr);

try
    
    % load calibration file
    data.calinfo = calload(filename);
    data.cfg.cal.calibr = filename;
    
catch err
    
    % clear calinfo and set calibr to last dir
    data.calinfo = [];
    if isdir(pathstr)
        data.cfg.cal.calibr = pathstr;
    else
        data.cfg.cal.calibr = pwd;
    end
    
    if ~any(strcmp(eventdata,{'init','data','calprocess'}))
        waitfor(warndlg(err.message, 'Warning', 'modal'));
    end
    
end

% clear pattern mask
if ~isempty(data.ptrninfo)
    data.ptrninfo.MaskOn = [];
end

% set spotfinder method for SR-SIM
if isempty(data.calinfo)
    data.cfg.sim.spotfindermethod = spotfinder_method_spotfinder(data.cfg.db.spotfinder);
else
    data.cfg.sim.spotfindermethod = spotfinder_method_calibration;
end

% update preview when applicable
% updateSimPreview('all');
% updateVsmPreview();
% updateMsmPreview();

% synchronize fields
if ~any(strcmp(eventdata, {'data','init'}))
    updateDlgMain('on', eventdata);
end

%-----------------------------------------------------------------------------
function btnPtrnRunCalibration_Callback(~,eventdata)
%-----------------------------------------------------------------------------
global data

% close preview images
closePreview();

% open dialog
datadir = uigetdir(fileparts_dir(data.cfg.cal.calibr), 'Choose data directory');
if isequal(datadir,0), return; end; % if cancel

% dispaly wait message + disable buttons
updateDlgMain('off', eventdata);

% run calibration process
try
    [calfn,~] = calprocess(datadir);
catch err
    calfn = '';
    waitfor(warndlg(err.message,'Warning','modal'));
end

% synchronize fields
set(data.hndl.editPtrnCalibration, 'String', calfn);
editPtrnCalibration_Callback(data.hndl.editPtrnCalibration, eventdata);

% ============================================================================
% Pattern
% ============================================================================

%-----------------------------------------------------------------------------
function btnPtrnChangeRepz_Callback(~,eventdata)
%-----------------------------------------------------------------------------
global data

% open dialog
tmp = pwd;
if ~isempty(data.cfg.ptrn.repz)
    dirname = fileparts_dir(data.cfg.ptrn.repz);
    if isdir(dirname)
        cd(dirname);
    end
end
[filename, dirname] = uigetfile('*.repz', 'Choose pattern reperoire');
cd(tmp);

% set new file name
if ~isequal(filename,0)
    set(data.hndl.editPtrnRepz, 'String', [dirname, filename]);
    editPtrnRepz_Callback(data.hndl.editPtrnRepz, eventdata);
end

%-----------------------------------------------------------------------------
function editPtrnRepz_Callback(h,eventdata)
%-----------------------------------------------------------------------------
global data

% read text field
filename = get(h, 'String');

% close preview images
closePreview();

% display wait message + disable buttons
updateDlgMain('off', 'ptrn');

% extract path and filename
[pathstr, filename] = extractPathAndFilename(filename, data.cfg.ptrn.repz);

try
    
    % remove previous pattern repertoire
    ptrnclose(data.ptrninfo);
    
    % initialize a new pattern repertoire
    data.ptrninfo = ptrnopen(filename);
    data.cfg.ptrn.repz = filename;
    data.ptrninfo.MaskOn = [];  % pattern mask for preview
    
    % switch running order to the default value
    if strcmp(eventdata,'ptrn') || isnan(data.cfg.ptrn.ro)
        data.cfg.ptrn.ro = data.ptrninfo.default;
    end
    
catch err
    
    % clear ptrn, set #ro, set repz to last dir
    data.ptrninfo = [];
    data.cfg.ptrn.ro = NaN;
    if isdir(pathstr)
        data.cfg.ptrn.repz = pathstr;
    else
        data.cfg.ptrn.repz  = pwd;
    end
    
    if ~any(strcmp(eventdata,{'init','data'}))
        waitfor(warndlg(err.message, 'Warning', 'modal'));
    end
    
end

% check for line pattern and set angles
ptrnangles(eventdata);

%-----------------------------------------------------------------------------
function popPtrnRunningOrder_Callback(h,eventdata)
%-----------------------------------------------------------------------------
global data
% read RO
data.cfg.ptrn.ro = get(h, 'Value')-1; % RO starts from zero
% close preview images
closePreview();
% clear pattern mask for preview
data.ptrninfo.MaskOn = [];
% check for line pattern and set angles
ptrnangles(eventdata);

%-----------------------------------------------------------------------------
function ptrnangles(eventdata)
%-----------------------------------------------------------------------------
global data

if isfield(data.cfg.msm,'MaskOn')
    data.cfg.msm = rmfield( data.cfg.msm ,'MaskOn');
end

try
    
    % test line pattern + pattern must be the same size as image sequence
    [ptrn, numangles, ro] = ptrnchecklines(data.ptrninfo, data.cfg.ptrn.ro);
    assert(~isempty(ptrn) && ~isempty(data.imginfo) && data.imginfo.image.size.seq == ro.numseq);
    
    if any(strcmp(eventdata, {'ptrn', 'ro','data'}))
        % initialize weights for harmonic components
        numharmon = min([fix(([ptrn.num] - 1)/2), 4]); % maximum is 4
        data.cfg.sim.harmonweight = [0 ones(1, numharmon)];
        % initialize angles
        data.cfg.ptrn.angles = struct('name',{},'enable',{},'numharmon',{});
        for I = 1:numangles
            data.cfg.ptrn.angles(I) = struct('name',sprintf('%.0f', ptrn(I).angle),'enable',1,'numharmon',numharmon);
        end
    elseif strcmp(eventdata, 'findpeaks')
        % update weights
        currentnumharmon = length(data.cfg.sim.harmonweight)-1; % previous weights, -1 is because of 0th harmonics
        maxnumharmon = max([data.cfg.ptrn.angles.numharmon]);   % this is set by FindPeaks
        if currentnumharmon >= maxnumharmon
            data.cfg.sim.harmonweight = data.cfg.sim.harmonweight(1:(maxnumharmon+1)); % trim weights
        else
            data.cfg.sim.harmonweight((currentnumharmon+2):(maxnumharmon+1)) = 1; % add weight = 1 to new harmonics
        end
    end
    
catch err
    data.cfg.sim.harmonweight = [];
    data.cfg.ptrn.angles = [];
end

% synchronize fields
if ~any(strcmp(eventdata, {'data','init'}))
    updateDlgMain('on', eventdata);
end

%-----------------------------------------------------------------------------
function chkbxPtrnAngles_Callback(h,idx)
%-----------------------------------------------------------------------------
global data
data.cfg.ptrn.angles(idx).enable = get(h, 'Value');
% updateSimPreview('combine');
% updateVsmPreview();
% updateMsmPreview();

%-----------------------------------------------------------------------------
function editPtrnOffset_Callback(h,~)
%-----------------------------------------------------------------------------
global data
num = str2double(strrep(get(h, 'String'),',','.'));
if ~isnan(num)
    data.cfg.ptrn.offset = floor(num);
    %     updateSimPreview('all');
    %     updateVsmPreview();
    %     updateMsmPreview();
end
set(h, 'String', data.cfg.ptrn.offset);

%-----------------------------------------------------------------------------
function editPtrnSigmaBlure_Callback(h,~)
%-----------------------------------------------------------------------------
global data
num = str2double(strrep(get(h, 'String'),',','.'));
if num >= 0
    data.cfg.ptrn.blure = num;
    data.ptrninfo.MaskOn = [];
    %     updateVsmPreview();
    %     updateMsmPreview();
end
set(h, 'String', data.cfg.ptrn.blure);

%-----------------------------------------------------------------------------
function btnPtrnEstimate_Callback(~,~)
%-----------------------------------------------------------------------------
global data
waitfor(setEstimatePatterns('createDlg', data.imginfo, data.calinfo, data.cfg));

% ============================================================================
% SIM Processing Options
% ============================================================================

%-----------------------------------------------------------------------------
function editSimWeigth_Callback(h,idx)
%-----------------------------------------------------------------------------
global data
num = str2double(strrep(get(h, 'String'),',','.'));
if num >= 0
    data.cfg.sim.harmonweight(idx) = num;
    %     updateSimPreview('combine');
end
set(h, 'String', data.cfg.sim.harmonweight(idx));

%-----------------------------------------------------------------------------
function editSimWiener_Callback(h,~)
%-----------------------------------------------------------------------------
global data
num = str2double(strrep(get(h, 'String'),',','.'));
if num >= 0
    data.cfg.sim.wiener = num;
    %     updateSimPreview('combine');
end
set(h, 'String', data.cfg.sim.wiener);

%-----------------------------------------------------------------------------
function popSim_Callback(h,eventdata)
%-----------------------------------------------------------------------------
global data
% get selection
idx = get(h, 'Value');
% change apodizing filter
choice = data.cfg.db.(eventdata)(idx);   % eventdata = apodize / otf
if ~isempty(choice.params)
    choice.params.resolution = data.imginfo.image.resolution.x;
end
data.cfg.sim.(eventdata) = struct('type', choice.type, 'params', choice.params);
% updateSimPreview(eventdata);

%-----------------------------------------------------------------------------
function editSimPopParam_Callback(h,parname,eventdata)
%-----------------------------------------------------------------------------
global data
if strcmp(parname,'file')
    data.cfg.sim.(eventdata).params.(parname) = get(h, 'String');  % eventdata = apodize / otf
else
    num = str2double(strrep(get(h, 'String'),',','.'));
    if ~isnan(num)
        data.cfg.sim.(eventdata).params.(parname) = num;
    end
end
% update parameter value in the database
if strcmp(parname,'file') || ~isnan(num)
    idx = strcmp(data.cfg.sim.(eventdata).type,{data.cfg.db.(eventdata).type});
    data.cfg.db.(eventdata)(idx).params.(parname) = data.cfg.sim.(eventdata).params.(parname);
    %     updateSimPreview(eventdata);
end
% update field
set(h, 'String', data.cfg.sim.(eventdata).params.(parname));

%-----------------------------------------------------------------------------
function chkbxSimEnable_Callback(h,~)
%-----------------------------------------------------------------------------
global data
data.cfg.sim.enable = get(h, 'Value');
if ~data.cfg.sim.enable
    closePreview();
end
updateDlgMain('on');

%-----------------------------------------------------------------------------
function btnSimFindPeaks_Callback(~,~)
%-----------------------------------------------------------------------------
global data
waitfor(setFindPeaks('createDlg', data.imginfo, data.ptrninfo, data.calinfo, data.cfg));
ptrnangles('findpeaks');

% ============================================================================
% VSM Processing Options
% ============================================================================

%-----------------------------------------------------------------------------
function ptrninfo = computeptrnmask(imginfo,ptrninfo,calinfo,cfg)
%-----------------------------------------------------------------------------
if ~isempty(calinfo) && isempty(ptrninfo.MaskOn)
    hndlwb = waitbar(0,'Initializing ...','Name','Progress ...','Tag','WaitBar','WindowStyle','modal');
    ptrninfo.MaskOn = seq2subseq(ptrnmaskprecompute(imginfo, ptrninfo, calinfo, ...
        'runningorder', cfg.ptrn.ro, 'sigma', cfg.ptrn.blure, 'progressbar', hndlwb), ptrninfo, cfg.ptrn.ro);
    close(hndlwb);
end

%-----------------------------------------------------------------------------
function chkbxVsmEval_Callback(h,idx)
%-----------------------------------------------------------------------------
global data
data.cfg.vsm.eval(idx).enable = get(h, 'Value');
if ~data.cfg.vsm.eval(idx).enable
    closePreview();
end
updateDlgMain('on');

%-----------------------------------------------------------------------------
function chkbxVsmOptions_Callback(h,eventdata)
%-----------------------------------------------------------------------------
global data
data.cfg.vsm.(eventdata) = get(h, 'Value');  % eventdata = striperemoval / flatfield
% updateSimPreview('all');
% updateVsmPreview();
% updateMsmPreview();

% ============================================================================
% MAP-SIM Processing Options
% ============================================================================

%-----------------------------------------------------------------------------
function chkbxUpsampleMap_Callback(h,~)
%-----------------------------------------------------------------------------
global data
data.cfg.msm.upsample = get(h, 'Value');
% if data.cfg.msm.upsample == 1 && isempty(data.calinfo)
% set(data.hndl.txtMapNote, 'Visible', 'On');
% else
% set(data.hndl.txtMapNote, 'Visible', 'Off');
% end

%-----------------------------------------------------------------------------
function chkbxUpsampleSim_Callback(h,~)
%-----------------------------------------------------------------------------
global data
data.cfg.sim.upsample = get(h, 'Value');
% if data.cfg.msm.upsample == 1 && isempty(data.calinfo)
% set(data.hndl.txtMapNote, 'Visible', 'On');
% else
% set(data.hndl.txtMapNote, 'Visible', 'Off');
% end

%-----------------------------------------------------------------------------
function chkbxMsmEnable_Callback(h,~)
%-----------------------------------------------------------------------------
global data
data.cfg.msm.enable = get(h, 'Value');
if data.cfg.msm.enable && isempty(data.calinfo)
    set(data.hndl.txtMapNote, 'Visible', 'On');
else
    set(data.hndl.txtMapNote, 'Visible', 'Off');
end

if ~data.cfg.msm.enable
    closePreview();
end
updateDlgMain('on');

%-----------------------------------------------------------------------------
function editMsmFc_Callback(h,~)
%-----------------------------------------------------------------------------
global data
num = str2double(strrep(get(h, 'String'),',','.'));
if num >= 0
    data.cfg.msm.fc = num;
    %     updateMsmPreview();
end
set(h, 'String', data.cfg.msm.fc);

%-----------------------------------------------------------------------------
function editMsmMerging_Callback(h,~)
%-----------------------------------------------------------------------------
global data
num = str2double(strrep(get(h, 'String'),',','.'));
if num >= 0
    data.cfg.msm.wmerg = num;
    %     updateMsmPreview();
end
set(h, 'String', data.cfg.msm.wmerg);

%-----------------------------------------------------------------------------
function chkbxCudaMap_Callback(h,~)
%-----------------------------------------------------------------------------
global data
if gpuDeviceCount
    if get(h,'Value')
        data.cfg.msm.meth = 'CUDA';
        GPUinfo = gpuDevice;
        
        txt = sprintf('GPU test: OK\nName: %s\nCC: %s', ...
            GPUinfo(1).Name,GPUinfo(1).ComputeCapability);
        set(data.hndl.txtCudaInfo,'String',txt, ...
            'ForegroundColor','black','Visible','on');
    elseif ~get(h,'Value')
        data.cfg.msm.meth = 'CPU';
        set(data.hndl.txtCudaInfo,'Visible','off');
    end
    updateDlgMain('on');
else
    data.cfg.msm.meth = 'CPU';
    txt = sprintf('GPU test: FAIL\nCUDA is not supported.');
    set(data.hndl.txtCudaInfo,'String',txt, ...
        'ForegroundColor','red','Visible','on');
    set(h,'Value',0);
    updateDlgMain('on');
end
% if data.cfg.msm.upsample == 1 && isempty(data.calinfo)
% set(data.hndl.txtMapNote, 'Visible', 'On');
% else
% set(data.hndl.txtMapNote, 'Visible', 'Off');
% end

%-----------------------------------------------------------------------------
% function editMsmCudaAlpha_Callback(h,~)
% %-----------------------------------------------------------------------------
% global data
% num = str2double(strrep(get(h, 'String'),',','.'));
% if num >= 0
%     data.cfg.msm.cuda.alph = num;
%     %     updateMsmPreview();
% end
% set(h, 'String', data.cfg.msm.cuda.alph);

%-----------------------------------------------------------------------------
% function editMsmCudaMaxiter_Callback(h,~)
% %-----------------------------------------------------------------------------
% global data
% num = str2double(strrep(get(h, 'String'),',','.'));
% if num >= 0
%     data.cfg.msm.cuda.maxiter = num;
%     %     updateMsmPreview();
% end
% set(h, 'String', data.cfg.msm.cuda.maxiter);

% ============================================================================
% SAVE OPTIONS
% ============================================================================

%-----------------------------------------------------------------------------
function chkbx16bit_Callback(h,~)
%-----------------------------------------------------------------------------
global data
data.cfg.save(1).enable = get(h, 'Value');
data.cfg.save(2).enable = ~get(h, 'Value');
updateDlgMain('on');

%-----------------------------------------------------------------------------
function chkbx32bit_Callback(h,~)
%-----------------------------------------------------------------------------
global data
data.cfg.save(1).enable = ~get(h, 'Value');
data.cfg.save(2).enable = get(h, 'Value');
updateDlgMain('on');

%-----------------------------------------------------------------------------
function btnSaveChangeDir_Callback(~,eventdata)
%-----------------------------------------------------------------------------
global data

% open dialog
datadir = uigetdir(data.cfg.resdir, 'Choose save directory');

% set new file name
if ~isequal(datadir, 0)
    set(data.hndl.editSaveDir,'String', datadir);
    editSaveDir_Callback(data.hndl.editSaveDir, eventdata);
end

%-----------------------------------------------------------------------------
function editSaveDir_Callback(h,~)
%-----------------------------------------------------------------------------
global data

% read text field (before menu is updated)
savedir = get(h, 'String');
if exist(savedir,'dir') == 7
    resname = savedir;
else
    choice = questdlg('Save directory does not exist. Would you like to create it?', ...
        'Save Directory', ...
        'Yes','No','Cancle','Yes');
    if strcmp(choice,'Yes')
        a = mkdir(savedir);
        if a == 1
            oldpath=pwd;
            cd(savedir);
            resname = pwd;
            cd(oldpath);
        else
            msgbox(['Impossible to create this directory: ' savedir], ...
                'Warning','warn');
            resname = ['$data$' filesep 'results' filesep];
        end
    else
        resname = ['$data$' filesep 'results' filesep];
    end
    
end

data.cfg.resdir = [fileparts_dir(resname) filesep];
% synchronize gui
updateDlgMain('on','all');

% ============================================================================
% MAIN - Defaults, Run, Quit
% ============================================================================

%-----------------------------------------------------------------------------
function btnRun_Callback(~,~)
%-----------------------------------------------------------------------------
global data
closePreview();
updateDlgMain('off','run');
try
    process(data.cfg,data.imginfo, data.ptrninfo, data.calinfo);
catch err
    printerror(err);
end
updateDlgMain('on','run');

%-----------------------------------------------------------------------------
function btnQuit_Callback(~,~)
%-----------------------------------------------------------------------------
global data
close(data.hndl.dlgMain);

%-----------------------------------------------------------------------------
function btnReset_Callback(~,~)
%-----------------------------------------------------------------------------
global data

%%%%%% ARE YOU SURE %%%%%%%%%%%
choice = questdlg('Reset all settings?', ...
    'Reset', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        % load default configuration
        cfgRESET = config();
        
        data.cfg.sim = cfgRESET.sim;
        data.cfg.msm = cfgRESET.msm;
        data.cfg.vsm = cfgRESET.vsm;
        
        % set spotfinder method for SR-SIM
        if isempty(data.calinfo)
            data.cfg.sim.spotfindermethod = spotfinder_method_spotfinder(data.cfg.db.spotfinder);
        else
            data.cfg.sim.spotfindermethod = spotfinder_method_calibration;
        end
        
        updateDlgMain('on','all');
    case 'No'
        display('Reset canceled.');
end


% ============================================================================
% PREVIEW
% ============================================================================

%-----------------------------------------------------------------------------
function btnPreview_Callback(~,~)
%-----------------------------------------------------------------------------
global data

% OS-SIM - create a figure for every method
for I = 1:length(data.cfg.vsm.eval)
    if data.cfg.vsm.eval(I).enable && ~ishandle(data.hndl.preview.vsm(I))
        data.hndl.preview.vsm(I) = figure;
        set(gcf,'Name', data.cfg.db.vsm(I).name, 'NumberTitle','off', ...
            'DeleteFcn', sprintf('SIMToolbox(''onVsmPreviewClose_Callback'',%f,%d)', 1, I)); % data.hndl.dlgMain
    end
end

% SR-SIM  - create a figure for sim reconstruction + FFT
if data.cfg.sim.enable
    names = {'SR-SIM reconstruction', 'FFT of SR-SIM reconstruction'};
    for I = 1:2
        if ~ishandle(data.hndl.preview.sim(I))
            data.hndl.preview.sim(I) = figure;
            set(gcf,'Name', names{I}, 'NumberTitle','off', ...
                'DeleteFcn', sprintf('SIMToolbox(''onSimPreviewClose_Callback'',%f,%d)', 1, I)); % data.hndl.dlgMain
        end
    end
end

% MAP-SIM  - create a figure for sim reconstruction
if data.cfg.msm.enable
    names = {'MAP-SIM reconstruction'};
    for I = 1:1
        if ~ishandle(data.hndl.preview.msm(I))
            data.hndl.preview.msm(I) = figure;
            set(gcf,'Name', names{I}, 'NumberTitle','off', ...
                'DeleteFcn', sprintf('SIMToolbox(''onMsmPreviewClose_Callback'',%f,%d)', 1, I)); %data.hndl.dlgMain
        end
    end
end

% show preview figures
updateVsmPreview();
updateSimPreview('all');
updateMsmPreview();

%-----------------------------------------------------------------------------
function editPreview_Callback(h,eventdata)
%-----------------------------------------------------------------------------
global data
num = str2double(strrep(get(h, 'String'),',','.'));
if ~isnan(num) && (num >= 1) && (num <= data.imginfo.image.size.(eventdata))
    data.cfg.preview.(eventdata) = floor(num);   % eventdata = z / t
    %     updateSimPreview('all');
    %     updateVsmPreview();
    %     updateMsmPreview();
end
set(h, 'String', data.cfg.preview.(eventdata));

%-----------------------------------------------------------------------------
function updateSimPreview(event)
%-----------------------------------------------------------------------------
global data

% do nothing if no preview is open
if ~any(ishandle([data.hndl.preview.sim]))
    return
end

% close preview if no pattern is open or number of patterns does not agree
if isempty(data.ptrninfo) || ptrngetnumseq(data.ptrninfo, data.cfg.ptrn.ro) ~= data.imginfo.image.size.seq
    closePreview();
    return
end

updateDlgMain('off','simpreview');

% preview based on settings in VSM
Z = data.cfg.preview.z;
T = data.cfg.preview.t;
offset = -data.cfg.ptrn.offset;
angles = logical([data.cfg.ptrn.angles.enable]);

if data.cfg.sim.enable
    if any(strcmp(event,{'all', 'findpeaks'}))
        % find and assign peaks
        %timestamp('  Finding and assigning peaks ...');
        data.ptrn = sim_findpeaksassign(data.imginfo, data.ptrninfo, data.calinfo, Z, data.cfg); % which Z to use?
        if isempty(data.ptrn); updateDlgMain('on','simpreview'); return; end;
    end
end

if strcmp(event,'all')
    % load SIM sequence
    %timestamp('  Loading sequence ...');
    data.seq = seq2subseq(seqload(data.imginfo, 'z',Z,'t',T,'offset',offset,'datatype','single'), data.ptrninfo, data.cfg.ptrn.ro);
    % remove stripes in raw data
    if data.cfg.vsm.striperemoval, data.seq = seqstriperemoval(data.seq); end;
    % padding and smoothing of image borders to remove ugly cross in FFT
    data.seq = seqpadsmooth(data.seq, data.cfg.sim.smoothpadsize, data.cfg.sim.smoothsigma);
end

if data.cfg.sim.enable
    if any(strcmp(event,{'all', 'findpeaks'}))
        
        % compute expanded spectra for all illumination angles
        % timestamp('  Extracting spectra ...');
        data.seq = sim_extract(data.seq, data.ptrn);
        
        % shift expanded spectra to center position
        %timestamp('  Shifting spectra ...');
        data.seq = sim_shiftspectra(data.seq, data.ptrn,data.cfg.sim);
    end
    
    if any(strcmp(event,{'all', 'otf'}))
        %timestamp('  Generating shifted OTFs ...');
        data.seq = sim_addOTF(data.seq, data.ptrn, data.cfg.sim.otf);
    end
    
    %combine spectra together
    %timestamp('  Combining spectra ...');
    if any(angles)
        [IMsr,IMsrFFT] = sim_combine(data.seq(angles), data.cfg.sim);
        
        % remove padded borders
        if data.cfg.sim.upsample
            IMsr = imgrmpadding(IMsr, data.cfg.sim.smoothpadsize*2);
        else
            IMsr = imgrmpadding(IMsr, data.cfg.sim.smoothpadsize);
        end
        
    else
        IMsr = zeros([data.imginfo.image.size.y, data.imginfo.image.size.x], 'double');
        IMsrFFT = IMsr;
    end
    
    % show figures
    if ishandle(data.hndl.preview.sim(1))
        figure(data.hndl.preview.sim(1));
        showimage(IMsr, data.cfg.preview.saturate);
    end
    if ishandle(data.hndl.preview.sim(2))
        figure(data.hndl.preview.sim(2)); clf
        showfft(IMsrFFT);
        if isfield(data.cfg.sim.apodize.params,'rad')
            hold on
            cnt = ceil((size(IMsrFFT)+1)/2);
            t = linspace(0,2*pi,100);
            r = 2*data.cfg.sim.apodize.params.resolution/data.cfg.sim.apodize.params.rad;
            x = cnt(2) + cnt(2)*r*cos(t);
            y = cnt(1) + cnt(1)*r*sin(t);
            plot(x,y,'m-');
        end
    end
end

updateDlgMain('on','simpreview');
%end

%-----------------------------------------------------------------------------
function updateVsmPreview(~)
%-----------------------------------------------------------------------------
global data

% do nothing if no preview is open
if ~any(ishandle([data.hndl.preview.vsm]))
    return
end

% close preview if no pattern is open or number of patterns does not agree
if isempty(data.ptrninfo) || ptrngetnumseq(data.ptrninfo, data.cfg.ptrn.ro) ~= data.imginfo.image.size.seq
    closePreview();
    return
end

updateDlgMain('off', 'vsmpreview');

% precompute virtual mask
if sum([data.cfg.db.vsm(logical([data.cfg.vsm.eval.enable])).applymask]) > 0
    data.ptrninfo = computeptrnmask(data.imginfo, data.ptrninfo, data.calinfo, data.cfg);
end

% load sequence for the current section & rewind according to pattern offset
IMseq = seqload(data.imginfo, 'z', data.cfg.preview.z, 't', data.cfg.preview.t, 'offset', -data.cfg.ptrn.offset, 'datatype', 'single');

% flatfield correction
if data.cfg.vsm.flatfield
    [IMseq,data.calinfo] = runseqflatfield(IMseq, data.calinfo, data.imginfo);
end

% split sequence if appropriate - based on the running order (e.g, several line patterns)
seq = seq2subseq(IMseq, data.ptrninfo, data.cfg.ptrn.ro);

% stripe removal
if data.cfg.vsm.striperemoval, seq = seqstriperemoval(seq); end;

% which angles to process
angles = logical([data.cfg.ptrn.angles.enable]);
% process the sequence for every method
for I = find([data.cfg.vsm.eval.enable])
    if ishandle(data.hndl.preview.vsm(I))
        if any(angles)
            if data.cfg.db.vsm(I).applymask
                IM = feval(data.cfg.vsm.eval(I).fnc, seq(angles), data.ptrninfo.MaskOn(angles));
            else
                IM = feval(data.cfg.vsm.eval(I).fnc, seq(angles));
            end
        else
            IM = zeros([data.imginfo.image.size.y, data.imginfo.image.size.x]);
        end
        % show figure with 0.1% values saturated
        figure(data.hndl.preview.vsm(I));
        showimage(IM, data.cfg.preview.saturate);
    end
end

updateDlgMain('on','vsmpreview');
%end

%-----------------------------------------------------------------------------
function updateMsmPreview(~)
%-----------------------------------------------------------------------------
global data

% do nothing if no preview is open
if ~any(ishandle([data.hndl.preview.msm]))
    return
end

% close preview if no pattern is open or number of patterns does not agree
% if isempty(data.calinfo) || isempty(data.ptrninfo) || ptrngetnumseq(data.ptrninfo, data.cfg.ptrn.ro) ~= data.imginfo.image.size.seq
if isempty(data.ptrninfo) || ptrngetnumseq(data.ptrninfo, data.cfg.ptrn.ro) ~= data.imginfo.image.size.seq
    closePreview();
    return
end

updateDlgMain('off', 'mapsimpreview');

% precompute virtual mask
if isempty(data.ptrninfo.MaskOn)
    data.ptrninfo = computeptrnmask(data.imginfo, data.ptrninfo, data.calinfo, data.cfg);
end

% load sequence for the current section & rewind according to pattern offset
IMseq = seqload(data.imginfo, 'z', data.cfg.preview.z, 't', data.cfg.preview.t, 'offset', -data.cfg.ptrn.offset, 'datatype', 'single');

% split sequence if appropriate - based on the running order (e.g, several line patterns)
seq = seq2subseq(IMseq, data.ptrninfo, data.cfg.ptrn.ro);

% stripe removal
if data.cfg.vsm.striperemoval, seq = seqstriperemoval(seq); end;

% preview based on settings in VSM
Z = data.cfg.preview.z;

% which angles to process
angles = logical([data.cfg.ptrn.angles.enable]);

% process the sequence
if any(angles)
    
    %%% if the calibration is not known - patterns are estimated from the data
    if data.cfg.msm.enable && isempty(data.calinfo)
        
        data.cfg.msm.estimate = 1;
        data.ptrn = sim_findpeaksassign(data.imginfo, data.ptrninfo, data.calinfo, Z, data.cfg);
        
        if isempty(data.ptrn); updateDlgMain('on','mapsimpreview'); return; end;
        
        if isempty(data.ptrninfo.MaskOn)
            data.ptrninfo.MaskOn = genMasks(seq,data.ptrn);
        end
        IM = mapsim( ...
            seq(angles),...
            data.ptrninfo.MaskOn(angles),...
            seqcfhomodyne(seq(angles)),...
            data.cfg.msm);
        
        %%% if the calibration is known - patterns are known
    elseif data.cfg.msm.enable && ~isempty(data.calinfo)
        
        data.cfg.msm.estimate = 0;
        IM = mapsim(...
            seq(angles),...
            data.ptrninfo.MaskOn(angles),...
            seqcfhomodyne(seq(angles)),...
            data.cfg.msm);
    end
    
else
    IM = zeros([data.imginfo.image.size.y, data.imginfo.image.size.x]);
end

% show figure with 0.1% values saturated
if ishandle(data.hndl.preview.msm)
    figure(data.hndl.preview.msm);
    showimage(IM, data.cfg.preview.saturate);
end

updateDlgMain('on','mapsimpreview');

%-----------------------------------------------------------------------------
function showimage(IM, saturate)
%-----------------------------------------------------------------------------
imagesc(IM, imgclipval(IM, saturate));
colormap gray
axis off equal tight
set(gca,'Position',[0 0 1 1]);

%-----------------------------------------------------------------------------
function showfft(IMfft)
%-----------------------------------------------------------------------------
imagesc(log(abs(IMfft)),[-10 3]);
colormap jet
axis off equal tight
set(gca,'Position',[0 0 1 1]);

%-----------------------------------------------------------------------------
function closePreview()
%-----------------------------------------------------------------------------
global data

data.seq = [];  % clear memory

for I = 1:length(data.hndl.preview.sim)
    if ishandle(data.hndl.preview.sim(I))
        close(data.hndl.preview.sim(I));
        data.hndl.preview.sim(I) = NaN;
    end
end

for I = 1:length(data.hndl.preview.msm)
    if ishandle(data.hndl.preview.msm(I))
        close(data.hndl.preview.msm(I));
        data.hndl.preview.sim(I) = NaN;
    end
end

for I = 1:length(data.hndl.preview.vsm)
    if ishandle(data.hndl.preview.vsm(I))
        close(data.hndl.preview.vsm(I));
        data.hndl.preview.vsm(I) = NaN;
    end
end

%-----------------------------------------------------------------------------
function onSimPreviewClose_Callback(~,idx)
%-----------------------------------------------------------------------------
global data
data.hndl.preview.sim(idx) = NaN;

%-----------------------------------------------------------------------------
function onMsmPreviewClose_Callback(~,idx)
%-----------------------------------------------------------------------------
global data
data.hndl.preview.msm(idx) = NaN;

%-----------------------------------------------------------------------------
function onVsmPreviewClose_Callback(~,idx)
%-----------------------------------------------------------------------------
global data
data.hndl.preview.vsm(idx) = NaN;

% ============================================================================
% UPDATE - main menu and fields with new configuration values
% ============================================================================

%-----------------------------------------------------------------------------
function setDataInfoTxt(state,eventdata)
%-----------------------------------------------------------------------------
global data

if strcmp(state, 'off') && strcmp(eventdata, 'data')
    set(data.hndl.txtDataInfo, 'String', sprintf('\nReading data info, please wait ...'));
    set(data.hndl.txtDataDim, 'String', '');
elseif strcmp(state, 'on') && any(strcmp(eventdata, {'data', 'all'}))
    if isempty(data.imginfo)
        set(data.hndl.editDataDir, 'String', '');
        set(data.hndl.editSaveDir, 'String', '');
        set(data.hndl.txtDataInfo, 'String', sprintf('\nNo data'));
        set(data.hndl.txtDataDim, 'String', '');
    else
        set(data.hndl.editDataDir, 'String', data.imginfo.data.dir);
        set(data.hndl.editSaveDir, 'String', ...
            fixresname(data.cfg.resdir, data.imginfo.data.dir, data.imginfo.data.filemask));
        set(data.hndl.txtDataInfo, 'String', [...
            sprintf(' Camera:      %s\n', data.imginfo.camera.name) ...
            sprintf(' Data info:   %d file(s) with %d frames\n', length(data.imginfo.data.filelist), data.imginfo.data.numframes(end)) ...
            sprintf(' Image size:  x: %4d px, y: %4d px, z: %d\n', data.imginfo.image.size.x, data.imginfo.image.size.y, data.imginfo.image.size.z) ...
            sprintf(' Resolution:  x:%5.1f nm  y:%5.1f nm  z: %.0f nm', 1000*data.imginfo.image.resolution.x, 1000*data.imginfo.image.resolution.y, 1000*data.imginfo.image.resolution.z)]);
        set(data.hndl.txtDataDim, 'String', sprintf('time: %2d\n seq: %2d\n  ch: %2d', data.imginfo.image.size.t, data.imginfo.image.size.seq, data.imginfo.image.size.w));
    end
end

%-----------------------------------------------------------------------------
function setCalInfoTxt(state,eventdata)
%-----------------------------------------------------------------------------
global data

if strcmp(state,'off') && any(strcmp(eventdata, {'cal', 'calprocess'}))
    clearSimAngles();
    if strcmp(eventdata, 'calprocess')
        set(data.hndl.txtPtrnRepzInfo, 'String', sprintf('Calibration in progress, please wait ...'));
    else
        set(data.hndl.txtPtrnRepzInfo, 'String', sprintf('Loading calibration info, please wait ...'));
    end
elseif strcmp(state, 'on') && any(strcmp(eventdata, {'cal', 'calprocess', 'all'}))
    if isempty(data.calinfo)
        set(data.hndl.editPtrnCalibration, 'String', '');
    else
        set(data.hndl.editPtrnCalibration, 'String', data.cfg.cal.calibr); %fileparts_nameext(data.cfg.cal.calibr)
    end
end

%-----------------------------------------------------------------------------
function setPtrnInfoTxt(state,eventdata)
%-----------------------------------------------------------------------------
global data

if strcmp(state, 'off') && strcmp(eventdata, 'ptrn')
    clearSimAngles();
    set(data.hndl.txtPtrnRepzInfo, 'String', sprintf('Loading pattern info, please wait ...'));
    set(data.hndl.txtPtrnAngles, 'Visible', 'off');
    set(data.hndl.txtPtrnRepzError, 'Visible', 'off');
elseif strcmp(state, 'on') && any(strcmp(eventdata, {'ptrn', 'ro', 'cal', 'calprocess', 'all'}))
    clearSimAngles();
    if isempty(data.ptrninfo)
        % no pattern loaded
        set(data.hndl.editPtrnRepz, 'String', '');
        set(data.hndl.popPtrnRunningOrder, 'String', {''}, 'Value', 1, 'Enable', 'off'); % clear RO popup
        set(data.hndl.txtPtrnRepzInfo, 'String', sprintf('No pattern'));
        set(data.hndl.txtPtrnAngles, 'Visible', 'off');
        set(data.hndl.txtPtrnRepzError, 'Visible', 'off');
    else
        % pattern loaded
        set(data.hndl.editPtrnRepz, 'String', fileparts_nameext(data.cfg.ptrn.repz));
        set(data.hndl.popPtrnRunningOrder, 'String', {data.ptrninfo.runningorder.name}, 'Value', data.cfg.ptrn.ro+1, 'Enable', 'on');
        setSimAngles();
    end
end

%-----------------------------------------------------------------------------
function clearSimAngles()
%-----------------------------------------------------------------------------
global data
hsim = get(data.hndl.txtPtrnAngles, 'Parent');
delete(findobj(hsim,'Tag','chkbxPtrnAngles'));
data.hndl.chkbxPtrnAngles = [];

%-----------------------------------------------------------------------------
function setSimAngles()
%-----------------------------------------------------------------------------
global data

% check line pattern
[ptrn, numangles, ro] = ptrnchecklines(data.ptrninfo, data.cfg.ptrn.ro);

% fill pattern info
strptrninfo = cell(1,2);
if isempty(ptrn)
    % no lines
    for I = 1:numangles
        strptrninfo{1} = cat(2, strptrninfo{1}, sprintf('%s(#%d), ', ro.data{I}.id, ro.data{I}.num));
    end
    strptrninfo{2} = 'Pattern must contain lines only for SIM processing.';
else
    % lines
    strptrninfo{1} = 'lines: ';
    for I = 1:numangles
        strptrninfo{1} = cat(2, strptrninfo{1}, sprintf('%.0fo (#%d), ', ptrn(I).angle, ptrn(I).num));
    end
end
strptrninfo{1}(end-1:end) = [];  % remove last ','
set(data.hndl.txtPtrnRepzInfo, 'String', strptrninfo);

% check if the pattern match the data
if ~isempty(data.imginfo) && (ro.numseq ~= data.imginfo.image.size.seq)
    set(data.hndl.txtPtrnAngles, 'Visible', 'off');
    set(data.hndl.txtPtrnRepzError, 'Visible', 'on');
end

% create SIM check boxes
if ~isempty(data.cfg.ptrn.angles)
    dimload;
    set(data.hndl.txtPtrnAngles, 'Visible', 'on');
    set(data.hndl.txtPtrnRepzError, 'Visible', 'off');
    hsim = get(data.hndl.txtPtrnAngles, 'Parent');
    psiz = get(data.hndl.txtPtrnAngles,'Position');
    for I = 1:numangles
        hndl = uicontrol('Parent',hsim, 'Style','checkbox','String', data.cfg.ptrn.angles(I).name, ...
            'Tag', 'chkbxPtrnAngles', ...
            'Callback', sprintf('SIMToolbox(''chkbxPtrnAngles_Callback'',gcbo,%d)', I), ...
            'Units', 'pixels', 'Position',[psiz(1)+95+(I-1)*45, psiz(2), 40, hTxt], ...
            'Value', data.cfg.ptrn.angles(I).enable);
        data.hndl.chkbxPtrnAngles = [hndl data.hndl.chkbxPtrnAngles];
    end
end

%-----------------------------------------------------------------------------
function setSimParams(state,eventdata,name)
%-----------------------------------------------------------------------------
global data

% apodizing function
item = lower(name);
set(data.hndl.(['popSim' name]), 'Value', find(strcmp(data.cfg.sim.(item).type,{data.cfg.db.(item).type})), 'Enable', state);

if any(strcmp(eventdata, {item, 'ptrn', 'findpeaks', 'all'}))
    % remove settings of parameters from menu
    hndlpanel = get(data.hndl.(['popSim' name]), 'Parent');
    delete(findobj(hndlpanel,'Tag',['txtSim' name 'ParamName']));
    delete(findobj(hndlpanel,'Tag',['editSim' name 'Param']));
    data.hndl.(['txtSim' name 'ParamName']) = [];
    data.hndl.(['editSim' name 'Param']) = [];
    % draw UI - add parameters settings - update menu
    dimload;
    psiz = get(data.hndl.(['popSim' name]),'Position');
    tmp = data.cfg.sim.(item);
    if ~isempty(tmp.params)
        parname = setdiff(fieldnames(tmp.params),{'offset', 'resolution'});
        for I = 1:length(parname)
            hndl = uicontrol('Parent',hndlpanel, 'Style', 'text', 'String', [parname{I} ':'], ...
                'Tag', ['txtSim' name 'ParamName'], ...
                'Units', 'pixels', 'Position',  [psiz(1)+120+(I-1)*90, psiz(2), 50, hTxt], ...
                'HorizontalAlignment','right');
            data.hndl.(['txtSim' name 'ParamName']) = [hndl, data.hndl.(['txtSim' name 'ParamName'])];
            hndl = uicontrol('Parent',hndlpanel, 'Style', 'edit', 'String', tmp.params.(parname{I}), ...
                'Tag', ['editSim' name 'Param'], ...
                'Callback', sprintf('SIMToolbox(''editSimPopParam_Callback'',gcbo,''%s'',''%s'')',parname{I}, item),  ...
                'Units', 'pixels', 'Position', [psiz(1)+120+(I-1)*90+60, psiz(2), 30, hEdtBx], ...
                'BackgroundColor','w', 'Enable', state);
            data.hndl.(['editSim' name 'Param']) = [hndl, data.hndl.(['editSim' name 'Param'])];
        end
    end
else
    if isfield(data.hndl,['editSim' name 'Param'])
        set(data.hndl.(['editSim' name 'Param']), 'Enable', state);
    end
end

%-----------------------------------------------------------------------------
function setSimWeights(state,eventdata)
%-----------------------------------------------------------------------------
global data

if any(strcmp(eventdata, {'ptrn', 'ro', 'findpeaks', 'all'}))
    % remove settings of parameters from menu
    hndlpanel = get(data.hndl.textHarmonWeights, 'Parent');
    delete(findobj(hndlpanel,'Tag','txtSimWeigth'));
    delete(findobj(hndlpanel,'Tag','editSimWeigth'));
    data.hndl.txtSimWeigth = [];
    data.hndl.editSimWeigth = [];
    % draw UI - add parameters settings - update menu
    dimload;
    txtwidth = 150;
    psiz = get(data.hndl.textHarmonWeights,'Position');
    for I = 1:length(data.cfg.sim.harmonweight)
        % harmonic
        hndl = uicontrol('Parent',hndlpanel, 'Style', 'text', 'String', sprintf('#%d:',I-1), ...
            'Tag', 'txtSimWeigth', ...
            'Units', 'pixels', 'Position',  [psiz(1)+txtwidth+(I-1)*62-16, psiz(2),  30, hTxt], ...
            'HorizontalAlignment','left');
        data.hndl.txtSimWeigth = [hndl, data.hndl.txtSimWeigth];
        % edit box for weight
        hndl = uicontrol('Parent',hndlpanel, 'Style', 'edit', ...
            'Tag', 'editSimWeigth', ...
            'String', data.cfg.sim.harmonweight(I), 'Enable', state, ...
            'Callback', sprintf('SIMToolbox(''editSimWeigth_Callback'',gcbo,%d)',I),  ...
            'Units', 'pixels', 'Position', [psiz(1)+txtwidth+(I-1)*62, psiz(2), 30, hEdtBx], ...
            'BackgroundColor','w');
        data.hndl.editSimWeigth = [hndl, data.hndl.editSimWeigth];
    end
else
    if isfield(data.hndl, 'editSimWeigth') && ~isempty(data.hndl.editSimWeigth)
        set(data.hndl.editSimWeigth, 'Enable', state);
    end
end

%-----------------------------------------------------------------------------
function setVsmMethods(state,~)
%-----------------------------------------------------------------------------
global data

for I = 1:length(data.cfg.db.vsm)
    if data.cfg.db.vsm(I).applymask && (isempty(data.ptrninfo) || isempty(data.calinfo))
        set(data.hndl.chkbxVsmEval(I), 'Enable', 'off', 'Value', 0);
    else
        set(data.hndl.chkbxVsmEval(I), 'Enable', state, 'Value', data.cfg.vsm.eval(I).enable);
    end
end

%-----------------------------------------------------------------------------
function btnEnable(state,eventdata)
%-----------------------------------------------------------------------------
% This function fills all the text and enables/disables all the buttons
global data

isimginfo = ~isempty(data.imginfo);
isptrninfo = ~isempty(data.ptrninfo) | (isimginfo & isfield(data.imginfo,'pattern'));
iscalinfo = ~isempty(data.calinfo);
isangles = ~isempty(data.cfg.ptrn.angles);
if isimginfo && isptrninfo && ~isnan(data.cfg.ptrn.ro) && (data.imginfo.image.size.seq == ptrngetnumseq(data.ptrninfo, data.cfg.ptrn.ro))
    ismatchimgptrn = 1;
    
elseif isimginfo && ~isptrninfo
    ismatchimgptrn = 1;
else
    ismatchimgptrn = 0;
end

% --- Data ---

set(data.hndl.btnDataChangeDir, 'Enable', state);
set(data.hndl.editDataDir, 'Enable', state);
setDataInfoTxt(state, eventdata);

% --- Pattern and calibration ---

% calibration
set(data.hndl.btnPtrnChangeCalibration, 'Enable', state);
set(data.hndl.editPtrnCalibration, 'Enable', state);
set(data.hndl.btnPtrnRunCalibration, 'Enable', state);
setCalInfoTxt(state, eventdata);

% repz
set(data.hndl.btnPtrnChangeRepz, 'Enable', state);
set(data.hndl.editPtrnRepz, 'Enable', state);
set(data.hndl.popPtrnRunningOrder, 'Enable', state);
setPtrnInfoTxt(state, eventdata);

% offset and blure
if ismatchimgptrn
    set(data.hndl.editPtrnOffset, 'String', data.cfg.ptrn.offset, 'Enable', state);
    if iscalinfo
        set(data.hndl.editPtrnSigmaBlure, 'String', data.cfg.ptrn.blure, 'Enable', state);
    end
else
    set(data.hndl.editPtrnOffset, 'String', '', 'Enable', 'off');
    set(data.hndl.editPtrnSigmaBlure, 'String', '', 'Enable', 'off');
end

% angles
if isfield(data.hndl,'chkbxPtrnAngles') && ~isempty(data.hndl.chkbxPtrnAngles)
    set(data.hndl.chkbxPtrnAngles, 'Enable', state);
end

% --- SR-SIM processing ---

% sim enable
if ismatchimgptrn %ismatchimgptrn && isangles
    simproc = state;
    simenable = data.cfg.sim.enable;
    simupsample = data.cfg.sim.upsample;
else
    simproc = 'off';
    simenable = 0;
    simupsample = 0;
end

set(data.hndl.btnSimFindPeaks, 'Enable', simproc);
set(data.hndl.chkbxSimEnable, 'Value', simenable, 'Enable', simproc);

if data.hndl.chkbxSimEnable.Value && strcmp(simproc,'on')
    sim = 'on';
else
    sim = 'off';
end
setSimParams(sim, eventdata, 'OTF');
setSimParams(sim, eventdata, 'Apodize');
setSimWeights(sim, eventdata);
set(data.hndl.editSimWiener, 'String', data.cfg.sim.wiener, 'Enable', sim);
set(data.hndl.chkbxUpsampleSim, 'Value', simupsample, 'Enable', sim);

% --- MAP-SIM processing ---

% mapsim enable
if ismatchimgptrn %% && isangles %% && iscalinfo
    mapproc = state;
    mapenable = data.cfg.msm.enable;
    mapupsample = data.cfg.msm.upsample;
    mapcuda = strcmp(data.cfg.msm.meth,'CUDA');
else
    mapproc = 'off';
    mapenable = 0;
    mapupsample = 0;
    mapcuda = 0;
end

set(data.hndl.chkbxMapEnable, 'Value', mapenable, 'Enable', mapproc);

if data.hndl.chkbxMapEnable.Value && strcmp(mapproc,'on')
    if data.hndl.chkbxCudaMap.Value
        msim = 'on';
        cuda = 'on';
    else
        msim = 'on';
        cuda = 'off';
    end
else
    msim = 'off';
    cuda = 'off';
end
set(data.hndl.editMsmFc, 'String', data.cfg.msm.fc, 'Enable', msim);
set(data.hndl.editMsmMerging, 'String', data.cfg.msm.wmerg, 'Enable', msim);
set(data.hndl.chkbxCudaMap, 'Value', mapcuda, 'Enable', msim);
set(data.hndl.chkbxUpsampleMap, 'Value', mapupsample, 'Enable', msim);
set(data.hndl.txtMapNote, 'Visible', msim);

% set(data.hndl.editMsmCudaAlpha, 'String', data.cfg.msm.cuda.alph, 'Enable', cuda);
% set(data.hndl.editMsmCudaMaxiter, 'String', data.cfg.msm.cuda.maxiter, 'Enable', cuda);

% --- VSM processing ---

% vsm enable
if ismatchimgptrn
    vsmproc = state;
else
    vsmproc = 'off';
end

setVsmMethods(vsmproc, eventdata);
set(data.hndl.chkbxVsmStripeRemoval, 'Value', data.cfg.vsm.striperemoval, 'Enable', vsmproc);
if iscalinfo
    set(data.hndl.chkbxVsmFlatField, 'Value', data.cfg.vsm.flatfield, 'Enable', vsmproc);
else
    set(data.hndl.chkbxVsmFlatField, 'Value', 0, 'Enable', 'off');
end

% --- Save options ---
% save enable
if ismatchimgptrn
    saveproc = state;
else
    saveproc = 'off';
end

depth16 = data.cfg.save(1).enable;
depth32 = data.cfg.save(2).enable;

set(data.hndl.chkbx16bit, 'Value', depth16, 'Enable', saveproc);
set(data.hndl.chkbx32bit, 'Value', depth32, 'Enable', saveproc);
set(data.hndl.btnSaveChangeDir, 'Enable', saveproc);
set(data.hndl.editSaveDir, 'Enable', saveproc);
setDataInfoTxt(state, eventdata);

% --- Commands ---

% set(data.hndl.btnDefaults, 'Enable', state);
set(data.hndl.btnReset, 'Enable', vsmproc);
set(data.hndl.btnPreview, 'Enable', vsmproc);
set(data.hndl.editPreviewTime, 'String', data.cfg.preview.t, 'Enable', vsmproc);
set(data.hndl.editPreviewZ, 'String', data.cfg.preview.z, 'Enable', vsmproc);
set(data.hndl.btnRun,'Enable',vsmproc);
set(data.hndl.btnQuit, 'Enable', state);

% update menu
drawnow;

%-----------------------------------------------------------------------------
function updateDlgMain(state,eventdata)
%-----------------------------------------------------------------------------
global data
if nargin < 1, state = 'on'; end;
if nargin < 2, eventdata = []; end;

if data.cfg.debug
    fprintf('state: %3s   eventdata: %s\n', state, eventdata);
end

if nargin > 0
    btnEnable(state, eventdata);
end

% eof