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
function res = much_SNTH(X,R,M,K,paras)
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
    ITQparam.nbits = pdim;
    train_data = X';
    ITQparam =  trainPCAH(train_data, ITQparam);
    ITQparam = trainITQ(train_data, ITQparam);
    W(:, 1:pdim) = ITQparam.pcaW*ITQparam.r;
    W = W./sqrt(sum(sum((W'*X).^2))/(M*K*L));
end
initW = W;

% optimization of RaHH objective function
initH = sign(W'*X);
bsize = floor(N/5);
Wvec = reshape(W, L*M*K, 1);
[Wopt objs iter] = minimize(Wvec, 'obj_ph_SNTH', 200, X, R, M, K, paras);
W = reshape(Wopt, L, M*K);

res.Hc = W'*X;
%res.H = sign(res.Hc);
res.H = (res.Hc'>=0);
res.B = compactbit(res.Hc'>=0);
%res.H,res.B,
res.W = W;
res.origH = initH;
res.origW = initW;
end
