function [obj,phvec]=  obj_regulaSemiFirst(Wvec,X,R,d,paras)
    [L N] =size(X);
    W = reshape(Wvec,L,d);
    XXT = X*X';
    alpha = paras.alpha;
    gamma = paras.gamma;
    delta = paras.delta;
    [i1 i2 r]= find(R);
    rnum = numel(r);
    X1=X(:,i1);%L*N_R
    X2 = X(:,i2);
    ewx1 = exp(-W'*X1);
    ewx2 = exp(-W'*X2);
    H1 = 2./(1+ewx1)-1;
    H2 = 2./(1+ewx2)-1; %MK*N_R
    DIST = sum((H1-H2).^2,1); %距离的平方
    dist =max(DIST(:)); %距离的最大值
    G=sparse(exp(-(DIST)./dist)); %归一化到0-1之间
    %sqrt_Dist_elem = -disMat(H1',H2',2)./dist;
    %minus_elem = H1-H2;
    %目标函数
    obj = sum(log(1+exp(-r'.*(alpha*G))))-gamma*sum(sum(W'*XXT*W));
    coef = (-r'./(1+exp(r'.*(alpha*G)))).*(G.*(-sqrt(sqrt(DIST))./dist));
    coef_diag = spdiags(coef',0,rnum,rnum);
    ph=zeros(L,d);
%    size(X1),size(coef_diag),size((ewx1./(1+ewx1).^2).*(H1-H2)),
    ph = X1*coef_diag*((2*(ewx1./(1+ewx1).^2).*(H1-H2))');
    ph = ph+X2*coef_diag*(2*(ewx2./(1+ewx2).^2).*(H1-H2))';
    ph = ph-gamma*2*XXT*W;
    phvec = reshape(ph,L*d,1);
end


