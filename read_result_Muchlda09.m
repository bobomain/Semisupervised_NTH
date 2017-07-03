%dirname = '/home/lf/much_code/dblp_mongo_vector/SemiNTH_NW_';
%filename = '/recRev_list200_g1e5g2e9_';

much_filename = '/home/lf/much_code/dblp_mongo_vector/Much_Multi/Multilda_';

mean_result.recall = zeros(3,23);
mean_result.precision = zeros(3,23);
mean_result.pos_recall = zeros(23,16);
mean_result.pos_precision = zeros(23,16);
mean_result.map = zeros(1,16);
mean_result.pos_map = zeros(1,16);
mean_result.ridus= zeros(23,16);
mean_result.train_time = zeros(1,16);
for M =1:4
    for K = [8,16,24,32]
	recall=[];
        precision=[];
        pos_recall=[];
        pos_precision=[];
        map=[];
        pos_map=[];
        ridus=[];
	train_time = [];
	for batch = [0:9]
    	   %f=load([dirname,int2str(batch),filename,int2str(M),'_',int2str(K),'.mat']);	    
    	   f=load([much_filename,int2str(batch),'/Multilda_list500','_',int2str(M),'_',int2str(K),'.mat']);	    
	   recall =[recall,f.resRev.recall];
	   precision = [precision,f.resRev.precision];
	   pos_recall = [pos_recall,f.resRev.rec];
	   pos_precision= [pos_precision,f.resRev.pre];
	   map = [map,f.resRev.mAp];
	   pos_map = [pos_map,f.resRev.mAp_pos];
	   ridus =[ridus,f.resRev.ridus'];	
%	   train_time = [train_time,f.resRev.train_time];
	end
%	M,K,recall,
	index=4*(M-1)+K/8
	mean_result.recall(:,index) = mean(recall,2);
	mean_result.precision(:,index) = mean(precision,2);
	mean_result.pos_recall(:,index) = mean(pos_recall,2);
	mean_result.pos_precision(:,index) = mean(pos_precision,2);
	mean_result.map(:,index) = mean(map,2);
	mean_result.pos_map(:,index) = mean(pos_map,2);
	mean_result.ridus(:,index) = mean(ridus,2);
%	mean_result.train_time(:,index) = mean(train_time,2);
%	index= index+1;
%	mean_result.recall,
    end
end
%save(['/home/lf/much_code/dblp_mongo_vector/resRev/mean_result/Semi_batch03_MResult.mat'],'mean_result');
save(['/home/lf/much_code/dblp_mongo_vector/resRev/mean_result/MuchMultilda_batch09_MResult.mat'],'mean_result');
