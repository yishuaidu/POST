%%% Demo for Color image


clc;
clear;
close all;
addpath('tensor_toolbox_2.5/');
addpath('mylib/');

% Problem setting
data  = double(imread('org.png'));
Tsize = size(data);
Omega = (rand(Tsize) > 0.9);
T     = data;
T(logical(1-double(Omega))) = 0;


alpha     = [1, 1, 1e-3];
alpha     = alpha/sum(alpha);
maxIter   = 500;
epsilon   = 1e-4;
inDims    = 40;
lambda    = 1e-4;

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
relErr = norm(X_O(:) - data(:), 'fro')/ norm(data(:), 'fro')


figure (1)
subplot(1,3,1); imshow(uint8(data), []);
subplot(1,3,2); imshow(uint8(T), []);
subplot(1,3,3); imshow(uint8(X_O), []);

