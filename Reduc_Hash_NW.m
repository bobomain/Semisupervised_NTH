dirname_load = '/home/lf/much_code/monog_file/';
WTrue =load([dirname_load,'Wtrue_NWMulti_flags.txt']);
paras.nneighbors = 5;
rev_paras.pos = [1:10:100 100:20:200 200:50:500];
paras.gamma = 1e-9;
paras.delta = 0.1;
paras.gamma1 = 1e-5;
paras.gamma2=1e-9;
train_time = ones(4,4);
test_time = ones(4,4);
feature_train = load([dirname_load,'train_NWMulti.txt']);
feature_test = load([dirname_load,'test_NWMulti.txt']);
train_num=size(feature_train,1);%N*L
test_num=size(feature_test,1);%N*L
for item = [0:1]
    batch = int2str(item)
    dirname_write = ['/home/lf/much_code/dblp_mongo_vector/Reduc_Hash/MultiNW_',batch,'/'];
    R =load([dirname_load,'NusWideMulti_CollectMatrix_',batch,'.txt']);
    XX = [feature_train; feature_test];
    sampleMean = mean(XX,1);
    XX = (double(XX)-repmat(sampleMean,size(XX,1),1));
    train_data = XX(1:train_num, :);%N*L
    test_data = XX(train_num+1:end, :);%N*L
    data.test_data = test_data'; %L*N
    data.train_data = train_data';
    paras.RXXT=train_data'*train_data;
    for M=[1,2,3,4]
	for K =[8,16,24,32]
	    paras.alpha = 2/K;
	    [train_time(M,K/8),test_B,train_B]=SemiHash_Stage(M,K,dirname_write,R,data,paras);
	    t1 = clock;
	    resRev=revolution_test(WTrue,test_B,train_B,M,K,rev_paras);
  	    t2 = clock;
	    test_time(M,K/8)=etime(t2,t1);
	    save([dirname_write,'recRev_NWMulti_N2list500_',int2str(M),'_',int2str(K),'.mat'],'resRev');
	end
    end
train_time
test_time
dlmwrite([dirname_write,'SemiNTH_NWMulti_train_time.txt'],train_time);
dlmwrite([dirname_write,'SemiNTH_NWMulti_test_time.txt'],test_time);
end
