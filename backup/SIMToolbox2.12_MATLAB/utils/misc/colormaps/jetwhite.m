function map = jetwhite(Colours);
%% Set Colour map through 7 stages from Black through BCGYRM to White
% aim is to improve on hsv, jet and jetviolet - optimized for RGB displays
% As resolution lowers colors tend to step - we want all to step at once.
% But if where we do have excess colours we hit the primaries first.
% At lower size maps it thus emphasizes evenness/discrimination/primaries.
% At higher resolutions it emphasizes hitting clear secondary colours too.
% Because of size adaptiveness the relative locations of colours varies.
% The meaning of life is 42 - jetwhite can't work with less.
% It is optimized for 63 or 64 at which primaries are smooth.
%
% Note that assuring a linear lightness scale tends to produce colours that 
% are muddy or pastel rather than the clear primary and secondary colours 
% jetwhite is designed to punctuate with, e.g. at 64 colours we have 
% 4-10: Blue, 14-20: Teal/Cyan, 24-30: Greens, 34-40: Yellow/Orange, 44-50: Reds, 
% 54-60: Magenta. 1-32 are dark/cool, 33-64 are light/warm colours...
% designed so that symmetric plots are centred on the yellow/green transition:
% useful for experiments involving two-sided effects/expectations/significance.
%
% Usage:
% colormap(squink)
%    sets the same size color map as currently used in your current figure
% colormap(jetwhite(N))
%    sets a color map of N shades with emphatic coverage of primaries
%    for N?100 this will be perceptually smooth
%    for N<100 there will be perceptual steps through some colours
% colormap(jetwhite(N).^K)
%    for K=0.5 there will emphasis on the secondaries
%    for K=0.7 there will be balance between primaries and secondaries
% Example:
%
% load spine;
% figure; colourmap=jetwhite(64);colormap(colourmap);image(X);colorbar
% figure; greyjet=rgb2gray(jetwhite); image(X); colormap(greyjet); colorbar('WestOutside');
%
% colormap(jetwhite(64).^0.5.*gray(64).^0.5)
%     emphasize secondary colours and darken for use on a CYM printer
% jetwhit=jetwhite(300);
% jetpink=jetwhit(25:280,:);
% colormap(jetpink)
%     eliminate black footroom and white headroom (blue to pink subrange)
%
%
% Copyright 2014 David M W Powers - All rights reserved
% Version 1.2

if nargin==0
    Colours=size(colormap,1);
end
Blocks=floor(Colours/7);
Extra=Colours-Blocks*6; % Slow down the last interpolation
Shade=[0,0,0];
I=0;
% -> B: Inc Blue
Block=Blocks-4;
for I=I+1:I+Block
    Shade(3)=Shade(3)+1/(Block+3.01);
    map(I,1:3)=Shade;
end
    Shade(3)=Shade(3)+1/(Block+3.01);
% -> C: Inc Green
Block=Extra+6;
for I=I+1:I+Block
    Shade(2)=Shade(2)+1/(Block+3.01);
    map(I,1:3)=Shade;
end
    Shade(2)=Shade(2)+1/(Block+3.01);
% -> G: Dec Blue
Block=Blocks-5;
for I=I+1:I+Block
    Shade(3)=Shade(3)-1/(Block+4.01);
    map(I,1:3)=Shade;
end
    Shade(3)=Shade(3)-1/(Block+4.01);
% -> Y: Inc Red
Block=Blocks-2;
for I=I+1:I+Block
    Shade(1)=Shade(1)+1/(Block+1.01);
    map(I,1:3)=Shade;
end
    Shade(1)=Shade(1)+1/(Block+1.01);
% -> R: Dec Green
Block=Blocks+4;
for I=I+1:I+Block
    Shade(2)=Shade(2)-1/(Block+4.01);
    map(I,1:3)=Shade;
end
    Shade(2)=Shade(2)-1/(Block+4.01);
% -> M: Inc Blue
Block=Blocks-1;
for I=I+1:I+Block
    Shade(3)=Shade(3)+1/(Block+2.01);
    map(I,1:3)=Shade;
end
% -> W: Inc Green
Block=Blocks+2;
for I=I+1:I+Block % No overlapping end/start so one more
    Shade(2)=Shade(2)+1/(Block+1.01);
    map(I,1:3)=Shade;
end
    map(1,1:3)=[0,0,0]; % clobber bottom entry (footroom)
    map(Colours,1:3)=[1,1,1]; % clobber top entry (headroom)

%     map=satlin(map);