function lambda=estimateNoise(im)

[sy, sx]=size(im);
im=double(im);

% compute sum of absolute values of Laplacian
M=[1 -2 1; -2 4 -2; 1 -2 1];
lambda=sum(sum(abs(conv2(im, M))));

% properly scale sigma
lambda=lambda*sqrt(0.5*pi)./(6*(sx-2)*(sy-2));
end