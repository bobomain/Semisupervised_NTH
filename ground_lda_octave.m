%function varargout = ground_tfidf_octave()
time_LSH = ones(3,8);
time_SH = ones(3,8);
time_SSH = ones(3,8);
time_ITQ = ones(3,8);
for batch = 3:5;
    batch,
    count =1;
    for k = [8,16,24,32,48,64,96,128]
        [time_LSH(batch+1,count),time_SH(batch+1,count),time_ITQ(batch+1,count),time_SSH(batch+1,count)]=ground_method('lda',k,batch);
	%col_index = batch+1;
	%t_LSH,t_SH,t_ITQ,t_SSH,
	%time_LSH(col_index,count)=t_LSH,
	%time_SH(col_index,count)=t_SH,
	%time_ITQ(col_index,count)=t_ITQ,
	%time_SSH(col_index,count)=t_SSH,
	count =count+1;
end
end
time_LSH,
time_SH,
time_ITQ,
time_SSH,
dirname = '/home/lf/much_code/test_gene/';
dlmwrite([dirname,'lda_LSH_time.txt'],time_LSH);
dlmwrite([dirname,'lda_SH_time.txt'],time_SH);
dlmwrite([dirname,'lda_SSH_time.txt'],time_SSH);
dlmwrite([dirname,'lda_ITQ_time.txt'],time_ITQ);
