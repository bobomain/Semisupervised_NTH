dirname_load = '/home/lf/much_code/monog_file/';
WTrue =load([dirname_load,'Wtrue_LDA_flags.txt']);
result_file = '/home/lf/much_code/dblp_mongo_vector/resRev/';
% generate training ans test split and the data matrix
rev_paras.pos = [1:10:40 50:50:1000];
for batch = 0:9
    batch,
    dirname_write = ['/home/lf/much_code/dblp_mongo_vector/much_p1p2_lda_Hc_',int2str(batch),'/'];
    R =load([dirname_load,'dblp_CollectMatrix_',int2str(batch),'.txt']);
    for M = 1:4
        for K = [8,16,24,32]
	    test_H = load([dirname_write,'much_test_lda_',int2str(M),'_',int2str(K),'.txt']);
	    train_H = load([dirname_write,'much_train_lda_',int2str(M),'_',int2str(K),'.txt']);
	    test_B = compactbit(test_H);
	    train_B = compactbit(train_H);
	    resRev=revolution_formal(WTrue,test_B,train_B,rev_paras);
            save([result_file,'much_recRev_',int2str(batch),'_',int2str(M),'_',int2str(K),'.mat'],'resRev');
        end
    end
end
