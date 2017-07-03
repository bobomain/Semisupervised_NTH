dirname_load = '/home/lf/much_code/monog_file/';
WTrue =load([dirname_load,'Wtrue_MultiLDA_flags.txt']);
result_file = '/home/lf/much_code/dblp_mongo_vector/resRev/';
% generate training ans test split and the data matrix
rev_paras.pos = [1:10:100 100:20:200 200:50:500];
for batch = 0:9
    batch,
    dirname_write = ['/home/lf/much_code/dblp_mongo_vector/much_p1p2_lda_Hc_',int2str(batch),'/'];
    for M = 1:4
        for K = [8,16,24,32]
	    test_H = load([dirname_write,'much_test_lda_binary_',int2str(M),'_',int2str(K),'.txt']);
	    [I,J]=size(test_H);
	    if I<J
    		test_H = test_H';
	    end
	    train_H = load([dirname_write,'much_train_lda_binary_',int2str(M),'_',int2str(K),'.txt']);
	    [I,J]=size(train_H);
	    if I<J
                train_H = train_H';
            end
	    test_B = compactbit(test_H);
	    train_B = compactbit(train_H);
	    resRev=revolution_test(WTrue,test_B,train_B,M,K,rev_paras);
            save([result_file,'much_Multilda_recRev_',int2str(batch),'_',int2str(M),'_',int2str(K),'.mat'],'resRev');
        end
    end
end
