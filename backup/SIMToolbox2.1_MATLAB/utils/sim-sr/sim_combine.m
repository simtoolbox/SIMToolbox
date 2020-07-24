function [IM,IMfft] = sim_combine(seq,cfg)
% Combining spectra components according to Gustafsson

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


% Match componets based on central spectra
seq = matchcentralspectra(seq);

% Match side spectra with central spectra as a reference
numangles = length(seq);
for I = 1:numangles
    seq(I) = matchwithcentral(seq(I),0.3);
end

% combining all side spectra with central spectra
S = 0; O2 = 0;
for I = 1:numangles
    comp = [seq(I).Sk.comp];
    for J = 1:length(comp)
        Skp = seq(I).Sk(J).S;
        Okp = seq(I).Sk(J).O*cfg.harmonweight(abs(comp(J))+1);
        S = S + Okp.*Skp;
        O2 = O2 + abs(Okp).^2;
    end
end

% wiener filter + apodizing
A = feval(['apodize_' cfg.apodize.type],size(S),cfg.apodize.params);

IMfft = S.*A./(O2+cfg.wiener);

if cfg.upsample
    IM = fftInterpolate(IMfft,size(IMfft)*2);
else
    IM = real(seqifft2(IMfft));
end

IM(IM<0) = 0;

% ----------------------------------------------------------------------------

function seq = matchcentralspectra(seq)

% reference (central spectra of the 1st angle)
Sk0 = seq(1).Sk([seq(1).Sk.comp] == 0);

% for all other angles
for I = 2:length(seq)
    
    % match central Sk with the reference
    s = sim_matchspectra(seq(I).Sk([seq(I).Sk.comp] == 0),Sk0);
    
    % for all phases
    for J = 1:length(seq(I).Sk)
        seq(I).Sk(J).S = s*seq(I).Sk(J).S;
    end
    
end

% ----------------------------------------------------------------------------

function seq = matchwithcentral(seq,thr)

% harmonic components
comp = [seq.Sk.comp];
numharmon = (length(comp)-1)/2;

% initial reference = central spectra
Sk = seq.Sk(comp == 0);

% for all harmonics
for I = 1:numharmon
    % positive band
    idx = comp == I;
    s = sim_matchspectra(seq.Sk(idx),Sk,thr);
    seq.Sk(idx).O = s*seq.Sk(idx).O;
    Sk = seq.Sk(idx); % go to next Sk    (or stay with Sk0?)
    % negative band
    idx = comp == -I;
    seq.Sk(idx).O = conj(s)*seq.Sk(idx).O;
end
