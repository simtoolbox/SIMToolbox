function IM = apodize(IM,sx,sy,fc,subbcg)
omega = 2*fc;

[k_x,k_y] = meshgrid(-sx/2+1:sx/2,-sy/2+1:sy/2);
% s = min(size(IM));
% [k_x,k_y] = meshgrid(linspace(-s/2+1,s/2,sx),linspace(-s/2+1,s/2,sy));
k_r = sqrt(k_x.^2+k_y.^2);
k_max = omega*max(k_r(:));
apdf = cos(pi*k_r/(2*k_max));
indi =  k_r > k_max ;
% apdf(indi) = realmin;
apdf(indi) = 0;

IMf = fftshift(fft2(IM));

if subbcg
    IMnoise = abs(IMf.*imcomplement(spectralMask(sx,sy,omega,1)));
    IMnoise = mean(IMnoise(:));
    IMfa = abs(IMf) - IMnoise; % subtract noise background
%     IMfa(IMfa<0) = realmin;
    IMfa(IMfa<0) = 0;
    IMf = IMfa.*exp(1i*angle(IMf)); 
end
IMf = IMf.*apdf; % apodization

IM = real(ifft2(ifftshift(IMf)));
IM(IM<0) = 0;

end