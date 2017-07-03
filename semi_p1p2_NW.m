
%R is the relation_matrix of the training data,5000*5000
%train_data is the BOW of SIFT feature of the training data,500*5000
function [test_time,train_time]=semi_p1p2_NW(varargin)
t1 = clock;
dirname_write = varargin{3};
dirname_load = '/home/lf/much_code/monog_file/'
R =load([dirname_load,'NusWide_CollectMatrix_',int2str(varargin{4}),'.txt']);
feature_data=load([dirname_load,'train_NW.txt']);
train_num=size(feature_data,1),
%%pre-proceding
nneighbors=30;
train_data = feature_data'; 1134*10000
DIST = distMat(train_data', train_data', 0) ; %欧氏距离
DIST = DIST + max(DIST(:))*eye(train_num); %矩阵DIST先组成一列元素，这一列元素的最大值、eye(A) A*A的单位阵;DIST的对角元素修改为矩阵的最大元素
[~, IDX] = sort(DIST, 2); %沿着行方向，升序排列DIST中的行元素，每行元素置换前的所在位置存储在IDX的每行对应位置中 IDX是与DIST等大的位置索引矩阵
%将DIST距离矩阵中的距离，由小到大排序
S = zeros(train_num);
for i = 1:train_num
    S(i, IDX(i,1:nneighbors)) = DIST(i, IDX(i,1:nneighbors)); %厉害了，使用位置索引把与最相近的5个相邻元素的距离找到
end
S = (S+S')/2;%相似性调整
dist =max(S(:)); %距离的最大值
S = full(S>0).*sparse(exp(-(S)./dist)); %用稀疏矩阵S记录相似度值，归一化到0-1之间
L = eye(train_num)-diag(sum(S).^(-0.5))*S*diag(sum(S).^(-0.5)); %归一化L，L=I-D^(-0.5).*W.*D^(-0.5) S即W，D>为S列或行的元素和

tem_train = train_data;
for i=1:train_num
   tem_train(:,i) = train_data(:,i)/norm(train_data(:,i));
end
data.train_data = tem_train;

%Shared subspace hyperplane
SSHparam.nbits = varargin{1}*varargin{2};
SSHparam.alpha = 1;
SSHparam.beta = 1;
SSHparam.gamma = 1e-1;
SSHparam.rdim = SSHparam.nbits;% 

SSHparam.max_iter = 30;
SSHparam.tol = 1e-18;
SSHparam.useanchor = 0;
SSHparam.nn = 5;%当SSHparam.useanchor参数为1时，trainSSH会用到
data.S = S;

SSHparam = trainSSH(data, SSHparam);
reduction_data = SSHparam.w'*data.train_data+ SSHparam.b*ones(1,train_num); %d*N
M=varargin{1},
K=varargin{2},
paras.alpha = 2/K;
paras.delta = 1;
paras.gamma1=1e-10;
paras.gamma2=1e-7;
paras.W = SSHparam.w;
paras.B = SSHparam.b;
res = much(data.train_data,R,M,K,paras);
median_train_Hc = res.Hc';%N*d
hash_num = size(median_train_Hc,2);
for i=1:hash_num
    median_train_Hc(:,i)=median_train_Hc(:,i)-median(median_train_Hc)(i);
end
much_train_Y = ones(size(median_train_Hc))*(1);
much_train_Y(median_train_Hc<0)=0;
t2=clock;
train_time = etime(t2,t1);
filename_train_Hc = [dirname_write,'semi_train_NW','_',int2str(M),'_',int2str(K),'.txt'];
filename_train_Hbinary = [dirname_write,'semi_train_NW_binary','_',int2str(M),'_',int2str(K),'.txt'];
dlmwrite(filename_train_Hc,much_train_Y);
dlmwrite(filename_train_Hbinary,res.H');
test_data = load([dirname_load,'test_NW.txt'])'; %L*N
test_num = size(test_data,2),
tem_test = test_data;
for i=1:test_num
    tem_test(:,i) = test_data(:,i)/norm(test_data(:,i));
end
test_data = tem_test;
test_hash_value=res.W'*test_data; %K*N
median_test_Hc = test_hash_value';%N*K
for i=1:hash_num
    median_test_Hc(:,i)=test_hash_value'(:,i)-median(test_hash_value')(i);
end
much_test_Y = ones(size(median_test_Hc))*(1);
much_test_Y(median_test_Hc<0)=0;
t3=clock;
filename_test_Hc = [dirname_write,'semi_test_NW_',int2str(M),'_',int2str(K),'.txt'];
filename_test_Hbinary = [dirname_write,'semi_test_NW_binary_',int2str(M),'_',int2str(K),'.txt'];
dlmwrite(filename_test_Hc,much_test_Y);
dlmwrite(filename_test_Hbinary,test_hash_value'>=0);

test_time = etime(t3,t2);
%filename_Hc = [dirname_write,'semi_Hc_NW_',int2str(M),'_',int2str(K),'.txt']
%filename_H = [dirname_write,'semi_hash_binary_NW_',int2str(M),'_',int2str(K),'.txt']
%filename_muchW = [dirname_write,'semi_muchW_NW_',int2str(M),'_',int2str(K),'.txt']
%filename_sshW = [dirname_write,'semi_sshW_NW_',int2str(M),'_',int2str(K),'.txt']
%filename_B = [dirname_write,'semi_B_NW_',int2str(M),'_',int2str(K),'.txt']

%dlmwrite(filename_Hc,res.Hc);
%dlmwrite(filename_H,res.H);
%dlmwrite(filename_muchW,res.W);
%dlmwrite(filename_B,SSHparam.b);
%dlmwrite(filename_sshW,SSHparam.w);
