clear all;
close all;
clc;

POST = [2264.355123;871.6209872;707.2474248;532.1146518;509.9926726;448.7822342;454.1807738;795.9008254]
% POST = [774.9687288;392.431983;365.2224628;317.497845;317.593898;270.3342368;278.5195838;406.7729114]


nrank = [1:1:8];

figure (1);
hold on;
box on;
% 
plot(nrank, POST, 'ko-.', 'LineWidth',3, 'MarkerSize',8);

legend('POST');


ylabel('Seconds', 'FontSize',25);
xlabel('Streaming Batch Size','FontSize',25);
title('Running time of DBLP (R = 5)','FontSize',25)
xticklabels({'1','5','10','50','100','1k','5k','10k'})
 set(gca, 'FontSize',25);

