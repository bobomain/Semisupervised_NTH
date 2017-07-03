dirname_load = '/home/lf/much_code/monog_file/';
WTrue =load([dirname_load,'Wtrue_NW_flags.txt']);
nneighbors=5;
rev_paras.pos = [1:10:40 50:50:1000];
M=2;
K=16;
paras.delta=0.1;
paras.alpha = 2/K;
feature_train = load([dirname_load,'train_NW.txt']);
feature_test = load([dirname_load,'test_NW.txt']);
train_num=size(feature_train,1),%N*L
test_num=size(feature_test,1),%N*L
for batch=[3]
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
    num =1;
for gamma1 = [1e-9]
    for gamma2 = [1e-11,1e-9,1e-7,1e-5,1e-3]
        paras.gamma1 = gamma1;
        paras.gamma2 = gamma2;
        [test_B,train_B]=SemiNTH_testNW(M,K,dirname_write,R_G,data,paras,num);
        resRev=revolution_test(WTrue,test_B,train_B,M,K,rev_paras);
        resRev.gamma1=gamma1;
        resRev.gamma2=gamma2;
        resRev.delta=paras.delta;
        resRev.alpha=paras.alpha;
        save([dirname_write,'SemiNTH_recRev_nei5_g1e9_',int2str(num),'.mat'],'resRev');
        num = num+1;
end
end
end
