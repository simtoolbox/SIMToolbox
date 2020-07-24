function seq = sim_shiftspectra(seq, ptrn, params)
% Shift of extracted FFT components is based on modulation property
% of Fourier transform (multiply in image space ~ shift in FFT)
% h(x)=exp(2*pi*i*x*X0)*f(x)   <->   H(X0) = F(X-X0)
%
%   seq = sim_shiftspectra(seq, ptrn)
%
% Input/output arguments:
%
%   seq         ... [struct]  image sequence (created by seq2subseq)
%   ptrn        ... [struct]  running order data (created by ptrnchecklines)
%   params      ... [struct]  additional parameters and settings
%
% Note that seq.Sk.S must be an image and not fft.
%
% See also seqload, seq2subseq, ptrnload, ptrnchecklines, sim_extract

% Copyright © 2009-2015 Pavel Krizek, Tomas Lukes, lukestom@fel.cvut.cz
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

siz = size(seq(1).Sk(1).S);
[x,y] = meshgrid(1:siz(2),1:siz(1));
x = x/siz(2);
y = y/siz(1);


for I = 1:length(seq)
    seq(I).Sk = shiftspectra(seq(I).Sk,ptrn(I).pos,params);
end

% ----------------------------------------------------------------------------

    function Sk = shiftspectra(Sk,pos,params)
        
        for J = 1:length(Sk)
            if Sk(J).comp == 0
                offset = [0 0];
            else
                % shift is in oposite direction to the peak position, therefore "-"
                offset = - sign(Sk(J).comp) * pos{abs(Sk(J).comp)} .* siz;
            end
            % applying modulation property and make FFT
            Sk(J).S = seqfft2( Sk(J).S .* exp(2*pi*1i * (offset(1)*y + offset(2)*x)) );
        end
        
    end

end

%eof