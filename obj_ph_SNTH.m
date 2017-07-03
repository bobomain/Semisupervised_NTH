%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% caculate objective function value and gradient
%计算目标函数值和梯度
% Input:
%   Wvec: vectorized hash projection 哈希映射的向量化表示
%   X: feature matrix 特征矩阵
%   R: relation matrix 关系矩阵
%   M: number of similarity components 相似组件个数
%   K: number of hash bits of each similarity component 相似组件哈希编码长度
%   paras is a struct of parameters, including: 
%       alpha: scale factor of non-transitive similarity, default: 2.0/K
%       delta: translation factor of non-transitive similarity, default: 1.0
%       gamma1: weight of first regularizor
%       gamma2: weight of second regularizor
% Output:
%   obj: objective function value 目标函数值
%   phvec: gradient 梯度
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [obj, phvec] = obj_ph_SNTH(Wvec, X, R, M, K, paras)
    [L N] = size(X);
    W = reshape(Wvec, L, M*K); %改变矩阵形状，L行M*K列
    gamma1 = paras.gamma1;
    gamma2 = paras.gamma2;
    alpha = paras.alpha;
    delta = paras.delta;
    XXT=paras.XXT;
    linear = false;


    [i1 i2 r] = find(R); %R中非零元素的位置，i1是按行索引，i2是按列索引，r是元素组成的向量
    rnum = numel(r); %数组中元素的总数
    X1 = X(:,i1); %矩阵X中i1对应列数
    X2 = X(:,i2); %矩阵X中i2对应列数
    Smask = sparse(reshape(ones(K,1)*(1:M), M*K, 1), (1:M*K), ones(M*K,1), M, M*K);
    if linear
        H1 = W'*X1;
        H2 = W'*X2;
    else
        ewx1 = exp(-W'*X1);
        ewx2 = exp(-W'*X2);
        H1 = 2./(1+ewx1)-1;
        H2 = 2./(1+ewx2)-1;
    end
    %H1.*H2,
    Sc = Smask*(H1.*H2); %Sij
    %Sc,
    Sc_exp = exp(Sc); 
    S = sum(Sc_exp.*Sc, 1)./sum(Sc_exp, 1);
% 目标函数
    obj = sum(log(1+exp(-r'.*(alpha*S-delta))))+gamma1*sum(sum((W'*W-spdiags(sum(W.^2, 1)',0,M*K,M*K)).^2))+gamma2*sum(sum(W'*XXT*W));
	%+gamma2*sum(sum(W.^2));
%求梯度
    ph = zeros(L, M*K);
    %tic;
    for m = 1:M
        mind_ph = ((m-1)*K+1):(m*K);
        coef = (-alpha*r'./(1+exp(r'.*(alpha*S-delta)))).*((Sc_exp(m,:)+(Sc(m,:).*Sc_exp(m,:))-Sc_exp(m,:).*S)./sum(Sc_exp,1));
        if linear
            Xcov = X1*spdiags(coef', 0, rnum, rnum)*X2';
            ph(:, (m-1)*K+(1:K)) = (Xcov+Xcov')*W(:,mind_ph);
        else
            coef_diag = spdiags(coef', 0, rnum, rnum);
            ph(:, (m-1)*K+(1:K)) = full(X1*coef_diag*(2*(ewx1(mind_ph,:)./(1+ewx1(mind_ph,:)).^2).*H2(mind_ph,:))'...
                + X2*coef_diag*(2*(ewx2(mind_ph,:)./(1+ewx2(mind_ph,:)).^2).*H1(mind_ph,:))');
        end
        ww = W'*W(:,mind_ph);
        ww(sub2ind([M*K K], (mind_ph)', (1:K)')) = 0;
        ph(:, (m-1)*K+(1:K)) = ph(:, (m-1)*K+(1:K)) + gamma1*4*W*ww;
        %ph(:, (m-1)*K+(1:K)) = ph(:, (m-1)*K+(1:K)) + gamma2*2*W(:,mind_ph);
        ph(:, (m-1)*K+(1:K)) = ph(:, (m-1)*K+(1:K)) + gamma2*2*XXT*W(:,mind_ph);
    end
    phvec = reshape(ph, L*M*K, 1);
    %tim = toc;
    %fprintf('obj_h.m: tic --toc : use time %15.5f.\n',tim);
end








