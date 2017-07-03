function [test_B,train_B]=SemiStage_Pcatest(M,K,dirname_write,R,data,paras)

X=data.train_data';
npca = 2*M*K;
[pc, ~] = eigs(cov(X), npca);
train_data = pc'*data.train_data; %L*N
test_data = pc'*data.test_data;

res_Reduc = Reduc_Stage(train_data,R,M*K,paras);
feature_train = res_Reduc.Hc'; %N*d
W_Reduc = res_Reduc.W;
nneighbors=paras.nneighbors;
train_num=size(feature_train,1);
DIST = distMat(feature_train, feature_train, 0);
DIST = DIST + max(DIST(:))*eye(train_num);
[~, IDX] = sort(DIST, 2);

G = zeros(train_num);
for i = 1:train_num
    G(i, IDX(i,1:nneighbors)) = DIST(i, IDX(i,1:nneighbors)); %厉害了，使用位置索引把与最相近的5个相邻元素的距离找到
end
G = (G+G')/2;%相似性调整
dist =max(G(:)); %距离的最大值
G = full(G>0).*sparse(exp(-(G)./dist)); %用稀疏矩阵S记录相似度值，归一化到0-1之间
R_G =max(R,G);
plusone=find(R==-1);
R_G(plusone)=-1;
Hash_train=res_Reduc.Hc; %d*N
paras.XXT= Hash_train*Hash_train';
paras.alpha = 2/K;
res_Hash=much_SNTH(Hash_train,R_G,M,K,paras)
train_H = res_Hash.H;
W_Hash = res_Hash.W;
test_value = W_Hash'*W_Reduc'*test_data; %K*N
test_H = (test_value'>=0);
train_B = res_Hash.B;
test_B = compactbit(test_H);

