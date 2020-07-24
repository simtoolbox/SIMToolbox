clear; close all;
clc;

% datafol = 'h:\SIMToolbox\Data\Actin (green LED) LCOS\output\';
datafol = 'h:\SIMToolbox\Data\Mito_Zeiss\output\';

txtfiles = dir([datafol '*.txt']);

delimiter = '\t';
startRow = 2;
formatSpec = '%f%f%[^\n\r]';

ya = [];
yb = [];
for m = 1:length(txtfiles)
    filename = [txtfiles(m).folder filesep txtfiles(m).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    tmp = [dataArray{1:end-1}];
    
    x = tmp(:,1);
    if ~mod(m,2)
        ya = [ya,tmp(:,2)./max(tmp(:,2))];
    else
        yb = [yb,tmp(:,2)./max(tmp(:,2))];
    end
    
    
end

%%
figure(3)
subplot(211); plot(x,ya,'Linewidth',1);
axis([x(1) x(end) 0 1]); set(gca,'TickDir','out','XTick',0:0.5:6,'FontSize',12);
xlabel('Length (µm)'); ylabel('Norm. profile (-)');
legend('Widefield','SR-SIM');

subplot(212); plot(x,yb,'Linewidth',1);
axis([x(1) x(end) 0 1]); set(gca,'TickDir','out','XTick',0:0.5:6,'FontSize',12);
xlabel('Length (µm)'); ylabel('Norm. profile (-)');
legend('OS-SIM','MAP-SIM');

fig2pdf(gcf,[14,12]);


