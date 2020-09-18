function OTF = createOTF(sx,sy,fc)

fx = linspace(-1,1,sx);
fy = linspace(-1,1,sy);
[Fx,Fy] = meshgrid(fx,fy);

[THETA,RHO] = cart2pol(Fx,Fy); 

H = 1/pi*(2*(acos(RHO./fc)) - sin(2*acos(RHO/fc)));

OTF = abs(H);
OTF(RHO > fc) = 0;

end