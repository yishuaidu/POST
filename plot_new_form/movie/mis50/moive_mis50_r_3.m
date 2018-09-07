clear all;
close all;
clc;

df = load('r3.mat');
% mast mis90
mast = df.mis50_r3(:,1);
% tncp mis90
tncp = df.mis50_r3(:,2);
% als mis90
als = df.mis50_r3(:,3);
% our-v-3 mis90
our= df.mis50_r3(:,4);

nrank = [1:1:36];

figure (1);
hold on;
box on;
%change color
plot(nrank, mast,  'rs-.','LineWidth',1.3, 'MarkerSize',8);
plot(nrank, tncp, 'g<-.','LineWidth',1.3, 'MarkerSize',8);
plot(nrank, als, 'b>-.','LineWidth',1.3, 'MarkerSize',8);
plot(nrank, our, 'ko-.', 'LineWidth',1.3, 'MarkerSize',8);

 
lgd = legend('MAST','TNCP','CP-ALS','POST');
lgd.FontSize = 18;
ylabel('RA-AUC', 'FontSize',25);
xlabel('Number of slice increments','FontSize',25);
title('MovieLens (50% Missing, R = 3)','FontSize',25)

% set(gca,'XTick',1:7:35, 'FontSize',25);
 set(gca, 'FontSize',25);
%  %set(gca,'YTick',[0.55, 0.65, 0.75, 0.85], 'FontSize',25);
%  set(gca,'FontSize',25);