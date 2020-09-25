% function sim_findpeaks_corr(seq)

clear;
addpath(genpath('utils'));
load('data_to_shift_spectra.mat');

% Match side spectra with central spectra as a reference
numangles = length(seq);
thr = [0.5 0.3];
for m = 1:numangles
    sequen = seq(m);
    
    % harmonic components
    comp = [sequen.Sk.comp];
    numharmon = (length(comp)-1)/2;
    
    % initial reference = central spectra
    Sk = sequen.Sk(comp == 0);
    
    % for all harmonics
    for n = 1:numharmon
        % positive band
        idx = comp == n;
        [s, maska] = sim_matchspectra(sequen.Sk(idx), Sk, thr(n));
        
        disp(['Angle: ' num2str(seq(m).angle) 'harm: ' num2str(n) '. s = ' num2str(s)]);
        
        sequen.Sk(idx).O = s * sequen.Sk(idx).O;
        sequen.Sk(idx).mask = maska;
%         Sk = sequen.Sk(idx); % go to next Sk    (or stay with Sk0?)
        
        % negative band
        idx = comp == -n;
        sequen.Sk(idx).O = conj(s) * sequen.Sk(idx).O;
        sequen.Sk(idx).mask = rot90(maska,2);
    end
    
    seq(m) = sequen;
end

%% correlation Band0 and Band1
an = 2; % angle

comp = [seq(an).Sk.comp];

% zero component
idx = comp == 0;
b0 = seq(an).Sk(idx).S;

idx = comp == 1;
b11 = seq(an).Sk(idx).S;
CRb11 = seq(an).Sk(idx).mask;

idx = comp == -1;
b12 = seq(an).Sk(idx).S;
CRb12 = seq(an).Sk(idx).mask;


figure(98);
subplot(231); imshow(log10(abs(b11)),[]);
subplot(232); imshow(log10(abs(b0)),[]);
subplot(233); imshow(log10(abs(b12)),[]);

subplot(234); imshow(CRb11);
subplot(235); imshow(CRb11 + CRb12);
subplot(236); imshow(CRb12);


correla = xcorr2(CRb11*b11,CRb11*b0);

figure(99);
imshow(correla,[]);
surf(abs(correla));
%%
b1 = 4; % band to compare
spek0 = seq(an).Sk(3).S;
spek1 = seq(an).Sk(b1).S;

% commonRegion
commonRegion = seq(an).Sk(b1).mask;

%% OTF

otf0 = abs(seq(an).Sk(3).O);
otf1 = abs(seq(an).Sk(b1).O);

figure(41); imshow(cat(3,zeros(size(otf0)),otf0,otf1));


%% Spectra
sp2sh0 = log10(abs(spek0));
sp2sh0 = sp2sh0 - min(sp2sh0(:));
sp2sh0 = sp2sh0./max(sp2sh0(:));

sp2sh1 = log10(abs(spek1)); 
sp2sh1 = sp2sh1 - min(sp2sh1(:));
sp2sh1 = sp2sh1./max(sp2sh1(:));

spek2show = cat(3,0.5.*commonRegion,sp2sh0,sp2sh1);

figure(42); 
subplot(131); imshow(cat(3,zeros(size(sp2sh0)),sp2sh0,zeros(size(sp2sh0))));
subplot(132); imshow(spek2show);
subplot(133); imshow(cat(3,zeros(size(sp2sh0)),zeros(size(sp2sh0)),sp2sh1),[]);



