function [U] = compressITQ(X, ITQparam)
%
% code for converting data X to binary code C using ITQ
% Input:
%       X: n*d data matrix, n is number of images, d is dimension
%       bit: number of bits
% Output:      
%       C: n*bit binary code matrix
% 
% Yunchao Gong (yunchao@cs.unc.edu)
%


% center the data, VERY IMPORTANT for ITQ to work
sampleMean = ITQparam.sampleMean;
X = (X - repmat(sampleMean,size(X,1),1));
X = X * ITQparam.pc;
R = ITQparam.R;
X = X*R;
U = zeros(size(X));
U(X>=0) = 1;

