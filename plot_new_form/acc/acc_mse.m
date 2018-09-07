clear all;
close all;
clc;

POST = [0.190267;0.189152;0.189452;0.185162;0.183659;0.177457;0.200638;0.355625];
WOPT = [0.272984;0.272984;0.272984;0.272984;0.272984;0.272984;0.272984;0.272984];

nrank = [1:1:8];

figure (1);
hold on;
box on;
% xin hao cyan
plot(nrank, POST, 'ko-.', 'LineWidth',3, 'MarkerSize',8);

plot(nrank, WOPT, 'c+-.','LineWidth',3, 'MarkerSize',8);

legend('POST','CP-WOPT');


ylabel('AVG-MSE', 'FontSize',25);
xlabel('Streaming Batch Size','FontSize',25);
title('MSE of ACC (R = 3)','FontSize',25)
xticklabels({'1','5','10','50','100','1k','5k','10k'})
 set(gca, 'FontSize',25);
