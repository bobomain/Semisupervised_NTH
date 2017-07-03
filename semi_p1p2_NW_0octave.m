test_time=ones(1,3);
train_time=ones(1,3);

batch=0;
dirname_write = ['/home/lf/much_code/dblp_mongo_vector/semi_p1p2_NW_Hc/'];
M = 4;
for K = [16,24,32]
        [test_time(1,K/8),train_time(1,K/8)]=semi_p1p2_NW(M,K,dirname_write,batch);
end

train_time
test_time
dlmwrite([dirname_write,'semi_train_time_',int2str(M),'.txt'],train_time);
dlmwrite([dirname_write,'semi_test_time_',int2str(M),'.txt'],test_time);
