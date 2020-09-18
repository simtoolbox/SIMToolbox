function seq = sim_addOTF(seq,ptrn,otf)
% Add OTF to the image sequence. The center of OTFs is shifted
% according to position of peaks.
% 
%   seq = sim_addOTF(seq, ptrn, otf)
% 
% Input/output arguments:
% 
%   seq         ... [struct]  image sequence (created by seq2subseq)
%   ptrn        ... [struct]  running order data (created by ptrnchecklines)
%   otf         ... [struct]  OTF definition, see apodize_*
% 
% See also seqload, seq2subseq, ptrnload, ptrnchecklines, apodize_*

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

% for all angles
for I = find([ptrn.enable])
    seq(I).Sk = addOTF(seq(I).Sk,ptrn(I).pos,otf);
end

% ----------------------------------------------------------------------------

function Sk = addOTF(Sk,pos,otf)

siz = size(Sk(1).S);
[Sk(:).O] = deal([]);
% for all components
for J = 1:length(Sk)
    if Sk(J).comp == 0
        % zero component
        otf.params.offset = [0 0];
    else
        % shift is in oposite direction to the peak position, therefore "-"
        otf.params.offset = -sign(Sk(J).comp)*pos{abs(Sk(J).comp)}.*siz;
    end
    % generating OTF
    Sk(J).O = single(feval(['apodize_' otf.type],siz,otf.params));
end

%eof