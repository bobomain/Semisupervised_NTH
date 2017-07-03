function D = distMat(fea_a,fea_b,bSqrt)
%EUDIST2 Efficiently Compute the Euclidean Distance Matrix by Exploring the
%Matlab matrix operations.
%
%   D = EuDist(fea_a,fea_b)
%   fea_a:    nSample_a * nFeature
%   fea_b:    nSample_b * nFeature
%   D:      nSample_a * nSample_a
%       or  nSample_a * nSample_b
%
%    Examples:
%
%       a = rand(500,10);
%       b = rand(1000,10);
%
%       A = EuDist2(a); % A: 500*500
%       D = EuDist2(a,b); % D: 500*1000
%
%   version 2.1 --November/2011
%   version 2.0 --May/2009
%   version 1.0 --November/2005
%
%   Written by Deng Cai (dengcai AT gmail.com)

% if bSqrt is not given,bSqrt is seted to 1
if ~exist('bSqrt','var')
    bSqrt = 1;
end

if (~exist('fea_b','var')) || isempty(fea_b)
    aa = sum(fea_a.*fea_a,2);
    ab = fea_a*fea_a';
    
    if issparse(aa)
        aa = full(aa);
    end
    
    D = bsxfun(@plus,aa,aa') - 2*ab;
    D(D<0) = 0;
    if bSqrt
        D = sqrt(D);
    end
    D = max(D,D');
else
    aa = sum(fea_a.*fea_a,2); %矩阵横向相加，得列向量
    
    bb = sum(fea_b.*fea_b,2);
    ab = fea_a*fea_b';
  %  fea_a,aa,bb,ab,
    if issparse(aa)
        aa = full(aa); %把稀疏矩阵转化成全矩阵
        bb = full(bb);
    end

    D = bsxfun(@plus,aa,bb')- 2*ab;
    D(D<0) = 0;
    if bSqrt==1
        D = sqrt(D);
    end
    if bSqrt == 2
	D=sqrt(sqrt(D));
    end
end
