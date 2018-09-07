test = load ('test.txt');

avg_auc = 0;
post_mean = post_u{1};
post_cov = post_u{2};
for i=1
    true_val = test(:,5);
    test_ind = int64(test(:,1:4));
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