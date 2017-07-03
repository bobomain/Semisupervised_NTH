function [U] = compressSH(X,SHparam)
%X :N*d
%nbits:hash coding k
%U:N*k

[Nsamples Ndim] = size(X);
nbits = SHparam.nbits;

X = X*SHparam.pc;
X = X-repmat(SHparam.mn, [Nsamples 1]);
omega0=pi./(SHparam.mx-SHparam.mn);
omegas=SHparam.modes.*repmat(omega0, [nbits 1]); %mode即是k

U = zeros([Nsamples nbits]);
for i=1:nbits
    omegai = repmat(omegas(i,:), [Nsamples 1]);
    ys = sin(X.*omegai+pi/2);
    yi = prod(ys,2); %计算矩阵ys 沿行方向的连乘积，返回到yi中，两维的连乘
    U(:,i)=yi;    
end
U=(U>0);
