function varargout = Much_lda_octave(varargin)
test_time = ones(4,4);
train_time = ones(4,4);
batch=varargin{1},
dirname_write = ['/home/lf/much_code/dblp_mongo_vector/SemiNTH_lda_',batch,'/'];
dirname_load = '/home/lf/much_code/monog_file/';
R =load([dirname_load,'dblp_CollectMatrix_',batch,'.txt']);
feature_train = load([dirname_load,'train_lda.txt']);
feature_test = load([dirname_load,'test_lda.txt']);
train_num=size(feature_train,1),%N*L
test_num=size(feature_test,1),%N*L

WTrue =load([dirname_load,'Wtrue_LDA_flags.txt']);
nneighbors=train_num*0.05;

DIST = distMat(feature_train, feature_train, 0) ; %欧氏距离
DIST = DIST + max(DIST(:))*eye(train_num); %矩阵DIST先组成一列元素，这一列元素的最大值、eye(A) A*A的单位阵;DIST的对角元素修改为矩阵的最大元素
[~, IDX] = sort(DIST, 2); %沿着行方向，升序排列DIST中的行元素，每行元素置换前的所在位置存储在IDX的每行对应位置中 IDX是与DIST等大的位置索引矩阵
%将DIST距离矩阵中的距离，由小到大排序
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

% generate training ans test split and the data matrix
XX = [feature_train; feature_test];
% center the data, VERY IMPORTANT
sampleMean = mean(XX,1);
XX = (double(XX)-repmat(sampleMean,size(XX,1),1));
train_data = XX(1:train_num, :);%N*L
test_data = XX(train_num+1:end, :);%N*L
data.test_data = test_data'; %L*N
data.train_data = train_data';

%DtrueTestTraining = distMat(feature_test,feature_train);
%测试样本与训练样本之间的距离
%[Dball, I] = sort(DtrueTestTraining,2); %按行排列，每一行表示测试样本数据点与训练样本数据点的距离
%exp_data.knn_p2 = I(:,1:nneighbors); %保存测试数据点的前5%个近邻索引 
%exp_data.dis_p2 = Dball(:,1:nneighbors); %保存测试数据点的前5%个近邻的欧式距离 
rev_paras.pos = [1:10:40 50:50:1000];

for M = 1:4
    for K = [8,16,24,32]
        [test_time(M,K/8),train_time(M,K/8),test_B,train_B]=SemiNTH_lda(M,K,dirname_write,R_G,data);
	resRev=revolution(WTrue,test_B,train_B,M,K,rev_paras);
        dlmwrite([dirname_write,'SemiNTH_recRev',int2str(M),'_',int2str(K),'.txt'],resRev);
end
end
train_time
test_time
dlmwrite([dirname_write,'SemiNTH_train_time.txt'],train_time);
dlmwrite([dirname_write,'SemiNTH_test_time.txt'],test_time);

