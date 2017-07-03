dirname_load = '/home/lf/much_code/monog_file/';
WTrue =load([dirname_load,'Wtrue_NW_flags.txt']);
nneighbors=5,
rev_paras.pos = [1:20:300 300];
paras.delta=0.1;
paras.gamma1 = 1e-5;
paras.gamma2 = 1e-9;
test_time = ones(4,4);
train_time = ones(4,4);
feature_train = load([dirname_load,'train_NW.txt']);
feature_test = load([dirname_load,'test_NW.txt']);
train_num=size(feature_train,1);%N*L
test_num=size(feature_test,1);%N*L
for batch=3
    dirname_write = ['/home/lf/much_code/dblp_mongo_vector/SemiNTH_NW_',int2str(batch),'/'];
    R =load([dirname_load,'NusWide_CollectMatrix_',int2str(batch),'.txt']);

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

    XX = [feature_train; feature_test];
    sampleMean = mean(XX,1);
    XX = (double(XX)-repmat(sampleMean,size(XX,1),1));
    train_data = XX(1:train_num, :);%N*L
    test_data = XX(train_num+1:end, :);%N*L
    data.test_data = test_data'; %L*N
    data.train_data = train_data';
    paras.XXT=train_data'*train_data;
for M = [4,3,2,1]
    for K = [32,16,24,8]
     	paras.alpha = 2/K;
        [test_time(M,K/8),train_time(M,K/8),test_B,train_B]=SemiNTH_NW(M,K,dirname_write,R_G,data,paras);
        resRev=revolution_test(WTrue,test_B,train_B,M,K,rev_paras);
        save([dirname_write,'SemiNTH_recRev_g1e5g2e9_',int2str(M),'_',int2str(K),'.mat'],'resRev');
end
end
train_time
test_time
dlmwrite([dirname_write,'SemiNTH_train_time.txt'],train_time);
dlmwrite([dirname_write,'SemiNTH_test_time.txt'],test_time);
end
