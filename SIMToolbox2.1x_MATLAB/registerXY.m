function [imgs_reg, shifts] = registerXY(imgs, upsc,shifts)

if nargin <3
    for ii = 1:size(imgs,3)-1

        im1 = imgs(:,:,ii);
        im2 = imgs(:,:,ii+1);
        [dx, dy] = ccrShiftEstimation(im1,im2,upsc);
        shifts(ii,:) = [dx,dy];
        disp(ii);
    end
end

[M, N]=size(imgs(:,:,1)); 
[xx, yy]=meshgrid(1:N,1:M);

imgs_reg(:,:,1) = imgs(:,:,1);
for ii = 1:size(imgs,3)-1
    imgs_reg(:,:,ii+1) = interp2(xx,yy, double(imgs(:,:,ii+1)), xx-sum(shifts(1:ii,1),1), yy-sum(shifts(1:ii,2),1));
    disp(ii)
end