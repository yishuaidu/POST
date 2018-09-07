function Y = outer_prod_rows(X)
    [m,n] = size(X);
    j=1:n;
    Y = reshape(repmat(X', n, 1) .* X(:,j(ones(n, 1),:)).', [n n m]);
end