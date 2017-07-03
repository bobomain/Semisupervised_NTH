function [B,R] = ITQ(V, n_iter)
%
% main function for ITQ which finds a rotation of the PCA embedded data 
% Input:
%       V: n*c PCA embedded data, n is the number of images and c is the      n*c的PCA嵌入数据
%       code length
%       n_iter: max number of iterations, 50 is usually enough 最大迭代次数
% Output:
%       B: n*c binary matrix
%       R: the c*c rotation matrix found by ITQ 得到的c*c旋转矩阵
% Author:
%       Yunchao Gong (yunchao@cs.unc.edu)
% Publications:
%       Yunchao Gong and Svetlana Lazebnik. Iterative Quantization: A
%       Procrustes Approach to Learning Binary Codes. In CVPR 2011.
%

% initialize with a orthogonal random rotation
bit = size(V,2); %矩阵V的列数，PCA嵌入数据的编码长度值
R = randn(bit,bit); %旋转矩阵 初始化
[U11 S2 V2] = svd(R); %矩阵R的奇异值，U11是一个具有与数据之间最小投影误差方向向量构成的bit*bit矩阵，S2是bit*bit的特征值矩阵，只有对角线为非零元素；特征列向量
R = U11(:,1:bit); %对1到bit列对应所有行的值组成一个矩阵；矩阵切割

tic;
% ITQ to find optimal rotation 查找最优循环
for iter=0:n_iter
    Z = V * R;      
    UX = ones(size(Z,1),size(Z,2)).*-1; %全-1的矩阵，行为n，列为bit 此处为c
    UX(Z>=0) = 1;
    C = UX' * V;
    [UB,sigma,UA] = svd(C);    
    R = UA * UB';
end

tim = toc;
fprintf('ITQ : tic --toc : use time %15.5f.\n',tim);

% make B binary
B = UX;
B(B<0) = 0;









