dirname_load = '/home/lf/much_code/monog_file/';
WTrue =load([dirname_load,'Wtrue_NW_flags.txt']);
result_file = '/home/lf/much_code/dblp_mongo_vector/resRev/';
% generate training ans test split and the data matrix
%rev_paras.pos = [1:10:40 50:50:1000];
rev_paras.pos = [1:10:100 100:20:200];
for batch = 0:9
    batch,
    dirname_write = ['/home/lf/much_code/dblp_mongo_vector/much_p1p2_NW_Hc_',int2str(batch),'/'];
    R =load([dirname_load,'NusWide_CollectMatrix_',int2str(batch),'.txt']);
    for M = 1:4
        for K = [8,16,24,32]
	    test_H = load([dirname_write,'much_test_NW_binary_',int2str(M),'_',int2str(K),'.txt']);
	    train_H = load([dirname_write,'much_train_NW_binary_',int2str(M),'_',int2str(K),'.txt']);
	    [I,J]=size(train_H);
            if I<J
                train_H = train_H';
            end
	    [I,J]=size(train_H);
            if I<J
                test_H = test_H';
            end
	    test_B = compactbit(test_H);
	    train_B = compactbit(train_H);
	    resRev=revolution_test(WTrue,test_B,train_B,M,K,rev_paras);
            save([result_file,'much_NW_recRev_',int2str(batch),'_',int2str(M),'_',int2str(K),'.mat'],'resRev');
        end
    end
end
