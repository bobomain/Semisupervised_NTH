function res = Reduc_Stage(X,R,d,paras)

%Input:
%	X:feature matrix L*N, L is dimension of feature, N is the number of samples
%	G:Similarity based on in origin space by

[L N]=size(X); %L*N
H=zeros(d,N);
W=randn(L,d);
Wvec=reshape(W,L*d,1);
[Wopt objs iter]=minimize(Wvec,'obj_SemiFirst',200,X,R,d,paras);
W=reshape(Wopt,L,d);
res.Hc = W'*X;
res.W = W;
end

