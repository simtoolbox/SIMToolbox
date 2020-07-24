function iqinf = iq2parse(filename)
% Parser of IQ2 grab protocol.
%
%   iqinf = iq2parse(filename)
%
% Input/output arguments:
%
%   filename  ... [string] name of a text file with IQ2 protocol
%   iqinf     ... [struct]  parsed IQ2 protocol
%
% See also iq2getinfo, imginfoinit

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

assert(isfile(filename), 'iq2parse:nofile', 'File with IQ2 grab protocol does not exist.');

% read iq file
desc = fileread(filename);
lnend = find(desc == 10);
lnbegin = [1, lnend(1:end-1)+1];
lnnum = length(lnbegin);
iqinf = [];
strsec = 'Header';

% parse values
for I = 1:lnnum
    
    % read one line
    lnstr = desc(lnbegin(I):lnend(I));
    % skip empty line
    if ~any(lnstr > ' '), continue; end;
    
    % start/finish section
    if lnstr(1) == '['
        if ~isempty(strfind(lnstr, ' End]')), strsec = ''; continue; end;
        strsec = fixname(lnstr(2:(find(lnstr == ']')-1)));
        continue;
    end
    
    assert(~isempty(strsec), 'iq2parse:nosection','Missing section name.');
    
    % sections fork
    switch (strsec)
        case 'ProtocolNodeList'
            continue;
        case 'ProtocolDescription'
            if isfield(iqinf.Header,'UserGuy')
                [name,val] = readvar(lnstr,9); % old IQ protocol
            else
                [name,val,secname,secval] = readprotocol(lnstr,'-');
                if ~isempty(secname),
                    iqinf.(strsec).(secname) = secval;
                end;
            end
        case 'Header'
            [name,val] = readvar(lnstr,':');
        otherwise
            [name,val] = readvar(lnstr,'=');
    end;
    
    % assign value to a field
    if ~isempty(name),
        iqinf.(strsec).(name) = val;
    end
    
end

% ----------------------------------------------------------------------------
function [name,val] = readvar(str,sgn)
% ----------------------------------------------------------------------------
% parse name and value in a line string
idx = find(str == sgn,1,'first');
if isempty(idx), name = fixname(str); val = []; return; end;
name = fixname(str(1:(idx-1)));
val = fixval(str((idx+1):end));

% ----------------------------------------------------------------------------
function str = fixname(str)
% ----------------------------------------------------------------------------
% string contains only letters and numbers
str( (str < 'A' | str > 'Z') & (str < 'a' | str > 'z') & (str < '0' | str > '9') & str ~= '_') = [];
if ((str(1) >= '0') && (str(1) <= '9')), str = ['x' str]; end;

% ----------------------------------------------------------------------------
function val = fixval(str)
% ----------------------------------------------------------------------------
% out: str or double
str(str == 9) = []; % tab
str(str < ' ') = []; % control characters
if (isempty(str)),  val = []; return; end;
idx = find(str > ' ',1,'first'); str = str(idx:end); % no space at the beginning
num = str2double(str);
if isnan(num),
    val = str;
else
    val = num;
end

% ----------------------------------------------------------------------------
function [name,val,secname,secval] = readprotocol(lnstr,sgn)
% ----------------------------------------------------------------------------
persistent strsec tmp numTABsec chnlname

numtab = sum(lnstr == 9);
[name,val] = readvar(lnstr,sgn);
secname = []; secval = [];

% fix some commands and return
if ~isempty(strfind(name,'MoveScanZ'))
    val = str2double(name(name >= '0' & name <= '9')); name = 'MoveScanZ';
elseif strcmp(name,'ChannelDescription')
    name = [];
elseif strcmp(name,'Snap') && ~isempty(chnlname)
    name = fixname([name '_' chnlname]);
elseif strcmp(name,'Repeat') && ~isempty(strfind(val,'Channel'))
    name = 'RepeatChannel';
elseif strfind(name,'End'),
    name = [name val]; val = [];
end

if ~isempty(strsec)
    % set section XYPositions
    if strcmp(name,'XYPositions')
        val = [name ' ' val]; name = strsec;
        strsec = 'XYPositions';
        numTABsec = numtab + 1;
        return
    end
    % other sections
    if numtab >= numTABsec
        % add to section
        tmp.(name) = val;
        name = []; val = [];
        return
    else
        % finish section + keep name and val from the current line
        secname = strsec; secval = tmp; tmp = []; strsec = [];
    end
end

% test and fix different section
if strcmp(name,'MoveChannel') || strcmp(name,'Channel')
    if strcmp(name,'MoveChannel'), chnlname = val; else chnlname = []; end;
    strsec = fixname(['Channel_' val]);
    numTABsec = numtab + 1;
    name = []; val = [];
elseif strcmp(name,'Repeat') && ~isempty(strfind(val,'XY'))
    strsec = 'RepeatXY';
    numTABsec = numtab + 1;
    name = []; val = [];
elseif strfind(name,'Events')
    strsec = 'Events';
    numTABsec = numtab + 1;
    name = []; val = [];
end

%eof