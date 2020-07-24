function progressbarGUI(hAxes,varargin)
% Description:
%   progressbar() provides an indication of the progress of some task using
% graphics and text. Calling progressbar repeatedly will update the figure and
% automatically estimate the amount of time remaining.
%   This implementation of progressbar is intended to be extremely simple to use
% while providing a high quality user experience.

persistent progdata

if isstruct(progdata)
    ind = find(cellfun(@(x) isequal(x,hAxes),{progdata.progaxes}));
    if any(ind)
        tmp = progdata(ind);
    end
else
    ind = [];
end

if ~isa(hAxes,'matlab.graphics.axis.Axes')
    disp('First input must be handle to Axes.');
    return;
end

if nargin > 1
    for m = 1:length(varargin)
        switch class(varargin{m})
            case 'char'
                if ismember(varargin{m},{'red','green','yellow','blue','cyan'})
                    tmp.barcol = varargin{m};
                else
                    tmp.txt = varargin{m};
                end
            case 'double'
                tmp.prog = varargin{m};
            otherwise
                disp('Wrong input');
                return;
        end
    end
    if ~isfield(tmp,'barcol'), tmp.barcol = 'green'; end
elseif nargin == 1
%     progdata = [];
    tmp.txt = '';
    tmp.prog = [];
    tmp.barcol = 'green';
end

axes(hAxes);
if ~isfield(tmp,'progaxes')
    cla(hAxes);
    
    tmp.progaxes = hAxes;
    
    tmp.progpatch = patch(hAxes,...
        'XData',[0 0 0 0],'YData',[0 0 1 1],...
        'FaceColor',tmp.barcol,'FaceAlpha',0.5,...
        'EdgeColor','none');
    tmp.progtext = text(hAxes,0.99,0.5,'', ...
        'HorizontalAlignment','Right', ...
        'FontSize',8);
    tmp.proglabel = text(hAxes,0.01,0.5,'', ...
        'HorizontalAlignment','Left', ...
        'FontSize',8);
end

% Update progress patch
if isempty(tmp.prog)
    txtperc = '';
else
    txtperc = sprintf('%2d%%',floor(100*tmp.prog));
end

set(tmp.progpatch,'XData', ...
    [0,tmp.prog,tmp.prog,0],'FaceColor',tmp.barcol)
set(tmp.proglabel,'String',tmp.txt);
set(tmp.progtext,'String',txtperc)

% Force redraw to show changes
drawnow

if nnz(ind)
    if tmp.prog < 1
        progdata(ind) = tmp;
    else
        progdata(ind) = [];
    end
else
    progdata = [progdata tmp];
end

if isempty(progdata)
    clear persistent progdata
end