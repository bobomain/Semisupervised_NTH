function [recall, precision,rate] = recall_precision(Wtrue, Dhat,max_hamm)
%
% Input:
%    Wtrue = true neighbors [Ntest * Ndataset], can be a full matrix NxN
%    Dhat  = estimated distances
%
% Output:
%
%                  exp. # of good pairs inside hamming ball of radius <= (n-1)
%  precision(n) = --------------------------------------------------------------
%                  exp. # of total pairs inside hamming ball of radius <= (n-1)
%
%               exp. # of good pairs inside hamming ball of radius <= (n-1)
%  recall(n) = --------------------------------------------------------------
%                          exp. # of total good pairs 

if(nargin < 3)
    max_hamm = max(Dhat(:));
end
hamm_thresh = min(7,max_hamm);
[Ntest, Ntrain] = size(Wtrue);
total_good_pairs = sum(Wtrue(:));
% find pairs with similar codes
%precision = zeros(max_hamm,1);
%recall = zeros(max_hamm,1);
precision = zeros(hamm_thresh,1);
recall = zeros(hamm_thresh,1);
rate = zeros(hamm_thresh,1);

for n = 1:length(precision)
    j = (Dhat<=((n-1)+0.00001));
    
    %exp. # of good pairs that have exactly the same code
    retrieved_good_pairs = sum(Wtrue(j));
    
    % exp. # of total pairs that have exactly the same code
    retrieved_pairs = sum(j(:));

    precision(n) = retrieved_good_pairs/(retrieved_pairs+eps);
    recall(n)= retrieved_good_pairs/total_good_pairs;
    rate(n)= retrieved_pairs/(Ntest*Ntrain);
end
%precision,recall,retrieved_pairs,retrieved_pairs+eps
