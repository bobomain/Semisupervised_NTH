%ceshiwenjian
D=2,
t1 = clock;
R =load('nus_wide/collection_matrix.txt');
X = load('nus_wide/reduction_data.txt');
M=4,
K=24,
paras.alpha = 2/24;
paras.delta = 1;
paras.gamma1 = 0.5;
paras.gamma2 = 0.5;
A = 1,
res =much(X,R,M,K,paras);
B=2,
dlmwrite('nus_wide/Hash_code.txt',res.Hc);

dlmwrite('nus_wide/Hash_binary.txt',res.H);
dlmwrite('nus_wide/W_matrix.txt',res.W);
dlmwrite('nus_wide/origH.txt',res.origH);
dlmwrite('nus_wide/origW.txt',res.origW);
C=3,
t2 = clock;
etime(t2,t1) %2.0861e+04
