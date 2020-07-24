function checkPhase(angl,phas,pos,ptrn,seq)

imsize = size(seq.IMseq);
% Generate sinusoidal patterns
[xx,yy] = meshgrid(1:imsize(2),1:imsize(1));

% estimate pattern frequency from the peak of the highest harmonics
freq = 2*pi*norm(pos{end});

pattern = zeros(imsize(1),imsize(2),ptrn.num);

for iphase = 1:ptrn.num
    
    k = rotxy(angl)*[freq; 0];
    kx = k(1);
    ky = k(2);
    
    temp = (1-cos(kx*xx+ky*yy+phas(iphase)));
    
    temp = temp./max(temp(:));
    temp(temp<(1-1/ptrn.num))=0;
    temp(temp>0)=1;
    pattern(:,:,iphase) = temp;
    
end

pha = 3;
figure(23)
imshowpair(seq.IMseq(:,:,pha),pattern(:,:,pha));

end

function a = rotxy(angle)
% angle = deg2rad(angle);
a = [cos(angle)  -sin(angle);
    sin(angle)   cos(angle)];
end


