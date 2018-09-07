clear;
clc;

%also report the variances of the probability
addpath('tensor_toolbox_2.5');

rng('default');

diary b1-7w
batch_size = 1;

nvec = [7,4735,8552,8248];
nmod = length(nvec);
post_mean = cell(nmod,1);
post_cov = cell(nmod, 1);
%settings
opt = [];
opt.max_iter = 500;
opt.tol = 1e-3;
R = 1;
v = 1;


train = load ('train10.txt');
nruns = 5;
auc_folds = zeros(nruns,1);
for fold=1:nruns
    tic;
    fprintf('run %d, batch size %d \n',fold, batch_size);
    train = train(randperm(size(train,1)),:);
    for k=1:nmod
        post_mean{k} = rand(nvec(k),R);
        post_cov{k} = reshape(repmat(v*eye(R), [1, nvec(k)]), [R,R,nvec(k)]);
    end
    post_u = {post_mean, post_cov};

    for i=1:batch_size:size(train,1)
        if i+batch_size-1<=size(train,1)
            batch_data = train(i:i+batch_size-1, :);
        else
            batch_data = train(i:end,:);
        end
        batch_data(:,1:nmod) = batch_data(:,1:nmod) + 1;
        post_u = POST(post_u,batch_data,opt);
        if mod(i-1, 10000*batch_size) == 0
            fprintf('%d batches processed!\n', i);
        end
    end
        
    
    %save('model.mat', 'post_u');
    %load('model.mat');
    test = load ('test10.txt');

    avg_auc = 0;
    post_mean = post_u{1};
    post_cov = post_u{2};
    for i=1
        true_val = test(:,5);
        test_ind = test(:,1:4)+1;
        n_test = size(test_ind,1);
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
        %calculates the variance via Gauss-Hermite quadrature
        
        n_q = 9;
        [nd,weights] = quadrl(n_q);
        %quadrature nodes
        x = repmat(m, [1,n_q]) + repmat(sqrt(var_m), [1,n_q])*diag(nd);
        %variance & standard deviation for the click prob. 
        var_prob = sum(normcdf(x).^2*diag(weights),2) - prob.^2;
        std_prob = sqrt(var_prob);
        scatter(std_prob, prob);
        hold on;
        scatter(sqrt(prob.*(1-prob)), prob);
        
    end
    avg_auc = avg_auc;
    fprintf('run %d, auc = %g\n',fold, avg_auc);
    auc_folds(fold) = avg_auc;
    
    
    fn_U = strcat('./output/size-7w-time-',int2str(fold),'-R-',int2str(R),'-V-',num2str(v),'-U','-batch-',int2str(batch_size),'.mat'); 
    save(fn_U, 'post_u'); %%%%%%%%
    toc;
    
    
    
end
fprintf('5 Runs: average auc = %g, std = %g\n', mean(auc_folds), std(auc_folds)/sqrt(nruns)); 


diary off