function [calfnlin, calfnrad] = calprocess(datadir)
% SIM camera-microdisplay calibration process
%
% Note that calibration is limited to one channel only.
% If you need to process data with more channels, please
% split the data using, e.g., ImageJ.
%
% See also calconfig

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

% initialize source dir
[calinfo, gdf, cfg] = calinit(datadir);

% detect markers and corners, compute mapping, etc.
[lin, rad] = calprocessimgs(calinfo, gdf, cfg);

% save result
setup = getsetupinfo(calinfo, gdf, cfg);
calfnlin = calsave([cfg.resdir calinfo.data.filemask '_LIN.yaml'], setup, lin);
% calfnrad = calsave([cfg.resdir calinfo.data.filemask '_RAD.yaml'], setup, rad);
calfnrad = [];

timestamp('Calibration finished');
fprintf([repmat('-',1,31) '\n\n']);

% -------------------------------------------------------------------------
function [calinfo, gdf, cfg] = calinit(datadir)
% -------------------------------------------------------------------------

cfg = calconfig();

% read data info
timestamp('Reading file information ...');
calinfo = imginfoinit(datadir);
fprintf('  x:%d  y:%d  z:%d  w:%d\n', calinfo.image.size.x, calinfo.image.size.y, calinfo.image.size.z, calinfo.image.size.w);

% check number of channels
assert(calinfo.image.size.w == 1, 'calinit:channels', 'Calibration is limited to one channel only.');

% read repertoire info - check for *.repz and ptrninfo.txt
timestamp('Reading repz information ...');
cfg.ptrnrepz = ptrndirinfo(calinfo.data.dir);
fprintf('   Using repertoire: %s\n', fileparts_nameext(cfg.ptrnrepz));

% read gdf info
gdf = calloadgdf(cfg.ptrnrepz, 'runningorder', cfg.ptrnro);
gdf.Origin = markers_sort(gdf.Origin);

% autodetect position of calibration/white/black images
timestamp('Detecting white/black/chessboard pattern position ...')
calinfo = detectptrnpos(calinfo);

% autodetect of best focus
timestamp('Detecting best focus  ...')
calinfo.idx.z0 = detectbestfocus(calinfo);
fprintf('  z0 =  %d\n', calinfo.idx.z0);

% images for flat field correction
cfg.imFFwhite = fixresname(cfg.imFFwhite, calinfo.data.dir, calinfo.data.filemask);
cfg.imFFblack = fixresname(cfg.imFFblack, calinfo.data.dir, calinfo.data.filemask);

% initialize result dir
cfg.resdir = fixresname(cfg.resdir, calinfo.data.dir, calinfo.data.filemask);
if ~isdir(cfg.resdir),
  mkdir(cfg.resdir); 
else
  % delete flat field images
  if isfile([cfg.resdir cfg.imFFwhite]), delete([cfg.resdir cfg.imFFwhite]); end
  if isfile([cfg.resdir cfg.imFFblack]), delete([cfg.resdir cfg.imFFblack]); end
end

% -------------------------------------------------------------------------
function inf = getsetupinfo(calinfo, gdf, cfg)
% -------------------------------------------------------------------------

inf.display = cfg.display;
inf.display.origin.x = gdf.Origin(5,1);
inf.display.origin.y = gdf.Origin(5,2);

inf.camera = rmfields(calinfo.camera,{'code','gain','nbit','bitdepth','norm'});

inf.ptrn.repz = fileparts_nameext(cfg.ptrnrepz);
inf.ptrn.ro = cfg.ptrnro;

% add configuration
names = fieldnames(cfg);
idx = strncmp('imFF',names,4) | strncmp('det',names,3);
inf.cfg = rmfield(cfg, names(~idx));

% -------------------------------------------------------------------------
function calinfo = detectptrnpos(calinfo)
% -------------------------------------------------------------------------
% detect position and number of white/black/chessboard patterns
z0 = round(calinfo.image.size.z/2); % assume that the best focus is in the middle
% compute mean intensity of all images in the sequence
avint = zeros(1,calinfo.image.size.seq);
for I = 1:calinfo.image.size.seq
  im = imgload(calinfo, 'z', z0, 'seq', I, 'datatype', 'double');
  avint(I) = mean(im(:));
