function metric = computeStandardmetricForLoizouData(funcHandle,pathToDynastat,debugMode,trainingSetInd)

try

%% Check inputs {{{
	if nargin < 3
		debugMode=false;
	end
	if nargin < 2
		pathToDynastat='~/sym/Dynastat/';
	end
	if pathToDynastat(end)~='/'
		pathToDynastat = [pathToDynastat '/'];
	end
% }}}

%% Get the filename of each wav file and identify the respective conditions {{{
namesOfAllCases = namesOfAllCases_load(pathToDynastat,{'*.wav'},debugMode);
if debugMode % {{{
	namesOfAllCases = namesOfAllCases(1:3) %#ok disp the test cases to the command window
end % }}}
[algorithm,snr,noisetype,sentnumber,maxSizeInfo] = sortLoizouCaseIntoParams(namesOfAllCases,'wav');
% }}}

%% Drop the sentences in the training set {{{
if nargin>=4
	% Correct the indices to account for the fact that I later drop 5:5:20
	transformedTrainingSetInd=trainingSetInd;
	for ii=1:length(trainingSetInd)
		if (transformedTrainingSetInd(ii)>=5 & transformedTrainingSetInd(ii)<=8)
			transformedTrainingSetInd(ii)=transformedTrainingSetInd(ii)+1;
		elseif (transformedTrainingSetInd(ii)>=9 & transformedTrainingSetInd(ii)<=12)
			transformedTrainingSetInd(ii)=transformedTrainingSetInd(ii)+2;
		elseif (transformedTrainingSetInd(ii)>=13 & transformedTrainingSetInd(ii)<=16)
			transformedTrainingSetInd(ii)=transformedTrainingSetInd(ii)+3;
		end
	end
	% Drop the appropriate sentences from the list of wav files to run
	whichOnesAreTheTrainingSet=ismember(sentnumber,transformedTrainingSetInd);
	namesOfAllCases(whichOnesAreTheTrainingSet)=[];
	algorithm(whichOnesAreTheTrainingSet)=[];
	snr(whichOnesAreTheTrainingSet)=[];
	noisetype(whichOnesAreTheTrainingSet)=[];
	sentnumber(whichOnesAreTheTrainingSet)=[];
end
% }}}

%% Initialize all the unsorted versions of the outputs % {{{
unsortedmetric=nan(length(namesOfAllCases),1);
% }}}

%% Run through each case and compute the output % {{{
for ss = 1:length(namesOfAllCases)
	x = [pathToDynastat 'sp' sprintf('%02.0f',sentnumber(ss))];
	y=[pathToDynastat namesOfAllCases{ss}];
	unsortedmetric(ss)=funcHandle(x,y);
end
% }}} 

%% Initialize the sorted output {{{
metric=nan(maxSizeInfo);
% }}} 

%% Sort all the outputs {{{
ind = sub2ind(maxSizeInfo,algorithm,snr,noisetype,sentnumber);
metric(ind) = unsortedmetric;
% }}}

%% Remove the Nans {{{
metric(:,:,:,5:5:20) = [];
% }}}

%% Remove training set if appropriate {{{
if nargin>=4
	metric(:,:,:,trainingSetInd) = [];
end
% }}}

%% Average over sentences {{{
metric = mean(metric,4);
% }}}

catch errorInfo % {{{
	if debugMode == false
		pathToSave = false; %#ok (pathToSave is used by abbieCatchScript) note that false means don't save
		abbieCatchScript;
	else
		rethrow(exception);
	end
end
% }}}

end % function end
