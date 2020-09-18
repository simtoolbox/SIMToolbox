function  [peaks,angl,k0,phaoff] = sim_findpeaks(imfft,method,ptrn,calinfo,cfg,idx,ax)
% Find position of peaks in an image
% 
%   peaks = sim_findpeaks(im, method, ptrn, calinfo, cfg)
% 
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

imfft_abs = log(mean(abs(imfft),3));
switch method.type
    case 'calibration'
        assert(~isempty(calinfo),'sim:findpeaks:calibr','Calibration not found.');
        if isfield(calinfo.cal.map,'Rw2i')
            % calibration_RAD: perform radial correction to virtual image
            error('sim:findpeaks:rad','Radial correction not implemented.');
        else
            % calibration_LIN: find peaks computationally (don't need to create pattern, not even to do any FFTs)
            [period,peaks,angl,k0,fit] = sim_findpeaks_calhomolin(imfft_abs,ptrn,calinfo);
            phaoff = 0;
        end
    case 'spotfinder'
        % no calibration - find peaks in the data
        [period,peaks,angl,k0,fit] = sim_findpeaks_data(imfft_abs,ptrn,method,idx);
        if ~isempty(peaks(1).x)
            cnt = ceil((size(imfft_abs)+1)/2);  % image center
            peakVal = squeeze(imfft(round(cnt(1)+peaks(1).y),round(cnt(2)+peaks(1).x),:));
            phasSort = sort(angle(peakVal) - 2*pi*(0:ptrn.num-1)'/ptrn.num);
            phasDiff = diff(phasSort);
            phaoff = mod(mean(phasSort(find(min(phasDiff)):find(min(phasDiff))+1)),2*pi);
        else, phaoff = NaN;
        end
    case 'manual'
        [period,peaks,angl,k0,fit] = sim_findpeaks_manual(imfft_abs,ptrn,method,idx);
        phaoff = cfg.db.manual.phsoff(idx);
    otherwise
        error('sim:findpeaks:method','Unknown method.');
end

if ~strcmp(method.type,'calibration') && ~isempty(peaks(1).x)
    
else
    
end

if cfg.plotpeaks
    sim_findpeaks_draw(imfft_abs,period,peaks,k0,fit,ax);
    
    spacPrint = (1e3*cfg.sim.otf.params.resolution)*k0;
    ang = wrapToPi(pi-angl)*180/pi;
    if ang<0, ang = 180+ang; end
    switch method.type
        case 'calibration'
            title(sprintf('Calibration\nAngle: %.0f° Spacing: %.0f nm',...
                ang,spacPrint));
        otherwise
            title(sprintf('Estimation\nAngle: %.0f° Spacing: %.0f nm',...
                ang,spacPrint));
    end
end

%--------------------------------------------------------------------------
function [period,pos,angl,k0,fit] = sim_findpeaks_calhomolin(im,ptrn,calinfo)
%--------------------------------------------------------------------------
% estimate period and angle using the calibration
fit = [];

% DISPLAY: two points, angle, direction vector
Aw = [calinfo.setup.display.origin.x,calinfo.setup.display.origin.y]; % origin
angl = ptrn.angle*pi/180;       % angle of the line pattern
vect = [sin(angl) cos(angl)];	% direction vector
Bw = Aw + ptrn.period*vect;     % second point

% CAMERA: two points
Ai = calw2i(Aw,calinfo.cal.map,calinfo.setup.camera.roi);
Bi = calw2i(Bw,calinfo.cal.map,calinfo.setup.camera.roi);
period = sqrt(sum((Ai-Bi).^2));	% line period in the camera
n = [Bi(2)-Ai(2),Bi(1)-Ai(1)];  % normal vector
n = sign(n(1))*n;               % move n to 1st or 2nd quadrant
angl = atan2(n(1),n(2));        % line angle in the camera

% theoretical position of the 1st harmonics
siz = size(im);
xrad = siz(2)/period;     % x-axis lenght for 1st harmonics
yrad = siz(1)/period;     % y-axis lenght for 1st harmonics

% position of peaks with respect to the center
pos = struct('x',{},'y',{});
for harmon = 1:ptrn.numharmon
    pos(harmon).x = harmon*xrad*cos(angl);
    pos(harmon).y = harmon*yrad*sin(angl);
end
k0 = period;

%--------------------------------------------------------------------------
function [period,pos,angl,k0,fit] = sim_findpeaks_data(im,ptrn,method,idx)
%--------------------------------------------------------------------------
% find position of peaks in the image
try
    fit = spotfinder(im, method.params.filter, method.params.detector, method.params.estimator);
catch err
    fit.x = [];
    fit.y = [];
end

% convert positions of peaks to polar coordinates
siz = size(im);
cnt = ceil((siz+1)/2);
scale = siz(2)/siz(1);  % scale y to get a circle
[th,rad] = cart2pol(fit.x-cnt(2),scale*(fit.y-cnt(1)));

% take only points close to the illumination pattern period (radial distance threshold)
period = method.params.radius(idx);
xrad = siz(2)/period;	% position of 1st harmonics
pos = struct('x',{},'y',{}); num = cell(1,ptrn.numharmon);
for harmon = 1:ptrn.numharmon
    idx = abs(rad - harmon*xrad) < xrad*method.params.radiusthr;
    pos(harmon).x = fit.x(idx) - cnt(2);
    pos(harmon).y = fit.y(idx) - cnt(1);
    num{harmon} = repmat(harmon, sum(idx),1);
end

% refine position of peaks - peaks lie on a line passing through the center, harmonics are equidistant
A = [cat(1,pos.x), -cat(1,pos.y)*scale];
if isempty(A), angl = NaN; k0 = NaN; return; end
[U,D,V] = svd(A);               % compute normal vector of the line passing through the center using LSQ
n = V(:,2); n = n/sqrt(n'*n);   % normal vector
n = sign(n(1))*n;               % move n to 1st or 2nd quadrant
angl = atan2(n(1),n(2));        % angle of the line

% estimate position of the 1st harmonic
num = cat(1,num{:});
s = [n(2);-n(1)];               % directin vector
d = A*s; idx = d>0;             % take only peaks on a halfplane
xrad = mean(d(idx)./num(idx));	% mean distance of 1st harmonics
yrad = xrad/scale;

% position of peaks with respect to the center
pos = struct('x',{},'y',{});
for harmon = 1:ptrn.numharmon
    pos(harmon).x = harmon*xrad*cos(angl);
    pos(harmon).y = harmon*yrad*sin(angl);
end
k0 = siz(2)/xrad;

%--------------------------------------------------------------------------
function [period,pos,angl,k0,fit] = sim_findpeaks_manual(im,ptrn,method,idx)
%--------------------------------------------------------------------------
fit = [];

siz = size(im);
scale = siz(2)/siz(1);  % scale y to get a circle

% theoretical position of the 1st harmonics
angl = method.params.angl(idx);
period = method.params.radius(idx);

xrad = siz(2)/method.params.k0(idx);	% x-axis lenght for 1st harmonics
yrad = xrad/scale;                      % y-axis lenght for 1st harmonics

pos = struct('x',{},'y',{});
for harmon = 1:ptrn.numharmon
    pos(harmon).x = harmon*xrad*cos(angl);
    pos(harmon).y = harmon*yrad*sin(angl);
end
k0 = method.params.k0(idx);

%--------------------------------------------------------------------------
function sim_findpeaks_draw(im,period,peaks,k0,fit,ax)
%--------------------------------------------------------------------------

% show FFT spectra
imagesc(ax,im); hold(ax,'on'); axis(ax,'off');

% show all detections
if nargin > 3 && ~isempty(fit)
    plot(ax,fit.x,fit.y,'g+');
end

% image size and image centers
siz = size(im); cnt = ceil((siz+1)/2);

% zero harmonics
plot(ax,cnt(2),cnt(1),'xm','MarkerSize',12,'Linewidth',2);

% radius of the 1st harmonics
rad = siz./period;
rad_k0 = siz./k0;

t = linspace(0,2*pi,1000);
for harmon = 1:length(peaks)
        
    % circle with k0 corresponding to a given harmonics
    x = harmon*rad_k0(2)*cos(t)+cnt(2);
    y = harmon*rad_k0(1)*sin(t)+cnt(1);
    plot(ax,x,y,'m');
    
    % circle with radius corresponding to a given harmonics
    x = harmon*rad(2)*cos(t)+cnt(2);
    y = harmon*rad(1)*sin(t)+cnt(1);
    plot(ax,x,y,'g-.');
    
    % plot selected peaks
    plot(ax,cnt(2)+peaks(harmon).x,cnt(1)+peaks(harmon).y,'xm','MarkerSize',12,'Linewidth',2);
    plot(ax,cnt(2)-peaks(harmon).x,cnt(1)-peaks(harmon).y,'xm','MarkerSize',12,'Linewidth',2);
end
hold(ax,'off'); daspect(ax,[siz(2)/siz(1) 1 1]);

%eof