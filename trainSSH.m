function param = trainSSH(data, param)
% Input
%   X = features matrix [Nsamples, Nfeatures]
%   SHparam.nbits = number of bits (nbits do not need to be a multiple of 8)
% Shared Subspace Hashing
X = data.train_data;
[dim nsample] = size(X);
nbits = param.nbits;
alpha = param.alpha;
beta = param.beta;
gamma = param.gamma;
% param.rdim = param.nbits;
rdim = param.rdim;

max_iter = param.max_iter;
tol = param.tol;

% L = diag(sum(data.S)) - data.S;
L = eye(nsample)-diag(sum(data.S).^(-0.5))*data.S*diag(sum(data.S).^(-0.5)); %构造拉普拉斯矩阵
% L = -data.S;
%%initialize
% Theta = eye(dim);
% Theta = Theta(1:rdim, :);
C = cov(double(X'));%X‘为4*3的矩阵，cov为3*3的矩阵，每（i,j）表示第i列向量与第j列向量的方差
[Theta l] = eigs(C, rdim); %C的前rdim个特征值,Theta 为对应的特征向量，I为特征值组成的对角阵
Theta = Theta'; %Theta是2*3的

% THETA = rand(dim);
% THETA = THETA + THETA';
% [E D] = eigs(double(THETA), rdim);
% Theta = E';
P = eye(nsample)-(1/nsample)*ones(nsample,1)*ones(1, nsample); %4*4

iter = 0;
pre_obj = Inf;

while(iter < max_iter)
    %% compute Y, W, V
    Theta_sym = Theta'*Theta; %3*3
    M = alpha*(alpha*(X*P*X')+(beta+gamma)*eye(dim)-beta*Theta_sym)\(X*P); %Q为3*4 
    M_hat = (eye(nsample)-M'*X); %1-Theta’X
    C = full(L) +alpha*(M_hat*P*M_hat')-beta*(M'*Theta_sym*M)+(beta+gamma)*(M'*M);%L`
    [E D] = eigs(double(C), nbits+1, 'sm'); %C的前nbits+1位对应的特征向量为E，特征值对角阵为D
    [~,idx] = sort(diag(abs(D))); %特征值升序排序，idx为顺序索引
    E = E(:,idx(2:end)); %最小特征值对应的特征向量
    Y = E';    %Y的最优值，对应于C的最小特征值对应的特征向量
    Y = ones(size(E'))*(-1);
    Y (E' >= 0) = 1; %二值化为 -1和1
    obj = trace(Y*C*Y'); %1求二维方阵的迹
    if (pre_obj-obj<max(obj*tol,tol)) %收敛条件为迭代次数or目标函数改变
        break;
    else        
        pre_obj = obj;
    end
    iter = iter + 1;
    
    W = M*Y'; %最优W
    b = (Y-W'*X)*ones(nsample,1)*(1/nsample); %最优b
    V = Theta*W;     %最优V
    
   %% compute Theta，在最优W、b、V、Y的取值情况下，进行共享结构的优化，求Theta的最优值
    C = W*W'; 
    [E D] = eigs(double(C),rdim); %C的最小rdim个特征值对应的特征向量为E
    Theta = E';    
end

param.w = W;
param.b = b;
param.theta = Theta;
param.v = V;
