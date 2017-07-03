function resRev=revolution_formal(WTrue,test_B,train_B,rev_paras)

%load trainset
Dhamm = hammingDist(test_B, train_B);
[~, rank] = sort(Dhamm, 2, 'ascend');
pos = rev_paras.pos;
[recall, precision, ~] = recall_precision(WTrue, Dhamm,3);
[rec, pre,ridus]= recall_precisionposridus(WTrue, Dhamm, pos); % recall VS. the number of retrieved sample
[mAp] = area_RP(recall, precision);
[mAp_pos] = area_RP(rec, pre);
resRev.recall = recall;
resRev.precision=precision;
resRev.rec=rec;
resRev.pre=pre;
resRev.mAp=mAp;
resRev.mAp_pos=mAp_pos;
resRev.ridus = ridus';
