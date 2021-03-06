function resRev=revolution_test(WTrue,test_B,train_B,M,K,rev_paras)

%load trainset
Dhamm = hammingDistSNTH(test_B, train_B,M,K);
pos = rev_paras.pos;
[recall, precision,rate] = recall_precision(WTrue, Dhamm,3);
[rec, pre,ridus]= recall_precisionposridus(WTrue, Dhamm, pos); % recall VS. the number of retrieved sample
[mAp] = area_RP(recall, precision);
[mAp_top]=area_RP(rec(1:16,:),pre(1:16,:));
[mAp_pos] = area_RP(rec, pre);
resRev.recall = recall;
resRev.precision=precision;
resRev.rate=rate;
resRev.rec=rec;
resRev.pre=pre;
resRev.mAp_top = mAp_top;
resRev.mAp=mAp;
resRev.mAp_pos=mAp_pos;
resRev.ridus = ridus';
