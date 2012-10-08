function spearman=getSpearmanOfLoizouStandard(funcHandle)

s=load('~/sym/HuLoizouSubj.mat');

metric=computeStandardmetricForLoizouData(funcHandle);
metric_subset=metric([1 2 4:15],:,:);
spearman=corr(metric_subset(:),s.subjRawNoNormalization_subset(:),...
	'type','Spearman');
