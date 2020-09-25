function gen_descfile(outputFile, data)
% generate a text file with description of the data

% Copyright © 2015 Tomas Lukes, lukestom@fel.cvut.cz
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

sx = data.prepdir.sx;
sy = data.prepdir.sy;
sz = data.prepdir.sz;
t = data.prepdir.st;


pxsize = getval(data.prepdir,'pxsize');
pysize = getval(data.prepdir,'pysize');
pzsize = getval(data.prepdir,'pzsize'); 
bdepth = data.prepdir.bdepth; 

t1 = sum(data.prepdir.numphases(1:data.prepdir.numangles));

zdepth = (sz - 1)*pzsize;

% Create content of the text file
A{1} = sprintf('%s',['Type : ',num2str(bdepth),' bit grey/pseudo']); 
A{2} = sprintf('%s',['x : ',num2str(sx),' * ',num2str(pxsize),' : um']); 
A{3} = sprintf('%s',['y : ',num2str(sy),' * ',num2str(pysize),' : um']); 
A{4} = sprintf('%s',['Time1 : ',num2str(t1)]);
A{5} = sprintf('%s',['Time1 : ',num2str(t1)]);
A{6} = sprintf('%s',['Time : ',num2str(t)]);
A{7} = sprintf('%s',['Z : ',num2str(sz)]);

A{8} = sprintf('%s','[Protocol Description]');
A{9} = sprintf('%s',['Repeat Z - ',num2str(zdepth),' um in ', num2str(sz),' planes (start)']);
A{10} = sprintf('%s',['Repeat T - ',num2str(t),' times (0 ms - fastest) ']);

A{11} = sprintf('%s',['Repeat T1 - ',num2str(t1),' times (0 ms - fastest) ']);
A{12} = sprintf('%s',['End - T1']);
          
A{13} = sprintf('%s',['End - T']);
A{14} = sprintf('%s',['End - Z']);
A{15} = sprintf('%s','[Protocol Description End]');
A{16} = sprintf('%s','[Tab Device Info]');
A{17} = sprintf('%s','Camera=DC-152Q-C00-FI 1348');
A{18} = sprintf('%s',['BitDepth=',num2str(bdepth)]); 
A{19} = sprintf('%s','[Tab Device Info End]');
A{20} = -1;
A = A';

% Write cell A into txt
fid = fopen(outputFile, 'w');
for i = 1:numel(A)
    if A{i+1} == -1
        fprintf(fid,'%s', A{i});
        break
    else
        fprintf(fid,'%s\r\n', A{i});
    end
end
fclose(fid);
end

function val = getval(val,fieldname)
    if isfield(val,fieldname)
        val = getfield(val,fieldname);   
    else
        val = 0.05;
    end
end
