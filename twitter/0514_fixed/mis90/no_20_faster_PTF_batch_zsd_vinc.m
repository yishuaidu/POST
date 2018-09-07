function[U_final,Var_final,AUC] = no_20_faster_PTF_batch_zsd_vinc(Var_final,U_final,U,Var,all_data,test_ind,tr_ind,R)

% % % environment vars
iter_cnt = 500;
tol = 1e-3;%0.1;

% % % function vars

bat_size = size(tr_ind, 1);
U_updt = U;
Var_updt = Var;
% for i=1:length(U)
%     U{i} = 0*U{i};
%     for j=1:length(Var_updt{i})
%         Var_updt{i}{j} = eye(size(U{i},2));
%     end
% end
len_all_data = size(all_data);

% matrix sorted by each column of origin matrix (only indexs kept)
mat_sorted = cell(1,3);
mat_sorted{1} = sortrows(tr_ind,1);
mat_sorted{2} = sortrows(tr_ind,2);
mat_sorted{3} = sortrows(tr_ind,3);
% pre-compute z values
mat_sorted{1}(:,4) = 2*all_data(sub2ind(len_all_data,mat_sorted{1}(:,1),...
    mat_sorted{1}(:,2),mat_sorted{1}(:,3)))-1;
mat_sorted{2}(:,4) = 2*all_data(sub2ind(len_all_data,mat_sorted{2}(:,1),...
    mat_sorted{2}(:,2),mat_sorted{2}(:,3)))-1;
mat_sorted{3}(:,4) = 2*all_data(sub2ind(len_all_data,mat_sorted{3}(:,1),...
    mat_sorted{3}(:,2),mat_sorted{3}(:,3)))-1;
% interval of unique values in each column of sorted matrixes
uniq = cell(1,3); % 1st col: uniq nbr ; 2nd col: index of fist occurrence
[uniq{1}(:,1),uniq{1}(:,2)] = unique(mat_sorted{1}(:,1));
[uniq{2}(:,1),uniq{2}(:,2)] = unique(mat_sorted{2}(:,2));
[uniq{3}(:,1),uniq{3}(:,2)] = unique(mat_sorted{3}(:,3));
uniq{1}(end+1,:) = [-1,bat_size+1];
uniq{2}(end+1,:) = [-1,bat_size+1];
uniq{3}(end+1,:) = [-1,bat_size+1];

new_norm = Inf;
% % % start iteration
for iter = 1:iter_cnt
    old_Ui = cell(1,3);
    new_Ui = cell(1,3);
    % % % update U_i
    for e_i = 1:3
        uniq_fst_cnt = length(uniq{e_i});
        old_Ui{e_i} = zeros(uniq_fst_cnt-1,R);
        new_Ui{e_i} = zeros(uniq_fst_cnt-1,R);
        ab=setdiff(1:3,e_i);a=ab(1);b=ab(2);
        % % % update all unique e_i
        for uniq_i = 2:uniq_fst_cnt
            % interval of one unique e_i in sorted matrix
            start_pos = uniq{e_i}(uniq_i-1,2);
            end_pos = uniq{e_i}(uniq_i,2);
            
            es = mat_sorted{e_i}(start_pos:end_pos-1,:);
            ea = es(:,a);eb=es(:,b);
            
            Ua = U_updt{a}(ea,:);
            Ub = U_updt{b}(eb,:);
            
            % !!! new way to compute Hadamard_ab
            UaVARa = zeros(R,R,uniq{a}(end-1,1));
            UbVARb = zeros(R,R,uniq{b}(end-1,1));
            for i = 1:uniq{a}(end-1,1)
                UaVARa(:,:,i) = transpose(U_updt{a}(uniq{a}(i,1),:)) * ...
                    U_updt{a}(uniq{a}(i,1),:) + ...
                    Var_updt{a}{i};
            end
            for i = 1:uniq{b}(end-1,1)
                UbVARb(:,:,i) = transpose(U_updt{b}(uniq{b}(i,1),:)) * ...
                    U_updt{b}(uniq{b}(i,1),:) + ...
                    Var_updt{b}{i};
            end
            Hadamard_ab = sum(UaVARa(:,:,ea).*UbVARb(:,:,eb),3);
            % !!! end new way to compute Hadamard_ab
            
            z = es(:,end);
            tmp = Ua.*Ub;
            if iter ~= 1
                m = sum(tmp.*U_updt{e_i}(es(:,e_i),:),2);
                z = m+z.*normpdf(m,0,1)./normcdf(z.*m,0,1);
            end
            UaUb_z = transpose(sum(z.*tmp));
            
            ei = es(1,e_i);
            old_Ui{e_i}(uniq_i-1,:) = U_updt{e_i}(ei,:);
            
            Var_i_ = inv(Var_final{e_i}{ei})+Hadamard_ab;
            U_i = transpose(Var_i_\((Var_final{e_i}{ei})\(transpose(U_final{e_i}(ei,:)))+UaUb_z));
            U_updt{e_i}(ei,:) = U_i;
            new_Ui{e_i}(uniq_i-1,:) = U_i;
            Var_updt{e_i}{ei} = inv(Var_i_);
        end
        % end all unique e_i
    end
    % end all 3 e_is
    % check if batch update converge
    old_norm = new_norm;
    new_norm = norm(old_Ui{1}-new_Ui{1})+norm(old_Ui{2}-new_Ui{2}) ...
        +norm(old_Ui{3}-new_Ui{3});
    norm_diff = abs(old_norm - new_norm);
%     fprintf('diff=%g\n', norm_diff);
    
    if norm_diff < tol
        break;
    end
end

U_final = U_updt;
Var_final = Var_updt;


% predict y using trained model
true_label = all_data(sub2ind(len_all_data,test_ind(:,1),test_ind(:,2), ...
    test_ind(:,3)));
e1=test_ind(:,1);e2=test_ind(:,2);e3=test_ind(:,3);
m = sum(U_final{1}(e1,:).*U_final{2}(e2,:).*U_final{3}(e3,:),2);
% !!! new way to compute sigma_sq
UiVARi=cell(1,3);
for mode = 1:3
    max_ind = max(test_ind(:,mode));
    UiVARi{mode}=zeros(R,R,max_ind);
    for i = 1:max_ind
        UiVARi{mode}(:,:,i) = transpose(U_final{mode}(i,:)) * ...
            U_final{mode}(i,:) + ...
            Var_final{mode}{i};
    end
end
sigma_sq = squeeze(sum(sum(UiVARi{1}(:,:,e1).*UiVARi{2}(:,:,e2).*UiVARi{3}(:,:,e3),2),1));
% !!! end new way to compute sigma_sq
prob = normcdf(m./sqrt(1+sigma_sq),0,1); % prob = normcdf(u/sqrt(1+sigma^2)) here, u := m
[~,~,~,AUC] = perfcurve(true_label,prob,1);

fprintf('our: difference=%f  auc=%f\n', norm_diff, AUC);


