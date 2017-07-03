%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% multi-component hashing
% Input:
%   X: feature matrix L*N, L is dimension of feature, N is the number of
%   samples
%   R: relation matrix N*N
%   M: number of similarity components
%   K: number of hash bits of each similarity component
%   paras is a struct of parameters, including: 
%       alpha: scale factor of non-transitive similarity, default: 2.0/K
%       delta: translation factor of non-transitive similarity, default: 1.0
%       gamma1: weight of first regularizor
%       gamma2: weight of second regularizor
%       W: optional, pre-defined hash projection
% Output:
%   res.H: hash code matrix MK*N
%   res.W: hash projection L*MK 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = much(X,R,M,K,paras)
fprintf('X: %d*%d, R: %d*%d, M: %d, K: %d, edges: %d\n', size(X), size(R), M, K, full(sum(sum(abs(R)))));
[L N] = size(X),
H = zeros(M*K, N);
W = zeros(L, M*K);

% Initialization of W
if isfield(paras, 'W')
    W = paras.W;
    B= paras.B;
    W = W./sqrt(sum(sum((W'*X+B*ones(1,N)).^2))/(M*K*L));
else
    % initialize by ITQ
    pdim = min([L, M*K]);
    %根据lxl_ssh中的trainSH调用的PCA更改参数
    pca_options.ReducedDim=pdim;
    [pcs,I]=PCA(X',pca_options );
    V = X'*pcs;
    wr = eye(pdim);
    iter = 50;
    [h wr] = ITQ(V, iter);
    W(:, 1:pdim) = pcs*wr;
    if L < M*K
        W(:, (L+1):end) = W(:, randsample(pdim, M*K-L));
    end
    W = W./sqrt(sum(sum((W'*X).^2))/(M*K*L));
end
initW = W;

% optimization of RaHH objective function
initH = sign(W'*X);
bsize = floor(N/5);
Wvec = reshape(W, L*M*K, 1);
[Wopt objs iter] = minimize(Wvec, 'obj_ph', 200, X, R, M, K, paras);
W = reshape(Wopt, L, M*K);

res.Hc = W'*X; %M*K*N
%res.H = sign(res.Hc);
res.H = (res.Hc'>=0);
res.W = W;
res.origH = initH;
res.origW = initW;
end
