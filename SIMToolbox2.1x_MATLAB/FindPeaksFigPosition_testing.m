
Nimages = 5;

sc = get(0,'screensize');
nRows = ceil(Nimages/3);
nCols = ceil(Nimages/nRows);
sbpSize = round(sc(4)/3);
H = nRows*sbpSize+(nRows+1)*30;
W = nCols*sbpSize+(nCols+1)*10;
figSize = [round((sc(3)-W)/2),sc(4)-H-93,W,H];

figure(43), clf;
set(gcf,'Name','Spot finder preview','Tag','figPreview','NumberTitle','off',...
    'Position',figSize,'Resize','off');

im = imread('cameraman.tif');
siz = size(im);
for m = 1:Nimages
    
    disp([a,b]);
    
    subplot(nRows,nCols,m); title(sprintf('Image (%.2f)',m));    
    set(gca,'Units','Pixels','Position',[...
        a*10+(a-1)*sbpSize,...
        10+(nRows-b)*round(H/nRows),...
        sbpSize,sbpSize]);
    
    %%%
    nam = get(gca,'Title'); nam = nam.String; p = strfind(nam,')');
    cla; imagesc(im);
    axis off;
    daspect([siz(2)/siz(1) 1 1]);
    title([nam(1:p(1)) ' - Fit: °']);
end