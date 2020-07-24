function cam = reshapePrismData(cam)
% Normalize mean for illumination pattern images, discard empty frames

cam.means = squeeze(mean(mean(cam.rawdata,1),2));
cam.emptyFrames = cam.means>120;

cam.meanMax = max(cam.means);
cam.imWeights = cam.meanMax./cam.means;
cam.imWeights = cam.imWeights(cam.emptyFrames);
cam.im = double(cam.rawdata(1:510,:,cam.emptyFrames));
cam.im = cam.im.*repmat(permute(cam.imWeights,[2, 3, 1]),size(cam.im,1),size(cam.im,2));
cam.imav = mean(cam.im,3);

% reshape and reorder illumination pattern images in different z planes
% stack has the following order: phase, angle, z, t
[sy, sx, szt] = size(cam.im);

cam.im = reshape(cam.im,sy,sy,4,[]);
cam.imav = reshape(cam.imav,sy,sy,4,[]);
