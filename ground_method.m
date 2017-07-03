function [time_LSH,time_SH,time_ITQ,time_SSH] = ground_method(varargin)
tic;
train_dblp_ND =load(['/home/lf/much_code/monog_file/train_',varargin{1},'.txt']);
dirname = ['/home/lf/much_code/test_gene/batch_dblp_',int2str(varargin{3}),'/']
train_num = size(train_dblp_ND,1);
nneighbors = 30;
train_data = train_dblp_ND'; %d*N
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
L = eye(train_num)-diag(sum(S).^(-0.5))*S*diag(sum(S).^(-0.5)); %归一化L，L=I-D^(-0.5).*W.*D^(-0.5) S即W，D为S列或行的元素和

%训练数据归一化，每列除以该列的模
%X = normc(train_data)
tem_train = train_data; %d*N
for i=1:train_num
   tem_train(:,i) = train_data(:,i)/norm(train_data(:,i));
end
data.train_data = tem_train; %d*N
X = train_data'; %N*d
train_data = data.train_data; %d*N
nbits = varargin{2}
t1=toc;
%LSH
tic;
LSHparam.nbits = nbits;
LSHparam = trainLSH(X, LSHparam);   
LSH_train = X*LSHparam.w; %N*K
LSH_train = (LSH_train>0); %N*k
tLSH=toc;

%%Spectral hyperplane
tic;
SHparam.nbits = nbits;
SHparam = trainSH(data, SHparam);
SH_train = compressSH(X,SHparam); %N*k
tSH=toc; 
%ITQ
tic;
ITQparam.nbits = nbits;
ITQparam.iter = 50;
ITQparam = trainITQ(data,ITQparam);
ITQ_train=compressITQ(X,ITQparam); %N*K
tITQ=toc;
%SSH
%Shared subspace hyperplane
tic;
SSHparam.nbits = nbits;
SSHparam.alpha = 1;
SSHparam.beta = 1;
SSHparam.gamma = 1e-1;
SSHparam.rdim = nbits;% 

SSHparam.max_iter = 30;
SSHparam.tol = 1e-18;
data.S = S; 
SSHparam = trainSSH(data,SSHparam);
Y = SSHparam.w'*train_data + SSHparam.b*ones(1,train_num);%K*N
SSH_train = (Y'>0);%N*K
tSSH=toc;

time_LSH = tLSH+t1;
time_SH = tSH+t1;
time_ITQ = tITQ+t1;
time_SSH = tSSH+t1;
dlmwrite([dirname,varargin{1},'_LSH_train_Hc_',int2str(nbits),'.txt'],LSH_train)
dlmwrite([dirname,varargin{1},'_SH_train_Hc_',int2str(nbits),'.txt'],SH_train)
dlmwrite([dirname,varargin{1},'_ITQ_train_Hc_',int2str(nbits),'.txt'],ITQ_train)
dlmwrite([dirname,varargin{1},'_SSH_train_Hc_',int2str(nbits),'.txt'],SSH_train)


%%%%%%%%%%%%TEST SET
test_dblp_ND =load(['/home/lf/much_code/monog_file/test_',varargin{1},'.txt']);
test_num = size(test_dblp_ND,1);
test_data = test_dblp_ND'; %d*N
tem_test = test_data;
for i=1:test_num
   tem_test(:,i) = test_data(:,i)/norm(test_data(:,i));
end
test_data = tem_test; %d*N
X_test = tem_test'; %N*d
%LSH
LSH_test = X_test*LSHparam.w; %N*K
LSH_test = (LSH_test>0);
LSH_TEsize = size(LSH_test),
dlmwrite([dirname,varargin{1},'_LSH_test_Hc_',int2str(nbits),'.txt'],LSH_test)
SH_test = compressSH(X_test,SHparam);% N*K
SH_TEsize = size(SH_test),
dlmwrite([dirname,varargin{1},'_SH_test_Hc_',int2str(nbits),'.txt'],SH_test)
ITQ_test = compressITQ(X_test,ITQparam); %N*K
ITQ_TEsize = size(ITQ_test),
dlmwrite([dirname,varargin{1},'_ITQ_test_Hc_',int2str(nbits),'.txt'],ITQ_test)
SSH_Y_test =SSHparam.w'*test_data + SSHparam.b*ones(1,test_num);
SSH_test = (SSH_Y_test'>0); %N*K
SSH_TEsize = size(SSH_test),
dlmwrite([dirname,varargin{1},'_SSH_test_Hc_',int2str(nbits),'.txt'],SSH_test)

