function m = spectralMask(sx,sy,fc,subbcg)
if nargin < 4
    subbcg = 0;
end
fx = linspace(-1,1,sx);
fy = linspace(-1,1,sy);
[Fx,Fy] = meshgrid(fx,fy);

[THETA,RHO]=cart2pol(Fx,Fy); 

if subbcg ==0 
    m = RHO<fc; 
else
    m = RHO>fc & ...
((abs(THETA) > (10/180)*pi & abs(THETA) <(80/180)*pi) |...
 (abs(THETA) > (100/180)*pi & abs(THETA) <(170/180)*pi));
end
end