end
thr2 = (0.1*(max(avint) - min(avint))/2)^2;
idxwhite = (avint - max(avint)).^2 < thr2;
idxblack = (avint - min(avint)).^2 < thr2;
calinfo.idx.calib = find(~(idxwhite | idxblack));
calinfo.idx.white = find(idxwhite);
calinfo.idx.black = find(idxblack);

% -------------------------------------------------------------------------
function z0 = detectbestfocus(calinfo)
% -------------------------------------------------------------------------
% autodetection of the best focus based on FFT power spectra maximum
prof = zeros(1,calinfo.image.size.z);
for Z = 1:calinfo.image.size.z
  % use chessboard pattern
  IM = imgload(calinfo, 'z', Z, 'seq', calinfo.idx.calib, 'datatype', 'double');
  % Parseval´s Theorem: 
  %   1/N * sum(abs(fft2(data)).^2) = sum(abs(data).^2)
  prof(Z) = sum((IM(:)- mean(IM(:))).^2);
end
[~,z0] = max(prof);

% -------------------------------------------------------------------------
function IMff = calimgload(calinfo, Z)
% -------------------------------------------------------------------------
% load images
IMcalib = imgload(calinfo, 'z', Z, 'seq', calinfo.idx.calib, 'datatype', 'double');
IMwhite = imgload(calinfo, 'z', Z, 'seq', calinfo.idx.white(1), 'datatype', 'double');
% IMblack = imgload(calinfo, 'z', Z, 'seq', calinfo.idx.black(1), 'datatype', 'double');

% compensate illumination
IMff = imgflatfield(IMcalib, IMwhite);%, IMblack);

% -------------------------------------------------------------------------
function [lin, rad] = calprocessimgs(calinfo, gdf, cfg)
% -------------------------------------------------------------------------

% detect markers on image with the best focus
timestamp('Detecting markers ...');
IM = calimgload(calinfo, calinfo.idx.z0);
markers = markers_detect(IM, cfg.detmarksigmablure, cfg.detmarkborder);
markers = markers_check(IM, markers);
markers = markers_sort(markers);

% detect corners - estimate x,y,z position with subpixel accuracy
timestamp('Detecting corners ...');
corners = detectcornersinzstack(calinfo, cfg);
fprintf('      Number of detected corners: %d\n', size(corners,1));

% plot detected corners and markers
if cfg.plotdet
  h = figure; clf; imagesc(IM); hold on;
  plot(corners(:,1),corners(:,2),'rx','MarkerSize',3);
  plot(markers(1:4,1),markers(1:4,2),'y+','MarkerSize',3);
  colormap gray; axis image off; set(gca,'Position',[0 0 1 1]); drawnow;
  title(sprintf('Number of detected corners: %d', size(corners,1)));
  print(h,'-dpng','-r408',[cfg.resdir 'detectedcorners.png']);
end

% match chessboard pattern and detected corners 
timestamp('Matching detected corners with the display ...')
[gpts, ipts] = calfindmatch(corners, markers, gdf, cfg);

% compute mapping
lin = getmapping(calinfo, gpts, ipts, @calhomolin, gdf, cfg);
rad = []; %getmapping(calinfo, gpts, ipts, @calhomorad, gdf, cfg);

timestamp('Tilt estimation ...');
%focusPlaneNormVect = 
displaytiltestimation(calinfo, corners, cfg);

% estimate flat field correction
timestamp('Computing flat field correction image ...');
[imFFwhite, imFFblack] = estimateFFcorrection(calinfo);
% save images with flat field correction
imgsave16(calinfo.camera.norm*imFFwhite, [cfg.resdir cfg.imFFwhite]);
imgsave16(calinfo.camera.norm*imFFblack, [cfg.resdir cfg.imFFblack]);

% -------------------------------------------------------------------------
function corners = detectcornersinzstack(calinfo, cfg)
% -------------------------------------------------------------------------

