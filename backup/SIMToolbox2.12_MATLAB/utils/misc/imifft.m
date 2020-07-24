function G = imifft(im)
% This function computes the inverse 2D Fourier transform
G = ifftshift(ifft2(ifftshift(im)));
end



