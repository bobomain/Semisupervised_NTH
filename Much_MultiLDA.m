function varargout = Much_MultiLDA(varargin)
dirname_load = '/home/lf/much_code/monog_file/';
WTrue =load([dirname_load,'Wtrue_MultiLDA_flags.txt']);
nneighbors=5,
rev_paras.pos = [1:10:100 100:20:200 200:50:500];
paras.delta=0.1;
paras.gamma1 = 1e-10;
paras.gamma2 = 1e-7;
test_time = ones(4,4);
train_time = ones(4,4);
feature_train = load([dirname_load,'train_lda.txt']);
feature_test = load([dirname_load,'test_Multi_lda.txt']);
train_num=size(feature_train,1);%N*L
test_num=size(feature_test,1);%N*L
    batch = varargin{1} 
    dirname_write = ['/home/lf/much_code/dblp_mongo_vector/Much_Multi/Multilda_',batch,'/'];
    R =load([dirname_load,'dblp_CollectMatrix_',batch,'.txt']);
    XX = [feature_train; feature_test];
    sampleMean = mean(XX,1);
    XX = (double(XX)-repmat(sampleMean,size(XX,1),1));
    train_data = XX(1:train_num, :);%N*L
    test_data = XX(train_num+1:end, :);%N*L
    data.test_data = test_data'; %L*N
    data.train_data = train_data';
    paras.XXT=train_data'*train_data;
for M = [1,2,3,4]
    for K = [8,16,24,32]
	filename = [dirname_write,'Multilda_list500_',int2str(M),'_',int2str(K),'.mat'];
	if exist(filename,'file') == 0
     	paras.alpha = 2/K;
        [train_time(M,K/8),test_B,train_B]=Much_Com(M,K,dirname_write,R,data,paras);
        t1 = clock;
	resRev=revolution_test(WTrue,test_B,train_B,M,K,rev_paras);
	t2=clock;
	resRev.test_time = etime(t2,t1);
	resRev.train_time = train_time(M,K/8);
        test_time(M,K/8)=etime(t2,t1);
	save([dirname_write,'Multilda_list500_',int2str(M),'_',int2str(K),'.mat'],'resRev');
	end
end
end
train_time
test_time
dlmwrite([dirname_write,'Muchlda_train_time.txt'],train_time);
dlmwrite([dirname_write,'Multilda_test_time.txt'],test_time);
end
