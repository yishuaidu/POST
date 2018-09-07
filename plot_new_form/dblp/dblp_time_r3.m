clear all;
close all;
clc;

POST = [774.9687288;392.431983;365.2224628;317.497845;317.593898;270.3342368;278.5195838;406.7729114]


nrank = [1:1:8];

figure (1);
hold on;
box on;
% 
plot(nrank, POST, 'ko-.', 'LineWidth',3, 'MarkerSize',8);

legend('POST');


ylabel('Seconds', 'FontSize',25);
xlabel('Streaming Batch Size','FontSize',25);
title('Running time of DBLP (R = 3)','FontSize',25)
xticklabels({'1','5','10','50','100','1k','5k','10k'})
 set(gca, 'FontSize',25);

