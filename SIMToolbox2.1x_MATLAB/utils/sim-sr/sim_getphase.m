function phase = sim_getphase(imft,peakx,peaky,cfg)
% (2013) Wicker K. - Non-iterative determination of pattern phase in 
%                    structured illumination microscopy using 
%                    auto-correlations in Fourier space

siz = size(imft); if numel(siz) > 2, np = siz(3); else, np = 1; end
otf = cfg.sim.otf;
otf.params.offset = [0 0];

OTFfit = single(feval(['apodize_' otf.type],siz(1:2),otf.params));
OTFfitConj = conj(OTFfit);

phase = nan(1,np);
for n = 1:np
    Dn = imft(:,:,n).*OTFfitConj;
    
    % proper calculation
%     DnCorr = xcorr2(Dn); 
%     phase(n) = -angle(DnCorr(round(peaky+size(Dn,1)),round(peakx+size(Dn,2))));
    
    % faster calc. gives the same results as xcorr2
    phase(n) = -angle(xcorr2xy(peakx,peaky,Dn));
end

function c = xcorr2xy(x,y,a,b)
if nargin < 4
	b = a;
end
% Matrix dimensions
adim = size(a);
bdim = size(b);
apad = padarray(a,bdim-1,'post');
bpad = padarray(conj(b),adim-1,'pre');

m = floor(size(apad,1)/2)+1+round(y);
n = floor(size(apad,2)/2)+1+round(x);

tmpa = apad(1:m,1:n);
tmpb = bpad(end-m+1:end,end-n+1:end);
        
c = sum(tmpa(:).*tmpb(:));