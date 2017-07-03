function [test_time,train_time,test_B,train_B]=SemiNTH_NW(M,K,dirname_write,R_G,data,paras)

t1 = clock;
%load trainset
train_data = data.train_data;
test_data = data.test_data;
res = much_SNTH(train_data,R_G,M,K,paras);
t2=clock;
train_time = etime(t2,t1);
train_H = res.H;
test_value=res.W'*test_data; %K*N
test_H=test_value'>=0;
t3=clock;
test_time = etime(t3,t2);
train_B = res.B;
test_B = compactbit(test_H);
filename_W = [dirname_write,'SemiNTH_W_LK_',int2str(M),'_',int2str(K),'.txt'];
dlmwrite(filename_W,res.W);
filename_test_Hbinary = [dirname_write,'semiNTH_test_NW_binary_',int2str(M),'_',int2str(K),'.txt'];
dlmwrite(filename_test_Hbinary,test_H);
filename_train_Hbinary = [dirname_write,'semiNTH_train_NW_binary_',int2str(M),'_',int2str(K),'.txt'];
dlmwrite(filename_train_Hbinary,train_H);
