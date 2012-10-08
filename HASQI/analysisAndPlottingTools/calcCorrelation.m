function [r,stderror] = calcCorrelation(pathToObj,pathToSubj,whichObjMeasure)

	if nargin < 3
		whichObjMeasure = 'hasqi';
	end
	if isempty(pathToObj)
		pathToObj = '~/sym/QnonlinQlinHASQI_resampTo16k.mat';
	end
	if nargin<2
		pathToSubj=['~/sym/hasqiLoizouData/'...
			'subjective/subj_normalizeRawOvrlByZscoresPerSubjAndExp.mat'];
	end
	if isempty(pathToSubj)
		pathToSubj=['~/sym/hasqiLoizouData/'...
			'subjective/subj_normalizeRawOvrlByZscoresPerSubjAndExp.mat'];
	end

	%% Load data {{{
	subj = load(pathToSubj);
	obj = load(pathToObj,whichObjMeasure);
	% }}}

	%% Do averaging over sentences if it hasn't already been done {{{
	if strcmp(whichObjMeasure,'cxy')
		obj.cxy=mean(obj.cxy,4);
	end
	% }}}
	
	[r,stderror] = pearson(obj.(whichObjMeasure)(:),subj.subj(:));
