function varargout = Test_ground_octave(varargin)
dirname_origin = '/home/lf/much_code/monog_file/';
dataset = varargin{1}
if strcmp(dataset,'lda')
        WTrue =load([dirname_origin,'Wtrue_LDA_flags.txt']);
else if strcmp(dataset,'NW')
	WTrue =load([dirname_origin,'Wtrue_NW_flags.txt']);
end
end
result_file = '/home/lf/much_code/dblp_mongo_vector/resRev/',
% generate training ans test split and the data matrix
rev_paras.pos = [1:10:40 50:50:1000];
model_list = {'ITQ','SH','SSH','LSH'};
for batch = 0:9
    batch,
    dirname_load = ['/home/lf/much_code/test_gene_',dataset,'/batch_dblp_',int2str(batch),'/'];
    for j=1:4
        for K = [8,16,24,32,48,64,96,128]
	    model=model_list{1,j};
	    test_H = load([dirname_load,dataset,'_',model,'_test_Hc_',int2str(K),'.txt']);
	    train_H = load([dirname_load,dataset,'_',model,'_train_Hc_',int2str(K),'.txt']);
	    test_B = compactbit(test_H);
	    train_B = compactbit(train_H);
	    resRev=revolution_formal(WTrue,test_B,train_B,rev_paras);
            save([result_file,dataset,'_ground_recRev_',model,'_',int2str(K),'.mat'],'resRev');
        end
    end
end
