function G = imfft(im)
% This function computes the 2D Fourier transform
G = fftshift(fft2(ifftshift(im)));
end

