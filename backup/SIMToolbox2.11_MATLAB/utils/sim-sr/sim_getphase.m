function phase = sim_getphase(imft,peakx,peaky,cfg)
% (2013) Wicker K. - Non-iterative determination of pattern phase in 
%                    structured illumination microscopy using 
%                    auto-correlations in Fourier space

siz = size(imft); if numel(siz) > 2, np = siz(3); else, np = 1; end
otf = cfg.sim.otf;
otf.params.offset = [0 0];

OTFfit = single(feval(['apodize_' otf.type],siz(1:2),otf.params));
OTFfitConj = conj(OTFfit);

phase = nan(np,1);
for n = 1:np
    Dn = imft(:,:,n).*OTFfitConj;
    phase(n) = -angle(xcorr2xy(peakx,peaky,Dn));
end