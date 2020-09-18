% Register SIM images from 8 plane prism

clear all; close all;
addpath('C:\Users\Lukestom\gitcodes\myutils');

ph = 'C:\Users\Lukestom\Downloads\MFSim\cellMito03__reshaped2\results';

fn = 'cellMito03__reshaped2_mapsim';
fn2 = 'cellMito03__reshaped2_av';

% loadstack
mapsim = double(load_tifFile([ph,filesep,fn,'.tif'],[],[]));

%% Register XY, coarse
[img_reg, shifts1] = registerXY(mapsim,2);

%% Brute force angle search
[sy,sx,sz] = size(mapsim);
angleRange = -2:0.02:+2;
count = 1;
img_reg(isnan(img_reg)) =0;

for ii = 1:size(mapsim,3)-1
    
    im1 = img_reg(:,:,ii);
    im2 = img_reg(:,:,ii+1);
    
    for angle = angleRange
        
        im2rot = imrotate(im2,angle,'crop');
        cor(count) = corr2(im1,im2rot);
        count = count +1;
    end
    count = 1;
    [~,maxCorIndx] = max(cor);
    rot(ii) = angleRange(maxCorIndx);   
    disp(ii);
end


img_regrot(:,:,1) = img_reg(:,:,1);
for ii = 1:size(mapsim,3)-1
    img_regrot(:,:,ii+1) = imrotate(img_reg(:,:,ii+1),sum(rot(1:ii)),'crop');
    disp(ii)
end

%% Register xy, fine 

[img_reg2, shifts2] = registerXY(img_regrot,5);

%% Show registered images
figure,
for ii = 1:8
    imshow(img_reg2(:,:,ii),[]);
    pause;
end

%% Save aligned stack
outputPath = [ph];
fileName = [fn,'_aligned'];
saveImageStack(img_reg2,outputPath,fileName,[])

%% Align WF image stack

% loadstack
wf = double(load_tifFile([ph,filesep,fn2,'.tif'],[],[]));

[img_wf, ~] = registerXY(wf,2,shifts1); % registerXY, use shifts estimated from mapsim, coarse

img_wf(:,:,1) = img_wf(:,:,1);
for ii = 1:size(mapsim,3)-1
    img_wf(:,:,ii+1) = imrotate(img_wf(:,:,ii+1),sum(rot(1:ii)),'crop');
    disp(ii)
end

[img_wf, ~] = registerXY(img_wf,5,shifts2); % registerXY, use shifts estimated from mapsim, fine

%% Save aligned stack
outputPath = [ph];
fileName = [fn2,'_aligned'];
saveImageStack(img_wf,outputPath,fileName,[])
%% Save montage

%%%%%
% find out rotation and zoom use log polar coordinates
% [sy,sx,sz] = size(mapsim);
% 
% for ii = 1:size(mapsim,3)-1
%     
%     im1 = imlogpolar(double(mapsim(:,:,ii)),sy,sx,'bilinear');
%     im2 = imlogpolar(double(mapsim(:,:,ii+1)),sy,sx,'bilinear');
%     
%     [dx, dy] = ccrShiftEstimation(im1,im2,2);
%     shifts(ii,:) = [dx,dy];
%     disp(ii);
% end
% % I = imread('ic.tif');
% % J = imlogpolar(I,64,64,'bilinear');
% % imshow(I), figure, imshow(J)
% % convert polar coordinates to cartesian coordinates and center
% xx = rho*cos(theta) + Center(1);
% yy = rho*sin(theta) + Center(2);

