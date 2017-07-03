function varargout = Reduc_Hash_NWparaOW7(varargin)
dirname_load = '/home/lf/much_code/monog_file/';
WTrue =load([dirname_load,'Wtrue_NWMulti_flags.txt']);
paras.nneighbors = 5;
batch = varargin{1}
rev_paras.pos = [1:10:100 100:20:200 200:50:500];
paras.delta = 0.1;

M=2;
K=32;
num=0
feature_train = load([dirname_load,'train_NWMulti.txt']);
feature_test = load([dirname_load,'test_NWMulti.txt']);
train_num=size(feature_train,1);%N*L
test_num=size(feature_test,1);%N*L
for paras.gamma=[1e-7]
    dirname_write = ['/home/lf/much_code/dblp_mongo_vector/Reduc_Hash/NWtestparas/batch_',batch,'/'];
    R =load([dirname_load,'NusWideMulti_CollectMatrix_',batch,'.txt']);
    XX = [feature_train; feature_test];
    sampleMean = mean(XX,1);
    XX = (double(XX)-repmat(sampleMean,size(XX,1),1));
    train_data = XX(1:train_num, :);%N*L
    test_data = XX(train_num+1:end, :);%N*L
    data.test_data = test_data'; %L*N
    data.train_data = train_data';
    %paras.RXXT=train_data'*train_data;
    for paras.gamma1=[1e-3,1e-5,1e-7,1e-9]
	for paras.gamma2 =[1e-3,1e-5,1e-7,1e-9]
	    num = num+1
	    paras.alpha = 2/K;
	    [test_B,train_B]=SemiStage_PcaOWtest(M,K,dirname_write,R,data,paras);
	    resRev=revolution_test(WTrue,test_B,train_B,M,K,rev_paras);
	    resRev.gamma=paras.gamma;
	    resRev.gamma1=paras.gamma1;
	    resRev.gamma2=paras.gamma2;

	    save([dirname_write,'recRev_NWMulti_parastest_7pcaow_',int2str(num),'.mat'],'resRev');
	end
    end
end
