clear all;
close all;
clc;

POST = [3500.760812;2074.210862;1829.110899;1672.111854;1722.558701;1854.707476;1594.065093;1487.289654]


nrank = [1:1:8];

figure (1);
hold on;
box on;
% 
plot(nrank, POST, 'ko-.', 'LineWidth',3, 'MarkerSize',8);

legend('POST','CP-WOPT');


ylabel('Seconds', 'FontSize',25);
xlabel('Streaming Batch Size','FontSize',25);
title('Runing time of ACC (R = 3)','FontSize',25)
xticklabels({'1','5','10','50','100','1k','5k','10k'})
 set(gca, 'FontSize',25);

