function markers = markers_check(IM, markers)
% Visual check if markers are detected correctly.
% Function shows and image and up to 4 markers.
% Click mouse to add/remove marker.
% Four markers are required to enable OK button.
%
%   markers = markers_check(IM, markers)
%
% Input/output arguments:
%
%   IM        ... [m x n]    input image
%   markers   ... [npts x 2] [X,Y] coordinates of markers
%
% See also markers_detect

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

imsiz = size(IM);

markers = markers(1:min(4,size(markers,1)),:);

hfig = figure('WindowButtonDownFcn',@markers_mouseclick_callback,'toolbar','figure','UserData',0);
imagesc(IM); colormap gray;  axis image off; hold on
hplot = plot(markers(:,1),markers(:,2),'rx');  
title('Set markers to their position');

% create ok button
pos = get(hfig,'Position');
hbtn = uicontrol('Parent',hfig, 'Style', 'pushbutton', 'String', 'OK', ...    
    'Callback',@markers_okbtn_callback, 'Units', 'pixels', 'Position', [pos(3)/2 10 50 20]);   

% Four markers are required
if size(markers,1) == 4
  set(hbtn,'Enable','on');
else
  set(hbtn,'Enable','off');
end

% wait until OK button is pressed
waitfor(hfig,'UserData',1)

% clean up
close(hfig);

  function markers_mouseclick_callback(src, evnt)
  
    % get mouse position
    pt = get(gca, 'CurrentPoint');
    pos = pt(1,[1 2]);

    if pos(1) < 1 || pos(1) > imsiz(2) || pos(2) < 1 || pos(2) > imsiz(1)
      return;
    end

    if size(markers,1) > 3   
      % get distance to every point
      dst = ptdist(pos,markers);  
      % remove the closest point
      [val,idx] = min(dst);
      if val < 50    
        markers(idx,:) = [];
        set(hplot,'Xdata',markers(:,1)','Ydata',markers(:,2)');
      end  
    else  
      % add current mouse positoin
      markers = [markers; pos];
      set(hplot,'Xdata',markers(:,1)','Ydata',markers(:,2)');
    end
    
    if size(markers,1) == 4
      set(hbtn,'Enable','on');
    else
      set(hbtn,'Enable','off');
    end

  end %markers_mouseclick_callback
  
  function markers_okbtn_callback(src, evnt)

    % quit if 4 markers are in place
    if size(markers,1) == 4
      set(hfig,'UserData',1);
    end
    
  end %markers_okbtn_callback

end %markers_check

%eof