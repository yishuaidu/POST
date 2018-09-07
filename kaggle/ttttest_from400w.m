load('model_400w.mat');
test = load ('test10ww.txt');

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


