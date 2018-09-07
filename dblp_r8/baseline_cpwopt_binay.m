clear all;
close all;
addpath('tensor_toolbox_2.5');
addpath('poblano_toolbox');
diary cpwopt
rng('default');
runs = 5;
total =zeros(runs,1);
for iii = 1:runs
    tic;
    dt = load('./tensor-data-large/dblp/dblp-large-tensor.txt');
    trind = dt(:,1:3)+1;
    trvals = dt(:,4);
    nvec = [10000,200,10000];
    W = sptensor(trind, ones(length(trind),1), nvec);
    dim = 8;
    Y = sptensor(trind, trvals,nvec);
    %P = cp_wopt(Y,W,dim, 'init', 'random','alg', 'lbfgs');
    P = cp_wopt(Y,W,dim, 'init', 'random');
    toc;
    test = load ('./tensor-data-large/dblp/dblp.mat');
    test = test.data.test;
    aucs = zeros(length(test),1);
    for t=1:length(test)
        sub = test{t}.subs;
        ymiss = test{t}.Ymiss;
        %init with randn
        %P = cp_wopt(Y,W,dim);
        %prediction
        nmod = length(nvec);
        pred = ones(length(ymiss),dim);
        for j=1:nmod
            pred = pred .* P.u{j}(sub(:,j),:);
        end
        pred = pred * fliplr(P.lambda')';
        [X_,Y_,T,AUC] = perfcurve(ymiss,pred,1);
        %fprintf('AUC = %g\n',AUC);
        aucs(t) = AUC;
    end
    fprintf('run %d, average auc = %g\n', iii, mean(aucs));
    total(iii) = mean(aucs);
end
fprintf('average %d runs, auc = %g, std = %g \n',runs, mean(total), std(total)/sqrt(runs));
diary off