%%% Demo for Synthetic Data


clc;
clear;
close all;
addpath('tensor_toolbox_2.5/');
addpath('mylib/');

% Problem setting
dims = 50
rank = 10;

tensor_order = 3;
factor_dims  = dims * ones(1, tensor_order);
core_dims    = rank * ones(1, tensor_order); 

U = cell(1, tensor_order);
for i = 1: tensor_order
    U{i} = rand(factor_dims(i), core_dims(i)) - 0.5;   
    [U{i}, aa1] = qr(U{i}, 0);
end
C = rand(core_dims);

% Generate low-rank tensor
X = ttensor(tensor(C), U);
X = double(X);
Omega     = rand(size(X)) > 0.80; 
T         = zeros(size(X));
T(Omega)  = X(Omega);


alpha     = [1, 1, 1];
alpha     = alpha/sum(alpha);
maxIter   = 500;
epsilon   = 1e-5;
inDims    = 60;
lambda    = 1e3;

tic
[X_O, errList] = NNCP(...
     T,...                    % a tensor whose elements in Omega are used for estimating missing value
     Omega,...                % the index set indicating the obeserved elements
     alpha,...                % the coefficient of the objective function,  i.e., \alpha_i*\|U_{i}\|_{*}
     inDims,...               % the given rank of the tensor
     lambda,...               % the regularization parameter 
     maxIter,...              % the maximum iterations
     epsilon...               % the tolerance of the relative difference of outputs of two neighbor iterations 
     ); 
time = toc

 
X_O    = double(X_O);
relErr = norm(X_O(:) - X(:), 'fro')/ norm(X(:), 'fro')



