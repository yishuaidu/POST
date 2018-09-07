clear all;
close all;
clc;

POST = [0.751853;0.751831;0.751832;0.752361;0.753015;0.767269;0.843937;0.87652];
WOPT = [0.744514;0.744514;0.744514;0.744514;0.744514;0.744514;0.744514;0.744514];

nrank = [1:1:8];

figure (1);
hold on;
box on;
% 
plot(nrank, POST, 'ko-.', 'LineWidth',3, 'MarkerSize',8);
plot(nrank, WOPT, 'c+-.','LineWidth',3, 'MarkerSize',8);

legend('POST','CP-WOPT');


ylabel('AVG-AUC', 'FontSize',25);
xlabel('Streaming Batch Size','FontSize',25);
title('AVG-AUC of DBLP (R = 8)','FontSize',25)
xticklabels({'1','5','10','50','100','1000','5k','10k'})
 set(gca, 'FontSize',25);

