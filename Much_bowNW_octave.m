function varargout = Much_bowNW_octave(varargin)
dirname_load = '/home/lf/much_code/monog_file/';
WTrue =load([dirname_load,'Wtrue_NW_flags.txt']);
rev_paras.pos = [1:10:100 100:20:200];
feature_train = load([dirname_load,'train_NW_bow.txt']);
feature_test = load([dirname_load,'test_NW_bow.txt']);
train_num=size(feature_train,1);%N*L
test_num=size(feature_test,1);%N*L
paras.delta = 1;
paras.gamma1 = 1.0e-10;
paras.gamma2 = 1.0e-7;
batch=varargin{1}
    dirname_write = ['/home/lf/much_code/dblp_mongo_vector/Much_NW_bow_',batch,'/'];
    R =load([dirname_load,'NusWide_CollectMatrix_',batch,'.txt']);
    XX = [feature_train; feature_test];
    sampleMean = mean(XX,1);
    XX = (double(XX)-repmat(sampleMean,size(XX,1),1));
    train_data = XX(1:train_num, :);%N*L
    test_data = XX(train_num+1:end, :);%N*L
    data.test_data = test_data'; %L*N
    data.train_data = train_data';
for M = [1,2,3,4]
    for K = [8,16,24,32]
     	paras.alpha = 2/K;
        [test_time(M,K/8),train_time(M,K/8),test_B,train_B]=Much_NW(M,K,dirname_write,R,data,paras);
        resRev=revolution_test(WTrue,test_B,train_B,M,K,rev_paras);
        save([dirname_write,'recRev_list200_bowNW_',int2str(M),'_',int2str(K),'.mat'],'resRev');
end
end
train_time
test_time
dlmwrite([dirname_write,'Much_bowNW_train_time.txt'],train_time);
dlmwrite([dirname_write,'Much_bowNW_test_time.txt'],test_time);

