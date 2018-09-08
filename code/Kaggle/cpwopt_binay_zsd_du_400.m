clear all;
close all;
clc ;
addpath('tensor_toolbox_2.5');
addpath('poblano_toolbox');
diary output/cpwopt400222ww
rng('default');
runs = 1;
total =zeros(runs,1);
for iii = 1:runs
    tic;
    dt = load('train400ww.txt');
    trind = dt(:,1:4)+1;
    trvals = dt(:,4);
    nvec = [7,4735,8552,8248];
    W = sptensor(trind, ones(length(trind),1), nvec);
    dim = 4;
    Y = sptensor(trind, trvals,nvec);
    %P = cp_wopt(Y,W,dim, 'init', 'random','alg', 'lbfgs');
    P = cp_wopt(Y,W,dim, 'init', 'random');
    toc;
    test = load ('test10ww.txt');
    test(:,1:4) = test(:,1:4)+1;
    aucs = zeros(1,1);
    for t=1
        sub = test(:,1:4);
        ymiss = test(:,5);
        %init with randn
        %P = cp_wopt(Y,W,dim);
        %prediction
        nmod = length(nvec);
        pred = ones(length(ymiss),nmod);
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