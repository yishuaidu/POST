clear;
clc;

%also report the variances of the probability
addpath('tensor_toolbox_2.5');

rng('default');

diary b1-7w
batch_size = 1;

nvec = [7,4735,8552,8248];
nmod = length(nvec);
%settings
opt = [];
opt.max_iter = 500;
opt.tol = 1e-3;
R = 1;
v = 1;

load('model_400w.mat');
test = load ('test10ww.txt');
avg_auc = 0;
post_mean = post_u{1};
post_cov = post_u{2};

true_val = test(:,5);
test_ind = test(:,1:4)+1;
n_test = size(test_ind, 1);
mu = ones(n_test,R);
S = ones(R,R,n_test);
for k=1:nmod
    mu = mu.*post_mean{k}(test_ind(:,k),:);
    S = S.*(post_cov{k}(:, :, test_ind(:,k)) + outer_prod_rows( post_mean{k}(test_ind(:,k),:) ));
end
m = sum(mu,2);
sq = squeeze(sum(sum(S,2),1));
var_m = sq - m.*m;
prob = normcdf(m./sqrt(1+var_m)); % prob = normcdf(u/sqrt(1+sigma^2)) here, u := m
[~,~,~,auc] = perfcurve(true_val,prob,1);
avg_auc = avg_auc + auc;

%7 x 2854 x 4114 x 6061
%calculates the variance via Gauss-Hermite quadrature
n_q = 9;
[nd,weights] = quadrl(n_q);
%quadrature nodes
x = repmat(m, [1,n_q]) + repmat(sqrt(var_m), [1,n_q])*diag(nd);
%variance & standard deviation for the click prob. 
var_prob = sum(normcdf(x).^2*diag(weights),2) - prob.^2;
std_prob = sqrt(var_prob);

%histogram
% histogram(std_prob);
% title('Histogram of Click Probability STD', 'FontSize', 25);
% xlabel('Posterior Standard Deviation');
% ylabel('Count');
% yticks([1, 10, 100, 1000, 10000]);
% xlim([-0.01, 0.16])
% set(gca,'YScale','log','FontSize',25)

%mean vs. variance
% scatter(prob, std_prob, 'blue');
% xlabel('Posterior Mean','FontSize',25);
% ylabel('Posterior Standard Deviation', 'FontSize',25);
% title('Click Probability', 'FontSize', 25);
% xticks([0, 0.25,  0.5, 0.8, 1])
% set(gca, 'FontSize',25);
% box on;

var_banner = post_cov{1}(:);
var_site = post_cov{2}(:);
var_app = post_cov{3}(:);
var_device = post_cov{4}(:);

%embeddings varaince vs. click probability
var_embeddigns = (var_banner(test_ind(:,1))) + (var_site(test_ind(:,2))) + (var_app(test_ind(:,3))) + (var_device(test_ind(:,4)));
scatter(var_embeddigns/4, prob, 'blue');
xlabel('AVG Embedding Variances','FontSize',25);
ylabel('Click Probability (Mean)', 'FontSize',25);
title('Embedding Variance vs. Click Probability', 'FontSize', 25);
xticks([0, 0.25,  0.5, 0.8, 1])
set(gca, 'FontSize',25);
box on;

n_test = size(test_ind,1);


%variance vs. count
% train = load ('train400ww.txt');
% train(1:end-1) = train(1:end-1)+1;
% %banner
% [count, id] = hist(train(:,1), unique(train(:,1)));
% [~, idx] = sort(id);
% scatter((var_banner), count(idx), 200,rgb('orange'), 'filled');
% title('Embeddings for Banner Pos', 'FontSize', 25);
% ylabel('Number of Observations');
% xlabel('Posterior Variance');
% yticks([1, 100, 1000, 100000, 10000000]);
% set(gca, 'FontSize',25,'YScale', 'log');
% box on;
% fprintf('ok');

% %site
% [count, id] = hist(train(:,2), unique(train(:,2)));
% [~, idx] = sort(id);
% scatter((var_site(1:length(id))), count(idx),[],rgb('orange'));
% title('Embeddings for Site', 'FontSize', 25);
% ylabel('Number of Observations')
% xlabel('Posterior Variance')
% yticks([1, 100, 1000, 100000, 10000000]);
% set(gca, 'FontSize',25,'YScale', 'log');
% box on;


%app
% [count, id] = hist(train(:,3), unique(train(:,3)));
% [~, idx] = sort(id);
% scatter(var_app(1:length(id)), count(idx), [],rgb('orange'));
% title('Embeddings for App', 'FontSize', 25);
% ylabel('Number of Observations')
% xlabel('Posterior Variance')
% yticks([1, 100, 1000, 100000, 10000000]);
% set(gca, 'FontSize',25,'YScale', 'log');
% box on;

%device model
% [count, id] = hist(train(:,4), unique(train(:,4)));
% [~, idx] = sort(id);
% scatter(var_device(1:length(id)), count(idx), [],rgb('orange'));
% title('Embeddings for Device Model', 'FontSize', 25);
% ylabel('Number of Observations')
% xlabel('Posterior Variance')
% yticks([1, 100, 1000, 100000, 10000000]);
% set(gca, 'FontSize',25,'YScale', 'log');
% box on;