% ----
% find response of a corner detector in all z-stack layers; localized corners are used only to plot

% estimate threshold on an image with best focus
IM = calimgload(calinfo, calinfo.idx.z0);
[foo, IMc] = corners_detect(IM, cfg.detcornsigmablure);
thr = cfg.detcornthr * max(IMc(:));
% find response of a corner detector and coordinates of corners
IMC = zeros([calinfo.image.size.y, calinfo.image.size.x, calinfo.image.size.z], 'double');
if cfg.plotdet, h = figure;  end;
for Z = 1:calinfo.image.size.z
  % load image
  IM = calimgload(calinfo, Z);
  % detect corners - only to plot
  [corners, IMC(:,:,Z)] = corners_detect(IM, cfg.detcornsigmablure,  thr);
  % plot
  if cfg.plotdet
    figure(h); clf; imagesc(IM); colormap gray; axis image off; set(gca,'Position',[0 0 1 1]);
    if ~isempty(corners), hold on; plot(corners(:,1),corners(:,2),'rx'); end;
    set(gcf,'Name',sprintf('%d/%d',Z,calinfo.image.size.z)); drawnow;
  end
end
if cfg.plotdet, close(h); end;

% ----
% estimate [X,Y,Z] coordinates of chessboard corners 

% for [X,Y]: use averaged response of a corner filter over all Z stacks.
IMc = sum(IMC,3);

% estimate aproximate distance between corners 
cprof = sum(IMc,1);
rprof = sum(IMc,2);
[foo,idxc] = locmax1d(cprof, mean(cprof));
[foo,idxr] = locmax1d(rprof, mean(rprof));
cornerdist = median([diff(idxr); diff(idxc)]);

% find coordinates of corners as local maxima in IMc
idx = findlocmax2d(IMc, cfg.detcornthr*max(IMc(:)), 8);
[r,c] = ind2sub([calinfo.image.size.y, calinfo.image.size.x], double(idx));
val = IMc(idx);

% remove points that are too close to each other
[val,idx] = sort(val,'descend');
r = r(idx); c = c(idx);
valid = circfilter([r c], cfg.detcorndst*cornerdist);
r = r(valid); c = c(valid);

 % remove points that are too close to the border
idx = r <= cfg.detsubpixnbr | c <= cfg.detsubpixnbr | r > calinfo.image.size.y-cfg.detsubpixnbr | c > calinfo.image.size.x-cfg.detsubpixnbr;
r(idx) = []; c(idx) = [];

% compute [X,Y] position of corners  to subpixel accuracy
% [rsub, csub] = subpix2d_gradintersect(r, c, IMc, cfg.detsubpixnbr);
[rsub, csub] = subpix2d_fitquadric(r, c, IMc, cfg.detsubpixnbr);

% for [Z]: Compute Z position of corners with subpixel accuracy
zsub = zstackprofmax(r, c, IMC, cfg.detsubpixnbr);

% [X,Y,Z] coordinates of corners
corners = [csub, rsub, zsub];

% -------------------------------------------------------------------------
function zsub = zstackprofmax(r, c, IM, nbr)
% -------------------------------------------------------------------------
% Compute subpixel position in z direction

if isempty(r)
  zsub = [];
  return;
end

[m,n,numz] = size(IM);
numpts = length(r);

% x,y indices of feature points
ind = sub2ind([m,n],r,c);

