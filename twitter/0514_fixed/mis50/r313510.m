clear;
clc;
addpath('../tensor_toolbox_2.6');
addpath('../NNCP_code');

rng('default');
for R =[3]
    for V=[ 3,5, 10]%1,3,5,10
        fprintf('init-tncp , R=%d , V=%f ,',R,V);  

        for m =1:5
            load('../data.mat')
            %load('../data/data.mat')
            a=tensor(double(a));
            lambda=1;alpha=[1/3,1/3,1/3]/10;
            newdims=[20,50,50];

            fprintf(' omegaT_50_%d \n',m);
            % missing = 0 , not missing =1 
            %path missing
            % mis = strcat('../data/omegaT_80_',int2str(1),'.mat');
            mis = strcat('omegaT_50_',int2str(m),'.mat');
            fprintf(' omegaT_50_%d \n',m);
            load(mis)
            c=a.data;c(logical(1-double(OmegaT)))=0;

            %set init for 20x50x50

            X0=c(1:20,1:50,1:50);
            [TNCP_rX,~,TNCP_P] = NNCP(X0,OmegaT(1:newdims(1),1:newdims(2),1:newdims(3)),alpha,R,lambda,500,1e-5);
            U=TNCP_P;
            %for i=1:length(U)
            %    U{i} = rand(size(U{i}));
            %end
            
            
            

            
            
            
            
            
            
            
            load('../data.mat')
            % load('../data/data.mat')
            a=tensor(a)+1;
            a =sptensor(a);



            newdims=[20,50,50];

            % 80% missing data
            load(mis)
            OmegaT = OmegaT+1;  %1 is mising, 2 is not mising 
            OmegaT = sptensor(OmegaT);
            c=a;c(find(OmegaT==1))=-1; % set mising values is -1


            %init 

            R=R;

            Varr={};
            A= {};
            B={};
            for i = 1:20
                A{end+1} = eye(R)*V;
                B{end+1} = eye(R);
            end 
            Varr{1} = A;
            Var{1}=B;
            A= {};
            for i = 1:50
                A{end+1} = eye(R)*V;
                B{end+1} = eye(R);
            end 
            Varr{2} = A;
            Var{2}=B;
            A= {};
            for i = 1:50
                A{end+1} = eye(R)*V;
                B{end+1} = eye(R);
            end 
            Varr{3} = A;
            Var{3}=B;

            % U{2}=[U{2};randn(450,R)];
            % U{3}=[U{3};randn(450,R)];


            Var_final = Varr;
            U_final{1} = ones(20,R)-1;
            U_final{2} = ones(50,R)-1;
            U_final{3} = ones(50,R)-1;


            %% run 20x50x50
            all_data = a(1:newdims(1),1:newdims(2),1:newdims(3)); %% real data
            X=c(1:newdims(1),1:newdims(2),1:newdims(3)); % °üº¬missing data -1

            cut = X;



            cut_test_ind = find(cut==-1);
            cut_train_ind = find(cut~=-1);

            [U_final,Var_final,AUC] = no_20_faster_PTF_batch_zsd_vinc(Var_final,U_final,U,Var,all_data-1,cut_test_ind,cut_train_ind,R);

% 
            save_tmp=[];
            ii = 45;
            for i=1:ii %1:49
            fprintf('i=%d ',i);
            olddims =newdims;
            newdims(2:3)=olddims(2:3)+10; 
            fprintf(' dims=[%d %d %d] \n',newdims(1),newdims(2),newdims(3));

            %%
            all_data = a(1:newdims(1),1:newdims(2),1:newdims(3)); %% real data
            X=c(1:newdims(1),1:newdims(2),1:newdims(3)); % °üº¬missing data -1

            cut = X;
            cut(1:olddims(1), 1:olddims(2), 1:olddims(3)) = -2;


            cut_test_ind = find(cut==-1);
            cut_train_ind = find(cut>-1);



            for j=2:3

                U{j}=[U{j};randn(10,R)];
                U_final{j}=[U_final{j};ones(10,R)-1];
                for lll = 1:10
                    Var{j}{end+1}=eye(R);
                    Var_final{j}{end+1}=eye(R)*V;
                end
            end  


            [U_final,Var_final,AUC] = no_20_faster_PTF_batch_zsd_vinc(Var_final,U_final,U,Var,all_data-1,cut_test_ind,cut_train_ind,R);
            U = U_final;
            Var = Var_final;
            save_tmp=[save_tmp,AUC];

            end




            ave_our=[];
            for i = 1:length(save_tmp)
                ave_our = [ave_our,sum(save_tmp(1:i))/i];

            end
            ave_our= ave_our'


            fn_U = strcat('./tmp_U_Var_output/R-',int2str(R),'-V-',int2str(V),'-OmegaT-',int2str(m),'-U.mat'); %%%%
            fn_Var = strcat('./tmp_U_Var_output/R-',int2str(R),'-V-',int2str(V),'-OmegaT-',int2str(m),'-Var.mat'); %%%%
            save(fn_U, 'U'); %%%%
            save(fn_Var, 'Var'); %%%%

            end

    end

end

