
function [recall, precision] = recall_precisionpos(Wtrue, Dhat, pos)
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
%                  exp. # of good pairs inside hamming ball of radius <= (n-1)
%  recall(n) = --------------------------------------------------------------
%                          exp. # of total good pairs 

grid = pos;
SortedD=Dhat;
for i=1:size(Dhat,1)
    [a,b] = sort(Dhat(i,:),'ascend');
    Wtrue(i,:) = Wtrue(i,b);
end
total_good_pairs = sum(Wtrue(:));
precision = zeros(length(grid),1);
recall = zeros(length(grid),1);
for i=1:length(grid)
    g = grid(i);
    retrieved_good_pairs = sum(sum(Wtrue(:,1:g)));
    [row, col] = size(Wtrue(:,1:g));
    total_pairs = row*col;
    recall(i) = retrieved_good_pairs/total_good_pairs;
    precision(i) = retrieved_good_pairs/total_pairs;
end