% add neibourhood coordinates to every feature point in a plane
[x,y] = meshgrid(-nbr:nbr,-nbr:nbr);
x = x(:); y = y(:);
numnbrs = length(x);
indnbr = repmat(ind,1,numnbrs) + repmat((x*m+y)',length(ind),1);

% compute mean value from neighbourhood points in every plane
prof = zeros(numpts,numz);
for Z = 1:numz
  prof(:,Z) = mean(IM(indnbr+m*n*(Z-1)),2);
end

% fitting of 1D gauss by LSQ
z = linspace(0,1,numz);
zsub = zeros(numpts,1);
for I = 1:numpts
  vals = prof(I,:);
  [valmax,idx] = max(vals);
  valmin = min(vals);
  par0 = [z(idx), 0.1, valmax-valmin, valmin];
  par = lmfit1DgaussXSAO(par0,z,vals);
  zsub(I) = par(1);
end

% % parabola fitting by LSQ - does not work right
% z = linspace(0,1,numz)';
% par = prof * pinv([z.^2, z, ones(numz,1)])';
% 
% % subpixel position
% zsub = -par(:,1) ./ par(:,2) / 2;

% interpolated value at subpixel coordinates
% if nargout > 2
%   valsub = sum([zsub.^2, zsub, ones(numpts,1)] .* par,2);
% end

zsub = (numz-1)*zsub + 1;

% -------------------------------------------------------------------------
function [normal, offset] = displaytiltestimation(calinfo, corners, cfg)
% -------------------------------------------------------------------------

% fit plane to detected corners
% corners(:,1) = corners(:,2) * calinfo.image.resolution.x;
% corners(:,2) = corners(:,2) * calinfo.image.resolution.y;
corners(:,3) = (corners(:,3)-(calinfo.image.size.z-1)/2) * calinfo.image.resolution.z;
[U,D,V] = svd([corners(:,1:3) ones(size(corners,1),1)]);
par = V(:,4);
par = par / sqrt(par(1:3)'*par(1:3));

% normal vector of the fitted plane
normal = par(1:3);
offset = par(4);

if cfg.plotdisptilt == 0, return; end;

hfil = fspecialseparable('gauss',41,15);

% distance from the plane to corners 
dst = (corners(:,1) * par(1) + corners(:,2) * par(2) + corners(:,3) * par(3) + par(4));
[X,Y] = meshgrid(1:calinfo.image.size.x,1:calinfo.image.size.y);
C = 1000*griddata(corners(:,1),corners(:,2),dst,X,Y,'nearest');
C = imfilterseparable(C, hfil, 'replicate');

% display surface
h=figure; clf
imagesc(C,[-100 100]); colormap jet; axis image on; colorbar;
% hold on; plot(corners(:,1),corners(:,2),'.')
xlabel('x [pixel]'); ylabel('y [pixel]');
title(sprintf('Surface of the display; color indicates z position in nm'));
drawnow; print(h,'-dpng','-r204',[cfg.resdir 'displaysurface.png']);

% display tilt
Z = griddata(corners(:,1),corners(:,2),corners(:,3),X,Y,'nearest');
Z = imfilterseparable(Z, hfil, 'replicate');
h=figure; clf
surf(X,Y,Z,C,'EdgeColor','none'); colormap jet; colorbar;
v = get(gca,'View'); if mean(Z(end,:)) < mean(Z(1,:)), v = [120 v(2)]; end;  set(gca,'CLim',[-100 100],'View',v);
xlabel('x [pixel]'); ylabel('y [pixel]'); zlabel('z [\mum]');
title(sprintf('Display position: tilt %.0f nm, bend %.0f nm\n', 1000*(max(corners(:,3)) - min(corners(:,3))), max(C(:)) - min(C(:)) ));
drawnow; print(h,'-dpng','-r150',[cfg.resdir 'displayposition.png']);

% -------------------------------------------------------------------------
function [gpts, ipts] = calfindmatch(corners, markers, gdf, cfg)
% -------------------------------------------------------------------------

% estimate of homography from marker points
map = calhomolin(gdf.Origin,markers);

% transform GDF coordinates to square coordinates and define ordering of points
gpts0 = gdf.Origin(5,:);
[th,rsq] = cart2sq(gdf.Data(:,1)-gpts0(1), gdf.Data(:,2)-gpts0(2));
gpts = sortrows([gdf.Data, th, rsq], [4 3]);   % [x y th sq]

% detected corneres in camera image -> GDF (display) + transformation to square coordinates
ipts0 = gpts0;
ipts = cali2w(corners(:,1:2), map); 
[th,rsq] = cart2sq(ipts(:,1)-ipts0(1), ipts(:,2)-ipts0(2));

% figure(1); clf
% imagesc(gdf.IM)
% colormap gray; axis image tight
% %hold on; plot(gpts(:,2),gpts(:,1),'b.','MarkerSize',5)
% for I = 1:100
%   text(gpts(I,2),gpts(I,1),sprintf('%d',I),'HorizontalAlignment','center','Color','b','FontSize',12)
% end
% figure(2); clf;
% plot(gptssq(:,2),gptssq(:,1),'b.','MarkerSize',5)
% for I = 1:100
%   text(gptssq(I,2),gptssq(I,1),sprintf('%d',I),'HorizontalAlignment','center','Color','b','FontSize',12)
% end

% find correspondences - go in a square spiral
if cfg.plotmatch, h = figure; end;
radius = gdf.BoxSize/2;
numipts = size(ipts,1);
idxlist = [];
while (1)
  
  numlist = size(idxlist,1);
  if (numlist == numipts),  break; end;
    
  % find points on a given square for detected corners and define ordering 
  idxiptssq = find(abs(rsq - radius) < gdf.BoxSize/3);
  [iptssq, idx] = sortrows([ipts(idxiptssq,:), th(idxiptssq), rsq(idxiptssq)],3);  % [x y th rsq]
  idxiptssq = idxiptssq(idx);
    
  % find points on a given square for GDF
  idxgptssq = find(abs(gpts(:,4) - radius) < 1E-3);
  gptssq = gpts(idxgptssq,:);
    
  % test if threre are more points detected than GDF contains
  assert(size(iptssq,1) <= size(gptssq,1), 'findmatch:correspondence', 'Error in correspondence matching');
  
  % if less detected corners than in GDF
  if length(idxiptssq) < length(idxgptssq)
    % compute point to point distance
    dst = zeros(size(gptssq,1),size(iptssq,1));
    for I = 1:size(iptssq,1)
      dst(:,I) = ptdist(iptssq(I,:),gptssq);
    end
    % take only nearest points
    [foo,idx] = min(dst,[],1);
    gptssq = gptssq(idx,:);
    idxgptssq = idxgptssq(idx);
  end

  if cfg.plotmatch
    figure(h); clf; imagesc(gdf.Image);    
    colormap gray; axis image off; set(gca,'Position',[0 0 1 1]); % ,'XLim',[400 900 ],'YLim',[300 700]);
    hold on;
    % plot(ipts(:,2),ipts(:,1),'r.')
    for I = 1:size(gptssq,1)
      text(gptssq(I,1),gptssq(I,2),sprintf('%d',I+numlist),'HorizontalAlignment','center','Color','b','FontSize',12)
    end
    for I = 1:size(iptssq,1)
      text(iptssq(I,1),iptssq(I,2),sprintf('%d',I+numlist),'HorizontalAlignment','center','Color','r','FontSize',12)  
    end
    drawnow;
  end
  
  % if the distance between GDF points and detected corners is too high  
  idx = sqrt(sum((iptssq(:,1:2) - gptssq(:,1:2)).^2,2)) > gdf.BoxSize/4;
  if any(idx)    
    % estimate new homography from already matched points
%     map = calhomorad(gpts([idxlist(:,1); idxgptssq],1:2), ...
%                     corners([idxlist(:,2);idxiptssq],1:2));
    map = calhomolin(gpts([idxlist(:,1); idxgptssq],1:2), ...
                    corners([idxlist(:,2);idxiptssq],1:2));
    % remap detected corneres 
    ipts = cali2w(corners(:,1:2), map);
    % transform mapped corners to square coordinates
    [th,rsq] = cart2sq(ipts(:,1)-ipts0(1), ipts(:,2)-ipts0(2));
    continue;
  end
  
  % save indices of matched points
  idxlist = [idxlist; idxgptssq, idxiptssq];
  % go to next square
  radius = radius + gdf.BoxSize;
end

% create final homography
gpts = gpts(idxlist(:,1),1:2);
ipts = corners(idxlist(:,2),1:2);

if cfg.plotmatch, close(h); end;

% -------------------------------------------------------------------------
function  cal = getmapping(calinfo, gpts, ipts, calfnc, gdf, cfg)
% -------------------------------------------------------------------------

% move camera coordinates to ROI of a full camera chip
ipts(:,1) = ipts(:,1) + calinfo.camera.roi.xlim(1) - 1;
ipts(:,2) = ipts(:,2) + calinfo.camera.roi.ylim(1) - 1;

cal.map = calfnc(gpts, ipts);
origin = calw2i(gdf.Origin(5,:), cal.map);
cal.origin.x = origin(1);
cal.origin.y = origin(2);
cal.err = getmaperr(calinfo, gpts, ipts, cal, cfg);

% -------------------------------------------------------------------------
function  err = getmaperr(calinfo, gpts, ipts, cal, cfg)
% -------------------------------------------------------------------------

% map camera image points to display
pts = cali2w(ipts, cal.map);
ddst = sqrt(sum(((pts - gpts).^2),2));

% map display points to camera image
pts = calw2i(gpts, cal.map);
idst = sqrt(sum(((pts - ipts).^2),2));
npts = length(idst);

% compute error
err.numpts = npts;
err.disp2cam = struct('av',mean(idst), 'std', std(idst), 'max', max(idst));
err.cam2disp = struct('av',mean(ddst), 'std', std(ddst), 'max', max(ddst));

if cfg.plotmap == 0
  return;
end

if isfield(cal.map,'Ri2w')
  str = 'RAD';
else
  str = 'LIN';
end

h = figure;
quiver(ipts(:,1),ipts(:,2),pts(:,1)-ipts(:,1),pts(:,2)-ipts(:,2));
set(gca,'XLim',[min(ipts(:,1))-1, max(ipts(:,1))+1],'YLim',[min(ipts(:,2))-1, max(ipts(:,2))+1]);
xlabel('x [pixels]');ylabel('y [pixels]')
title(['Error of mapping the display corners into camera image for ' str ' map' ...
  sprintf('( err_{av}=%.2f \\pm %.2f px,  err_{max}=%.2f px )', ...
  err.disp2cam.av, err.disp2cam.std, err.disp2cam.max)]);
print(h,'-dpng','-r300',[cfg.resdir 'errvectorfield' str '.png']);

h = figure; clf
val = sort([ddst;idst]); binlim = 2*ceil(val(round(0.999*2*npts)));
bin = linspace(0,binlim,100);
cnt1 = hist(ddst,bin);
cnt2 = hist(idst,bin);
bar(bin',[cnt1;cnt2]',2,'LineStyle','none');%,'FaceColor',[0.2 0.2 1])
colormap winter
xlabel('Corner to corner distance [pixels]')
ylabel('Count [-]')
title(['Mapping points with ' str ' map. Total number of points is ' num2str(npts) '.']);
set(gca,'XLim',[0 binlim/2],'YLim',[0 1.2*max([cnt1,cnt2])],'TickDir','out','Box','off','LineWidth',1.5);
legend({sprintf('display2camera ( err_{av}=%.2f \\pm %.2f px,  err_{max}=%.2f px )', err.disp2cam.av, err.disp2cam.std, err.disp2cam.max), ...
        sprintf('camera2display  ( err_{av}=%.2f \\pm %.2f px,  err_{max}=%.2f px )', err.cam2disp.av, err.cam2disp.std, err.cam2disp.max)});
print(h,'-dpng','-r200',[cfg.resdir 'errhistdst' str '.png']);

% -------------------------------------------------------------------------
function [IMwhite, IMblack] = estimateFFcorrection(calinfo)
% -------------------------------------------------------------------------
% compute average of black and white images over the whole Z-stack
IMwhite = 0;
IMblack = 0;
for Z = 1:calinfo.image.size.z
  IMwhite = IMwhite + imgload(calinfo, 'z', Z, 'seq', calinfo.idx.white(1), 'datatype', 'double');
  IMblack = IMblack + imgload(calinfo, 'z', Z, 'seq', calinfo.idx.black(1), 'datatype', 'double');
end
IMwhite = IMwhite/calinfo.image.size.z;
IMblack = IMblack/calinfo.image.size.z;

%eof
