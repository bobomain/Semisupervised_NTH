t1=clock;
addpath(genpath(('./')));
feature_data=load('nus_wide/nuswide_train_features.txt'); 5000*1134
train_num=5000;
%%pre-proceding
nneighbors=30;
train_data = feature_data'; 1134*5000
DIST = distMat(train_data', train_data', 0) ; %欧氏距离
DIST = DIST + max(DIST(:))*eye(train_num); %矩阵DIST先组成一列元素，这一列元素的最大值、eye(A) A*A的单位阵;DIST的对角元素修改为矩阵的最大元素
[~, IDX] = sort(DIST, 2); %沿着行方向，升序排列DIST中的行元素，每行元素置换前的所在位置存储在IDX的每行对应位置中 IDX是与DIST等大的位置索引矩阵
%将DIST距离矩阵中的距离，由小到大排序
S = zeros(train_num);
for i = 1:train_num
    S(i, IDX(i,1:nneighbors)) = DIST(i, IDX(i,1:nneighbors)); %厉害了，使用位置索引把与最相近的5个相邻元素的距离找到
end
S = (S+S')/2;%相似性调整
dist =max(S(:)); %距离的最大值
S = full(S>0).*sparse(exp(-(S)./dist)); %用稀疏矩阵S记录相似度值，归一化到0-1之间
L = eye(train_num)-diag(sum(S).^(-0.5))*S*diag(sum(S).^(-0.5)); %归一化L，L=I-D^(-0.5).*W.*D^(-0.5) S即W，D为S列或行的元素和


%训练数据归一化，每列除以该列的模
%X = normc(train_data)
for i=1:train_num
tem_train(:,i) = train_data(:,i)/norm(train_data(:,i));
end
data.train_data = tem_train;

%Shared subspace hyperplane
SSHparam.nbits = 500;
SSHparam.alpha = 1;
SSHparam.beta = 1;
SSHparam.gamma = 1e-1;
SSHparam.rdim = 500;% 

SSHparam.max_iter = 30;
SSHparam.tol = 1e-18;
SSHparam.useanchor = 0;
SSHparam.nn = 5;
data.S = S;

SSHparam = trainSSH(data, SSHparam);
reduction_data = SSHparam.w'*train_data+SSHparam.b*ones(1,train_num) %d*N
R=load('nus_wide/collection_matrix.txt')
M=4;
K=24;
paras.alpha = 2/24;
paras.delta = 1;
paras.gamma1=0.5;
paras.gamma2=0.5;
res = much(reduction_data,R,M,K,paras)
dlmwrite('nus_wide/red_hash_code_500.txt',res.Hc);
dlmwrite('nus_wide/red_hash_binary_500.txt',res.H);
dlmwrite('nus_wide/red_W_matrix_500.txt',res.W);
dlmwrite('nus_wide/red_origH_500.txt',res.origH);
dlmwrite('nus_wide/red_origW_500.txt',res.origW);
dlmwrite('nus_wide/red_WRW_matrix_500.txt',SSHparam.w*res.W);
t2=clock;
etime(t2,t1)
