function [X, n, Sigma2] = Pro2TraceNorm(Z, tau)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% min: 1/2*||Z-X||^2 + ||X||_tr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [S, V, D, Sigma2] = MySVDtau(Z, tau);
% V = max(diag(V) - tau, 0);
% n = sum(V > 0);
% X = S(:, 1:n) * diag(V(1:n)) * D(:, 1:n)';

%%% new
[m, n] = size(Z);

if 2*m < n
    AAT = Z*Z';
    [S, Sigma2, D] = svd(AAT);
    Sigma2 = diag(Sigma2);
    V = sqrt(Sigma2);
    tol = max(size(Z)) * eps(max(V));
    n = sum(V > max(tol, tau));
    mid = max(V(1:n)-tau, 0) ./ V(1:n) ;
    X = S(:, 1:n) * diag(mid) * S(:, 1:n)' * Z;
    return;
end

if m > 2*n
    [X, n, Sigma2] = Pro2TraceNorm(Z', tau);
    X = X';
    return;
end

[S,sigma,D] = svd(Z);

sigma = diag(sigma);
svp = sum(sigma > tau);
if svp >= 1
    sigma = sigma(1:svp)-tau;
else
    svp = 1;
    sigma = 0;
end
X = S(:, 1:svp) * diag(sigma(1:svp))* D(:, 1:svp)';




