function [r,stde]=getCorrCoeffStdeOfLoizouStandard(funcHandle,trainingSetInd)

s=load('~/sym/HuLoizouSubj.mat');
if nargin<2
	metric=computeStandardmetricForLoizouData(funcHandle);
else
	metric=computeStandardmetricForLoizouData(funcHandle,trainingSetInd);
end

metric_subset=metric([1 2 4:15],:,:);
[r,stde]=pearson(metric_subset(:),s.subjRawNoNormalization_subset(:));
