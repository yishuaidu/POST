clear all;
close all;

addpath('tensor_toolbox_2.5');
rng('default');



diary b1
%1,5,10,50,100,1K,5K,10K
batch_size = 1;
nvec = [3000,150,30000];
nmod = length(nvec);
post_mean = cell(nmod,1);
post_cov = cell(nmod, 1);
%settings
opt = [];
opt.max_iter = 500;
opt.tol = 1e-3;
%3,5,8
R = 8;
v = 1;


train = load ('./tensor-data-large/acc/ibm-large-tensor.txt');
nruns = 5;
mse_folds = zeros(nruns,1);
for fold=1:nruns
    tic;
    fprintf('run %d, batch size %d , R = %d \n',fold, batch_size,R);
    train = train(randperm(size(train,1)),:);
    for k=1:nmod
        post_mean{k} = rand(nvec(k),R);
        post_cov{k} = reshape(repmat(v*eye(R), [1, nvec(k)]), [R,R,nvec(k)]);
    end
    post = {post_mean, post_cov, [0.001, 0.001]};
    

    for i=1:batch_size:size(train,1)
        if i+batch_size-1<=size(train,1)
            batch_data = train(i:i+batch_size-1, :);
        else
            batch_data = train(i:end,:);
        end
        batch_data(:,1:nmod) = batch_data(:,1:nmod) + 1;
        post = POST_cont(post,batch_data,opt);
        if mod(i-1, 1000*batch_size) == 0
        %if mod(i-1, 1*batch_size) == 0
            fprintf('%d batches processed!\n', i);
        end
    end
    
    test = load ('./tensor-data-large/acc/ibm.mat');
    test = test.data.test;
    avg_err = 0;
    post_mean = post{1};
    post_cov = post{2};
    for i=1:50
        true_val = test{i}.Ymiss;
        test_ind = test{i}.subs;
        n_test = size(test_ind,1);
        mu = ones(n_test,R);
        for k=1:nmod
            mu = mu.*post_mean{k}(test_ind(:,k),:);
        end
        pred = sum(mu,2);
        err = mean((true_val - pred).^2);        
        avg_err = avg_err + err;
    end
    avg_err = avg_err/50;
    fprintf('run %d, mse = %g\n',fold, avg_err);
    mse_folds(fold) = avg_err;
    
    fn_U = strcat('./output/zsd-time-',int2str(fold),'-R-',int2str(R),'-V-',num2str(v),'-U','-batch-',int2str(batch_size),'.mat'); 
    save(fn_U, 'post'); %%%%%%%%
    toc;
   
end
fprintf('5 Runs: average mse = %g, std = %g\n', mean(mse_folds), std(mse_folds)/sqrt(nruns)); 


diary off



