clear; close all;
clc;

[num,txt,raw] = xlsread('MapsimResults.xlsx','C36:W39');

x = num(contains(txt,'ImageSize'),:);
dataCPU = num(contains(txt,'MatlabTime'),:);
dataGPU = num(contains(txt,'CudaTime (V3)'),:);

%%

CPUfit = polyfit(x,dataCPU,2);
GPUfit = polyfit(x,dataGPU,2);

x_fine = linspace(x(1),x(end),1000);
dataCPUfit = polyval(CPUfit,x_fine);
dataGPUfit = polyval(GPUfit,x_fine);


figure(4);
plot(x,[dataCPU;dataGPU],'o','MarkerFaceColor','k'); hold on;
set(gca,'ColorOrderIndex',1);
h = plot(x_fine,[dataCPUfit;dataGPUfit],'LineWidth',1); hold off;
axis([100 2000 0 20]);
set(gca,'TickDir','out');
xlabel('Input image size (pixels)'); ylabel('Time (s)');
legend(h,'CPU','GPU','Location','NorthWest');

fig2pdf(gcf,[30,10]);