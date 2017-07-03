function [M,K,Time] = much_p1p2_nuswide_bow(varargin)

t1=clock;
addpath(genpath(('./')));

R=load('much_nuswide/W_matrix_bow_dbpaper_tags10_500.txt');
feature_data = load('much_nuswide/train_dbpaper_bow_feature.txt'); %10000*500
train_data = feature_data'; %500*10000
train_num=size(train_data,2); %列数

%训练数据归一化，每列除以该列的模
%X = normc(train_data)
tem_train = train_data;
for i=1:train_num
   tem_train(:,i) = train_data(:,i)/norm(train_data(:,i));
end
train_data = tem_train;
M=varargin{1},
K = varargin{2},
paras.alpha = 2/K;
paras.delta = 1;
%paras.gamma1 = 0.5;
%paras.gamma2 = 0.5;
paras.gamma1 = 1.0e-10;
paras.gamma2 = 1.0e-7;

res =much(train_data,R,M,K,paras);

filename_Hc = ['dblp_mongo_vector/p1p2_nuswide_Hc/much_hash_code_nuswide_bow_',int2str(M),'_',int2str(K),'.txt']
filename_H = ['dblp_mongo_vector/p1p2_nuswide_Hc/much_hash_binary_nuswide_bow_',int2str(M),'_',int2str(K),'.txt']
filename_W = ['dblp_mongo_vector/p1p2_nuswide_Hc/much_W_matrix_nuswide_bow_',int2str(M),'_',int2str(K),'.txt']

dlmwrite(filename_Hc,res.Hc);
dlmwrite(filename_H,res.H);
dlmwrite(filename_W,res.W);

t2=clock;
Time=etime(t2,t1)
