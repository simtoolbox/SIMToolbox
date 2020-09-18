function f1 = finterp(f,newsize,apod)
% NEWIMAGE = finterp(IMAGE,NEWSIZE,APOD)
% Resizes the image IMAGE using Fourier interpolation.
%
% NEWSIZE is the desired size of the interpolated image.  This can be a
% 2-element vector for non-square images.  If NEWSIZE is a scalar, the
% output image will be square (i.e. NEWSIZE=256 will create a 256x256 image).
%
% APOD is an optional parameter to apodize the image (by a Hanning filter)
% to reduce ringing in the output image
%   APOD = 0 or blank (DEFAULT) -- no apodization
%   0 < APOD < 1 -- Apodize
%
%   The Hanning filter is = 1 for x<xL
%                         = 0 for x>xH
%           between xL and xH, the filter transmission is a half-cycle of cos^2
%   For this function, xH is assumed to be the highest frequency in f, and
%   xL = APOD * xH
%
% Michael Hawks, Department of Engineering Physics, Air Force Institute of
% Technology
% 5 July 2013
if nargin<3, apod=0;
elseif apod>=1, error('ERROR: APOD must be between 0 and 1');
end
if ~ismatrix(f), error('ERROR: FINTERP only defined for 2-D arrays'); end
newsize=[1,1].*newsize;   % ensure newsize is 2D -- if input is one number, this makes a square array
if any(size(f)>newsize), f1=f; return; end
maxI = max(max(f));
minI = min(min(f));
pad = newsize - size(f); % number of elements to add
pad1 = floor(pad/2);     % portion to add to right/top
pad2 = pad - pad1;       % remainder add to left/bottom
F = fft2(f);
Fpad = padarray(fftshift(F),pad1,'pre');
Fpad = padarray(Fpad,pad2,'post');
if apod>0
    [Nx,Ny]=size(Fpad);
    H = 0.5.*size(F);  % use this as the high-freq cutoff (from -H to +H)
    if isodd(Nx);   x = -floor(Nx/2):floor(Nx/2);
    else,           x = -((Nx/2)-1):(Nx/2);
    end
    if isodd(Ny);   y = -floor(Ny/2):floor(Ny/2);
    else,           y = -((Ny/2)-1):(Ny/2);
    end
    filt = hanning(x,apod*H(1),H(1))' * hanning(y,apod*H(2),H(2));
    Fpad = Fpad.*filt;
end
ft = ifft2(ifftshift(Fpad));
f1 = (ft.*conj(ft)).^0.5; % assume we want a real-valued image out, but asymmetric padding could add an
% imaginary componenet so we approximate by SQRT(F F*)
% rescale/normalize the image.  This is kind of a hack, but it should take
% care of everything
f1 = f1 - min(min(f1));  f1 = f1./max(max(f1));
f1 = f1 .* maxI + minI;
% ...............
function i = isodd(x)
i = ( floor(x/2) ~= (x/2) );
% ...............
function f = hanning(x,xL,xH)
if ndims(squeeze(x))==1, x=1:x; dx=1;
else, dx = abs(x(2)-x(1));
end
f=zeros(1,length(x));
if x(1) >= 0  % one-sided filter
    jL = find(abs(x-xL)<dx,1); if isnan(jL); jL=1; end
    jH = find(abs(x-xH)<dx,1); if isnan(jH); jH=length(x); end
    f(1:jL)=1;
    f(jH:end)=0;
    k = jL:jH;      f(k)=0.5 + 0.5*cos(pi*(k-jL)/(jH-jL));
else
    j1 = find(abs(x+xL)<dx,1);  if isnan(j1); j1=1; end
    j2 = find(abs(x-xL)<dx,1);  if isnan(j2); j2=length(x); end
    j3 = find(abs(x+xH)<dx,1);  if isnan(j3); j3=1; end
    j4 = find(abs(x-xH)<dx,1);  if isnan(j4); j4=length(x); end
    f(1:j3)=0;
    f(j4:end)=0;
    f(j1:j2)=1;
    k = j2:j4;      f(k)=0.5 + 0.5*cos(pi*(k-j2)/(j4-j2));
    k = j3:j1;      f(k)=0.5 - 0.5*cos(pi*(k-j3)/(j3-j1));
end