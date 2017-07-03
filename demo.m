% Large-Scale Unsupervised Hashing with Shared Structure Learning
% Xianglong Liu, Yadong Mu, Danchen Zhang, Bo Lang, Xuelong Li.
% IEEE Transactions on Cybernetics, 2015
% Contact: xlliu@nlsde.buaa.edu.cn
% This package contains a demo code for the above paper.
% We appreciate your citation and any bug report. Thanks!

addpath(genpath(('./')));
clear
load('toy-example.mat')

%%pre-processing
train_data = [c1(:,1:100) c2(:,1:100) c3(:,1:100) c4(:,1:100)];
train_num = size(train_data,2);
nneighbors = round(train_num*0.0125);
DIST = distMat(train_data', train_data', 0) ;
DIST = DIST + max(DIST(:))*eye(train_num);
[~, IDX] = sort(DIST, 2);
S = zeros(train_num);
for i = 1:train_num
    S(i, IDX(i,1:nneighbors)) = DIST(i, IDX(i,1:nneighbors));
end
S = (S+S')/2;
dist = max(S(:));
S = full(S>0).*sparse(exp(-(S)./dist));
L = eye(train_num)-diag(sum(S).^(-0.5))*S*diag(sum(S).^(-0.5));
A = S>0;
clear data

%% plot 3D data
plot3(train_data(1,:),train_data(2,:),train_data(3,:), 'bo');
hold;
for i = 1:train_num
    idx = find(A(i,:) == 1);
    for j = 1:length(idx)
        plot3([train_data(1,i) train_data(1,idx(j))], [train_data(2,i) train_data(2,idx(j))],  [train_data(3,i) train_data(3,idx(j))],'g-');
    end
end

X = normc(train_data)';
data.train_data = X';
train_data = X';
sampleMean = mean(X,1);
XX = (X - repmat(sampleMean,size(X,1),1));

%%Random hyperplane
pc =  rand(3,2);
Y  = pc'*train_data;
show_codes('LSH', Y, train_num, L, A);

% %PCA hyperplane
% C = cov(XX);
% [pc, l] = eigs(C, 2);
% Y  = pc'*train_data;
% show_codes('PCAH', Y, train_num, L, A);

%%Spectral hyperplane
SHparam.nbits = 2;
SHparam = trainSH(data, SHparam);
[Nsamples Ndim] = size(X);
nbits = SHparam.nbits;
X = train_data'*SHparam.pc-repmat(SHparam.mn, [Nsamples 1]);
omega0=pi./(SHparam.mx-SHparam.mn);
omegas=SHparam.modes.*repmat(omega0, [nbits 1]);

Y = zeros([Nsamples nbits])';
for i=1:nbits
    omegai = repmat(omegas(i,:), [Nsamples 1]);
    ys = sin(X.*omegai+pi/2);
    yi = prod(ys,2);
    Y(i,:)=yi;    
end
show_codes('SH', Y, train_num, L, A);

%%ITQ
C = cov(XX);
[pc, l] = eigs(C, 2);
tempXX = XX*pc;
[C, R] = ITQ(tempXX,10);
Y = tempXX*R;
Y = Y';
show_codes('ITQ', Y, train_num, L, A);

%Shared subspace hyperplane
SSHparam.nbits = 2;
SSHparam.alpha = 1;
SSHparam.beta = 1;
SSHparam.gamma = 1e-1;
SSHparam.rdim = 2;% 

SSHparam.max_iter = 30;
SSHparam.tol = 1e-18;
SSHparam.useanchor = 0;
SSHparam.nn = 5;
data.S = S;

SSHparam = trainSSH(data, SSHparam);
Y = SSHparam.w'*train_data + SSHparam.b*ones(1,train_num);
show_codes('SSH', Y, train_num, L, A);



