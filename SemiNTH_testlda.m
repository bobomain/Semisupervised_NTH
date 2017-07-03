function [test_B,train_B]=SemiNTH_testlda(M,K,dirname_write,R_G,data,paras)

%load trainset
train_data = data.train_data;
test_data = data.test_data;
res = much_SNTH(train_data,R_G,M,K,paras);
train_H = res.H;
test_value=res.W'*test_data; %K*N
test_H=test_value'>=0;
train_B = res.B;
test_B = compactbit(test_H);
