
%R is the relation_matrix of the training data,5000*5000
%train_data is the BOW of SIFT feature of the training data,500*5000
function [test_time,train_time]=much_p1p2_NW(varargin)
t1 = clock;
dirname_write = varargin{3};
dirname_load = '/home/lf/much_code/monog_file/'
R =load([dirname_load,'NusWide_CollectMatrix_',int2str(varargin{4}),'.txt']);

train_data=load([dirname_load,'train_NW.txt'])';
M=varargin{1},
K=varargin{2},
paras.alpha = 2/K;
paras.delta = 1;
paras.gamma1 = 1.0e-10;
paras.gamma2 = 1.0e-7;
train_num = size(train_data,2),
tem_train = train_data;
for i=1:train_num
tem_train(:,i) = train_data(:,i)/norm(train_data(:,i));
end
X=tem_train;
res =much(X,R,M,K,paras);
%train_hash_value = res.W'*X; %d*N
%median_train_Hc = train_hash_value';%N*d
median_train_Hc = res.Hc';%N*d
hash_num = size(median_train_Hc,2);
for i=1:hash_num
    median_train_Hc(:,i)=median_train_Hc(:,i)-median(median_train_Hc)(i);
end
much_train_Y = ones(size(median_train_Hc))*(1);
much_train_Y(median_train_Hc<0)=0;
t2=clock;
train_time = etime(t2,t1);
filename_W = [dirname_write,'much_train_NW_W','_',int2str(M),'_',int2str(K),'.txt'];
dlmwrite(filename_W,res.W);
filename_train_Hc = [dirname_write,'much_train_NW','_',int2str(M),'_',int2str(K),'.txt'];
filename_train_Hbinary = [dirname_write,'much_train_NW_binary','_',int2str(M),'_',int2str(K),'.txt'];
dlmwrite(filename_train_Hc,much_train_Y);
dlmwrite(filename_train_Hbinary,res.H');
test_data = load([dirname_load,'test_NW.txt'])';
test_num = size(test_data,2),
tem_test = test_data;
for i=1:test_num
    tem_test(:,i) = test_data(:,i)/norm(test_data(:,i));
end
test_hash_value=res.W'*tem_test; %d*N
median_test_Hc = test_hash_value';%N*d
for i=1:hash_num
    median_test_Hc(:,i)=test_hash_value'(:,i)-median(test_hash_value')(i);
end
much_test_Y = ones(size(median_test_Hc))*(1);
much_test_Y(median_test_Hc<0)=0;
t3=clock;
filename_test_Hc = [dirname_write,'much_test_NW_',int2str(M),'_',int2str(K),'.txt'];
dlmwrite(filename_test_Hc,much_test_Y);
filename_test_Hbinary = [dirname_write,'much_test_NW_binary_',int2str(M),'_',int2str(K),'.txt'];
dlmwrite(filename_test_Hbinary,test_hash_value'>=0);

test_time=etime(t3,t2);
