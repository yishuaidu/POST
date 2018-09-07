clear;
clc;

addpath('tensor_toolbox_2.5');

rng('default');

diary b10
batch_size = 1;

nvec = [10000,200,10000];
nmod = length(nvec);
post_mean = cell(nmod,1);
post_cov = cell(nmod, 1);
%settings
opt = [];
opt.max_iter = 500;
opt.tol = 1e-3;
R = 8;
v = 1;


train = load ('./tensor-data-large/dblp/dblp-large-tensor.txt');
nruns = 5;
auc_folds = zeros(nruns,1);
for fold=1:nruns
    tic;
     fprintf('run %d, batch size %d ,R = \n',fold, batch_size,R);
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
        if mod(i-1, 1000*batch_size) == 0
            fprintf('%d batches processed!\n', i);
        end
    end
        
    
    
    test = load ('./tensor-data-large/dblp/dblp.mat');
    test = test.data.test;

    avg_auc = 0;
    post_mean = post_u{1};
    post_cov = post_u{2};
    for i=1:50
        true_val = test{i}.Ymiss;
        test_ind = test{i}.subs;
        n_test = size(test_ind,1);
        mu = ones(n_test,R);
        S = ones(R,R,n_test);
        for k=1:nmod
            mu = mu.*post_mean{k}(test_ind(:,k),:);
            S = S.*post_cov{k}(:, :, test_ind(:,k));
        end
        m = sum(mu,2);
        sq = squeeze(sum(sum(S,2),1));
        prob = normcdf(m./sqrt(1+sq)); % prob = normcdf(u/sqrt(1+sigma^2)) here, u := m
        [~,~,~,auc] = perfcurve(true_val,prob,1);
        avg_auc = avg_auc + auc;
    end
    avg_auc = avg_auc/50;
    fprintf('run %d, auc = %g\n',fold, avg_auc);
    auc_folds(fold) = avg_auc;
    
    
    fn_U = strcat('./output/time-',int2str(fold),'-R-',int2str(R),'-V-',num2str(v),'-U','-batch-',int2str(batch_size),'.mat'); 
    save(fn_U, 'post_u'); %%%%%%%%
    toc;
    
    
    
end
fprintf('5 Runs: average auc = %g, std = %g\n', mean(auc_folds), std(auc_folds)/sqrt(nruns)); 


diary off



clear;
clc;

addpath('tensor_toolbox_2.5');

rng('default');

diary b5
batch_size = 5;

nvec = [10000,200,10000];
nmod = length(nvec);
post_mean = cell(nmod,1);
post_cov = cell(nmod, 1);
%settings
opt = [];
opt.max_iter = 500;
opt.tol = 1e-3;
R = 8;
v = 1;


train = load ('./tensor-data-large/dblp/dblp-large-tensor.txt');
nruns = 5;
auc_folds = zeros(nruns,1);
for fold=1:nruns
    tic;
     fprintf('run %d, batch size %d ,R = \n',fold, batch_size,R);
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
        if mod(i-1, 1000*batch_size) == 0
            fprintf('%d batches processed!\n', i);
        end
    end
        
    
    
    test = load ('./tensor-data-large/dblp/dblp.mat');
    test = test.data.test;

    avg_auc = 0;
    post_mean = post_u{1};
    post_cov = post_u{2};
    for i=1:50
        true_val = test{i}.Ymiss;
        test_ind = test{i}.subs;
        n_test = size(test_ind,1);
        mu = ones(n_test,R);
        S = ones(R,R,n_test);
        for k=1:nmod
            mu = mu.*post_mean{k}(test_ind(:,k),:);
            S = S.*post_cov{k}(:, :, test_ind(:,k));
        end
        m = sum(mu,2);
        sq = squeeze(sum(sum(S,2),1));
        prob = normcdf(m./sqrt(1+sq)); % prob = normcdf(u/sqrt(1+sigma^2)) here, u := m
        [~,~,~,auc] = perfcurve(true_val,prob,1);
        avg_auc = avg_auc + auc;
    end
    avg_auc = avg_auc/50;
    fprintf('run %d, auc = %g\n',fold, avg_auc);
    auc_folds(fold) = avg_auc;
    
    
    fn_U = strcat('./output/time-',int2str(fold),'-R-',int2str(R),'-V-',num2str(v),'-U','-batch-',int2str(batch_size),'.mat'); 
    save(fn_U, 'post_u'); %%%%%%%%
    toc;
    
    
    
end
fprintf('5 Runs: average auc = %g, std = %g\n', mean(auc_folds), std(auc_folds)/sqrt(nruns)); 


diary off