clear;
clc;
addpath('tensor_toolbox_2.5');
addpath('NNCP_code');
rng('default');

diary mis90rank10
for m=1:5

nvec = [400,400,31];
nmod = length(nvec);
post_mean = cell(nmod,1);
post_cov = cell(nmod, 1);
%settings
opt = [];
opt.max_iter = 500;
opt.tol = 1e-3;
%rank [3,5,8,10]
R = 10;
v = 1;
load ('movie_400x400x31.mat');


%% inital 400x400x31
for k=1:nmod
    post_mean{k} = rand(nvec(k),R);
    post_cov{k} = reshape(repmat(v*eye(R), [1, nvec(k)]), [R,R,nvec(k)]);
end

%% warm up with 40x40x31 from TNCP
a=tensor(double(data));
lambda=1;alpha=[1/3,1/3,1/3]/10;
newdims=[40,40,31];


fprintf(' Movielen Rank %d \n',R);
fprintf(' omegaT_90_%d \n',m);
% missing = 0 , not missing =1 
%path missing
mis = strcat('omegaT_90_',int2str(m),'.mat');
load(mis)
c=a.data;c(logical(1-double(OmegaT)))=0;

%set init for 40x40x31
X0=c(1:40,1:40,1:31);
%warm up from TNCP
[TNCP_rX,~,TNCP_P] = NNCP(X0,OmegaT(1:newdims(1),1:newdims(2),1:newdims(3)),alpha,R,lambda,500,1e-5);
U=TNCP_P;


% use value from TNCP 40x40x31,after than from intial 
post_mean{1,1}(1:40,:) = U{1,1};
post_mean{2,1}(1:40,:) = U{1,2};
post_mean{3,1}(1:31,:) = U{1,3};

post_u = {post_mean, post_cov};




load('movie_400x400x31.mat')
% load('../data/data.mat')
a=tensor(a)+1;
a =sptensor(a);

newdims=[40,40,31];

% 90% missing data
load(mis)
OmegaT = OmegaT+1;  %1 is mising, 2 is not mising 
OmegaT = sptensor(OmegaT);
c=a;c(find(OmegaT==1))=-1; % set mising values is -1





%% run 20x50x50
all_data = a(1:newdims(1),1:newdims(2),1:newdims(3)); %% real data
X=c(1:newdims(1),1:newdims(2),1:newdims(3)); % °üº¬missing data -1

cut = X;



cut_test_ind = find(cut==-1);
cut_train_ind = find(cut~=-1);

test_value = all_data(cut_test_ind)-1;
train_value = all_data(cut_train_ind)-1;

%% batch data is not missing data from incremental. 
batch_data = [cut_train_ind, train_value];

post_u = POST(post_u,batch_data,opt);


post_mean = post_u{1};
post_cov = post_u{2};


%%%% start form 40x40x31

save_tmp=[];
ii = 36;
for i=1:ii %1:49
    fprintf('i=%d ',i);
    olddims =newdims;
    newdims(1:2)=olddims(1:2)+10; 
    fprintf(' dims=[%d %d %d] \n',newdims(1),newdims(2),newdims(3));

    %%
    all_data = a(1:newdims(1),1:newdims(2),1:newdims(3)); %% real data
    X=c(1:newdims(1),1:newdims(2),1:newdims(3)); % °üº¬missing data -1

    cut = X;
    cut(1:olddims(1), 1:olddims(2), 1:olddims(3)) = -2;


    cut_test_ind = find(cut==-1);
    cut_train_ind = find(cut>-1);
    
    test_value = all_data(cut_test_ind)-1;
    train_value = all_data(cut_train_ind)-1;
    batch_data = [cut_train_ind, train_value];

    post_u = POST(post_u,batch_data,opt);


    post_mean = post_u{1};
    post_cov = post_u{2};



    true_val = test_value;
    test_ind = cut_test_ind;
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
    save_tmp=[save_tmp,auc]


end

ave_our=[];
for i = 1:length(save_tmp)
    ave_our = [ave_our,sum(save_tmp(1:i))/i];
end
ave_our= ave_our'



end

diary off 