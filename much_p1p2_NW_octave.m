test_time = ones(4,4);
train_time = ones(4,4);
batch=1;
dirname_write = ['/home/lf/much_code/dblp_mongo_vector/much_p1p2_NW_Hc_',int2str(batch),'/'];
for M = 1:4
for K = [8,16,24,32]
    [test_time(M,K/8),train_time(M,K/8)]=much_p1p2_NW(M,K,dirname_write,batch);
end
end
train_time
test_time
dlmwrite([dirname_write,'much_train_time.txt'],train_time);
dlmwrite([dirname_write,'much_test_time.txt'],test_time);
