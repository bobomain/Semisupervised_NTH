function [test_B,train_B]=SemiNTH_testNW(M,K,dirname_write,R_G,data,paras,num)

%load trainset
train_data = data.train_data;
test_data = data.test_data;
res = much_SNTH(train_data,R_G,M,K,paras);
train_H = res.H;
test_value=res.W'*test_data; %K*N
test_H=test_value'>=0;
train_B = res.B;
test_B = compactbit(test_H);
filename_test_Hbinary = [dirname_write,'semiNTH_test_NW_binary_',int2str(num),'.txt'];
dlmwrite(filename_test_Hbinary,test_H);
filename_train_Hbinary = [dirname_write,'semiNTH_train_NW_binary_',int2str(num),'.txt'];
dlmwrite(filename_train_Hbinary,train_H);
