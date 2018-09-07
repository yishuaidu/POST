clear all;
close all;

df = load('r8.mat');
% mast mis80
mast = df.mis80_r8(:,1);
% tncp mis80
tncp = df.mis80_r8(:,2);
% als mis80
als = df.mis80_r8(:,3);
% our mis80
our= df.mis80_r8(:,4);

nrank = [1:1:45];

figure (1);
hold on;
box on;
%change color
plot(nrank, mast,  'rs-.','LineWidth',1.3, 'MarkerSize',8);
plot(nrank, tncp, 'g<-.','LineWidth',1.3, 'MarkerSize',8);
plot(nrank, als, 'b>-.','LineWidth',1.3, 'MarkerSize',8);
plot(nrank, our, 'ko-.', 'LineWidth',1.3, 'MarkerSize',8);

% legend('MAST','TNCP','CP-ALS','POST');
%lgd = legend('Ours-Win-1','Ours-Win-2','Ours-Win-3', 'GP-PTF');
%lgd.FontSize = 25;
ylabel('RA-AUC', 'FontSize',25);
xlabel('Number of slice increments','FontSize',25);

title('Twitter Topic (80% Missing, R = 8)','FontSize',25)

% xlim([0.9,101]);
 %ylim([0,1]);
% set(gca,'XTick',10:10:100, 'FontSize',25);
set(gca, 'FontSize',25);
 %set(gca,'YTick',[0.55, 0.65, 0.75, 0.85], 'FontSize',25);
 set(gca,'FontSize',25);

