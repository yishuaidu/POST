function [X, errList,U] = NNCP(T, Omega,alpha, tensor_rank, lambda, maxIter, tol,U)
%
% 
% This routine solves the nuclear-norm regularized CP tensor completion problem 
% via Alternation Direction Method of Multipliers (ADMM), which has been  
% presented in our papers:
% 1. Yuanyuan Liu, Fanhua Shang, Hong Cheng, James Cheng, Hanghang Tong: 
% Factor Matrix Trace Norm Minimization for Low-Rank Tensor Completion,
% SDM, pp. 866-874, 2014.
%
% 2. Yuanyuan Liu, Fanhua Shang, L. C. Jiao, James Cheng, Hong Cheng: 
% Trace Norm Regularized CANDECOMP/PARAFAC Decomposition with Missing Data,
% accepted by IEEE Transactions on Cybernetics, 2015.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Our ADMM algorithm for Nuclear Norm regularized CP tensor completion:
% 
%
% min_{X} sum(alpha_n|M(n)|_{*)+ lambda/2*||X-U(1)...U(n)||^2_{F}
% s.t., X_{Omega} = T_{Omega}, M(n) = U(n), n = 1,...,N.
%        
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% created by Fanhua Shang on 7/25/2014, fhshang@cse.cuhk.edu.hk
%
tic;
% Default parameters
if nargin < 7
    tol = 1e-5;  
end

if nargin < 6
    maxIter = 500; 
end

if nargin < 5
    lambda = 1/sqrt(max(size(T))); 
end

if nargin < 4
    tensor_rank = 40;
end

ndims_T = ndims(T);
if nargin < 3
    alpha = ones(ndims_T, 1);
    alpha = alpha / sum(alpha);
end
    

%%% Parameter set
beta = 1e-4;  
rho = 1.05;

X = T;
X(logical(1-Omega)) = mean(T(Omega));
errList = zeros(maxIter, 1);

ndims_T = ndims(T);
normT   = norm(T(:));
T_size  = size(T);
%stop_temp = zeros(ndims_T, 1);
M = [];
size_II = []; 
for i = 1:ndims_T
    if nargin<8
        U{i} = randn(T_size(i),  tensor_rank);
        M{i} = zeros(T_size(i), tensor_rank);
    else
        M{i} = zeros(T_size(i), tensor_rank);
    end
    Y{i} = zeros(T_size(i), tensor_rank);
    size_II = [size_II, tensor_rank];
end
index_temp = ones(1, tensor_rank);
II = tendiag(index_temp, size_II); 
X_pre = X;

%%% Iteration Scheme 

for k = 1: maxIter
    
    % if mod(k, 100) == 0
    %     fprintf('NNCP: iterations = %d   difference=%f\n', k, errList(k-1));
    % end
    beta = beta * rho;
  
    % update M  
    for i = 1:ndims_T
        temp = U{i} - Y{i}/beta;
        [UU, sigma, VV] = svd(temp,'econ'); 
        sigma = diag(sigma);
        svp   = length(find(sigma > alpha(i)/beta)); 
        if svp>=1
            sigma = sigma(1:svp) - (alpha(i)/beta);
        else
            svp   = 1;
            sigma = 0;
        end
        M{i} = UU(:,1:svp)*diag(sigma(1:svp))*VV(:,1:svp)';
    end    

    % update U  
    midT = [];    
    temp = [];
    for i = 1:ndims_T   
        midT = tensor(II);
        for m = 1:ndims_T  %Kronecker product
            if m == i
            continue;
            end
            midT = ttm(midT, U{m}, m);
        end
        unfoldD_temp = tenmat(midT, i);  

        temp_M = M{i} + Y{i}/beta; 
        temp_B = unfoldD_temp.data*unfoldD_temp.data';
        temp_B = lambda*temp_B + beta*eye(tensor_rank,tensor_rank);     
        temp_B = inv(temp_B + 0.00001*eye(size(temp_B)));
        temp_C = tenmat(X, i);
        U{i} = temp_C.data*unfoldD_temp.data';
        U{i} = (lambda*U{i} + beta*temp_M)*temp_B;  
    end;
    clear unfoldD_temp temp_B temp_M temp_C  
  
    % update X  
    midT = [];  
    midT = tensor(II);
    midT = ttm(midT, U, [1:ndims_T]);  
    X = midT.data;
    X(Omega) = T(Omega);
  
    % update Lagrange multiper   
    for i = 1:ndims_T      
        Y{i} = Y{i} + beta*(M{i} - U{i});   
        temp = M{i} - U{i};
        %stop_temp(i) = max(abs(temp(:))); 
    end 
 
    %stopC = max(stop_temp);
    stopC = norm(X_pre(:) - X(:))/norm(T(:)); 
    X_pre = X; 
    errList(k) = stopC;
 
    if stopC < tol
       break;
    end  
    %stop_temp = zeros(ndims_T, 1);
end
time=toc;
fprintf('NNCP: iterations = %d   difference=%f  time=%f\n', k, stopC, time);



