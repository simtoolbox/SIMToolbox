function [im_out] = applyOTF(im_in, OTF)
% im_in = double(im_in);

IM = fftshift(fft2(im_in));
im_out = abs(ifft2(ifftshift(IM.*OTF)));
end