test_time = ones(4,4);
train_time = ones(4,4);
batch=9;
dirname_write = ['/home/lf/much_code/dblp_mongo_vector/semi_p1p2_lda_Hc_',int2str(batch),'/'];
for M = 1:4
    for K = [8,16,24,32]
        [test_time(M,K/8),train_time(M,K/8)]=semi_p1p2_lda(M,K,dirname_write,batch);
end
end
train_time
test_time
dlmwrite([dirname_write,'semi_train_time.txt'],train_time);
dlmwrite([dirname_write,'semi_test_time.txt'],test_time);

