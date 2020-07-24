% Preprocess SIM data acquired by 8 plane prism
clear all; close all;
addpath('C:\Users\Lukestom\gitcodes\myutils');

ph = 'C:\Users\Lukestom\Downloads\MFSim';

fn_cam0 = 'cellMito04a_vid_timeLapse1000ms_cam0';
fn_cam1 = 'cellMito04a_vid_timeLapse1000ms_cam1';

% loadstack
cam0.rawdata = load_tifFile([ph,filesep,fn_cam0,'.tif'],[],[]);
cam1.rawdata = load_tifFile([ph,filesep,fn_cam1,'.tif'],[],[]);
cam1.rawdata = flip(cam1.rawdata,2);
% Normalize mean for illumination pattern images, discard empty frames
% Reshape and reorder illumination pattern images in different z planes

cam0 = reshapePrismData(cam0);
cam1 = reshapePrismData(cam1);

[sy, sx, szt] = size(cam0.im);

figure,
subplot(211);imshow(mean(cam0.rawdata,3),[]);
subplot(212);imshow(mean(cam1.rawdata,3),[]);
%% reorder stack (y, x, phase, angle, z, time)
imgs = cat(3,cam0.im,cam1.im);
imgs_av = cat(3,cam0.imav,cam1.imav);
imgs = imgs(:,:,[5,1,6,2,7,3,8,4],:);
imgs_av = imgs_av(:,:,[5,1,6,2,7,3,8,4]);

% z plane order 7,3,2,6, 8, 4, 5, 1

imgs = reshape(imgs,sy,sy,8,9,[]); % distinquish phases and time points (if more SIM images in the sequence)
imgs = permute(imgs, [1 2 4 3 5]);
imgs2 = reshape(imgs, sy, sy,[]);

imgs_mean = squeeze(mean(mean(mean(imgs,1),2),3));
imgs_mean = mean(imgs_mean,2); % mean over time points
imgs_weights = max(imgs_mean)./imgs_mean

%%
% z planes cam0: 2,1,3,4 

% figure,
% for ii = 1:8
%     imshow(imgs_av(:,:,ii),[]);
% %     imshow(imgs_bw(:,:,ii));
%     pause;
% end

% imshow(cam0.im(:,:,9),[]);

%% Register images and align the 3D stack
% imgs_bw = imgs_av>200;
% 
% 
% for ii = 1:size(imgs_bw,3)
%     stats{ii} = regionprops(imgs_bw(:,:,ii));
%     [~,maxAreaInd] = max([stats{ii}.Area]);
%     imCentroid(ii,:) = stats{ii}(maxAreaInd,:).Centroid; 
% end
% 
% %%
% imCenter = [sy/2, sy/2];
% imShifts = repmat(imCenter,8,1) - imCentroid; % shifts between centroids and the FOV center
% imDists = sqrt(sum((imShifts).^2,2)); %distances of the image centroid from the FOV center
% [~,minDistIdx] = min(imDists);
% 
% clear imgs_reg;
% d = 100;
% imCentroid = round(imCentroid);
% 
% imRef = imgs_av(-d+imCentroid(minDistIdx,1):+d+imCentroid(minDistIdx,1),...
%                 -d+imCentroid(minDistIdx,2):+d+imCentroid(minDistIdx,2),...
%                 minDistIdx);
% % imRef = imgs_av(:,:,minDistIdx);
% 
% [M, N]=size(imgs_av(:,:,1)); 
% [xx, yy]=meshgrid(1:N,1:M);
%  
% for ii = 1:size(imgs_av,3)
%     disp(ii)
%     if ii == minDistIdx
%         dx = 0;
%         dy = 0;
%     else
%         im = imgs_av(-d+imCentroid(minDistIdx,1):+d+imCentroid(minDistIdx,1),...
%                 -d+imCentroid(minDistIdx,2):+d+imCentroid(minDistIdx,2),...
%                 ii);
% %         im = imgs_av(:,:,ii);
%         [dx, dy] = ccrShiftEstimation(imRef,im,10);
%         
%     end
%     shifts(ii,:) = [imShifts(ii,2),imShifts(ii,1)];
%     imgs_reg(:,:,ii) = interp2(xx,yy, imgs_av(:,:,ii), xx-shifts(ii,2), yy-shifts(ii,1));
%     
% end
% 
% %%
% % figure,
% for ii = 1:8
%     figure,
%     imshow(imgs_reg(:,:,ii),[]);
% %     imshow(imgs_bw(:,:,ii));
%     pause;
% end
%%
outputPath = [ph];
fileName = [fn_cam0(1:end-4),'_reshaped'];
saveImageStack(imgs2,outputPath,fileName,[])
