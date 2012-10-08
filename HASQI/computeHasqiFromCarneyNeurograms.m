function [Qnonlin,Qlin,HASQI,cxy,d1,d2] = computeHasqiFromCarneyNeurograms(pathToNeurograms,debugMode,verbose)
	% computeHasqiFromCarneyNeurograms computes the Qnonlin, Qlin, and HASQI values {{{
	% for each of the wav files from the Dynastat/Hu/Loizou dataset
	%
	% Inputs:
	%
	% Outputs:
	%	Qnonlin	Matrix (algorithms by snr by noisetype by sentence)
	%							Contains the sorted Qnonlin values for
	%							each of the wav files
	%
	%	Qlin	Matrix (algorithms by snr by noisetype by sentence)
	%							Contains the sorted Qlin values for
	%							each of the wav files
	%
	%	HASQI	Matrix (algorithms by snr by noisetype by sentence)
	%							Contains the sorted HASQI values for 
	%							each of the wav files
	% }}}

try

%% Check inputs {{{
	if nargin < 3
		verbose=true;
	end
	if nargin < 2
		debugMode = false;
	end
	if pathToNeurograms(end)~='/'
		pathToNeurograms = [pathToNeurograms '/'];
	end
% }}}

if verbose, totalruntime=tic; end;

%% Get the filename of each wav file and identify the respective conditions {{{
namesOfAllCases = namesOfAllCases_load(pathToNeurograms,{'*.mat'},debugMode);
if debugMode % {{{
	namesOfAllCases = namesOfAllCases %#ok disp the test cases to the command window
end % }}}
[algorithm,snr,noisetype,sentnumber,maxSizeInfo]=...
	sortLoizouCaseIntoParams(namesOfAllCases,'wav');
% }}}

%% Drop the cases from the list that aren't used in the corr analysis {{{
% clean cases
namesOfAllCases=namesOfAllCases(algorithm~=16);
snr=snr(algorithm~=16);
noisetype=noisetype(algorithm~=16);
sentnumber=sentnumber(algorithm~=16);
algorithm=algorithm(algorithm~=16);

% "lap" cases
namesOfAllCases=namesOfAllCases(algorithm~=3);
snr=snr(algorithm~=3);
noisetype=noisetype(algorithm~=3);
sentnumber=sentnumber(algorithm~=3);
algorithm=algorithm(algorithm~=3);
% }}}

%% Initialize all the unsorted versions of the outputs % {{{
unsortedQnonlin = nan(length(namesOfAllCases),1);
unsortedQlin = nan(length(namesOfAllCases),1);
unsortedHASQI = nan(length(namesOfAllCases),1);
unsortedcxy=nan(length(namesOfAllCases),1);
unsortedd1=nan(length(namesOfAllCases),1);
unsortedd2=nan(length(namesOfAllCases),1);
% }}}

%% Run through each case and compute the outputs % {{{
allTheSentNumbers=unique(sentnumber);
for ss=1:length(allTheSentNumbers)
	if verbose 
		fprintf(['\n--> Starting sp%02.0f (' datestr(now) ')' '\n'],allTheSentNumbers(ss));
		startingsp=tic;
	end
	ref=load([pathToNeurograms sprintf('sp%02.0f.mat',allTheSentNumbers(ss))]);
	ref=ref.neurogram;
	theCorrespondingIndices=find(sentnumber==allTheSentNumbers(ss));
	theCorrespondingNamesOfTheCases=namesOfAllCases(theCorrespondingIndices);
	for nn=1:length(theCorrespondingNamesOfTheCases)
		% Load the test signal
		testsignal=load([pathToNeurograms theCorrespondingNamesOfTheCases{nn}]);
		
		% Run through the distance calculations
		[unsortedQnonlin(theCorrespondingIndices(nn)),...
			unsortedQlin(theCorrespondingIndices(nn)),...
			unsortedHASQI(theCorrespondingIndices(nn)),...
			unsortedcxy(theCorrespondingIndices(nn)),...
			unsortedd1(theCorrespondingIndices(nn)),...
			unsortedd2(theCorrespondingIndices(nn))]=...
			hasqiWithCarneyModel(ref,testsignal.neurogram);
	end
	if verbose, fprintf(['\tRuntime: ' secs2hms(toc(startingsp)) '\n']); end;
end
% }}} 

%% Initialize the sorted outputs {{{
Qnonlin=nan(maxSizeInfo);
Qlin=nan(maxSizeInfo);
HASQI=nan(maxSizeInfo);
cxy=nan(maxSizeInfo);
d1=nan(maxSizeInfo);
d2=nan(maxSizeInfo);
% }}} 

%% Sort all the outputs {{{
ind=sub2ind(maxSizeInfo,algorithm,snr,noisetype,sentnumber);
Qnonlin(ind)=unsortedQnonlin;
Qlin(ind)=unsortedQlin;
HASQI(ind)=unsortedHASQI;
cxy(ind)=unsortedcxy;
d1(ind)=unsortedd1;
d2(ind)=unsortedd2;
% }}}

%% Remove the Nans {{{
Qnonlin(:,:,:,5:5:20) = [];
Qlin(:,:,:,5:5:20) = [];
HASQI(:,:,:,5:5:20) = [];
cxy(:,:,:,5:5:20) = [];
d1(:,:,:,5:5:20) = [];
d2(:,:,:,5:5:20) = [];
% }}}

%% Average over sentences {{{
% Qnonlin = mean(Qnonlin,4);
% Qlin = mean(Qlin,4);
% HASQI = mean(HASQI,4);
% cxy = mean(cxy,4);
% d1= mean(cxy,4);
% d2 = mean(cxy,4);
% }}}

%% Send an email upon completion {{{
if verbose, fprintf(['\n Total runtime: ' secs2hms(toc(totalruntime)) '\n']); end;
if not(debugMode)
	[~,computeridentifier] = system('hostname');
	send_mail('abbiekressner+matlab@gmail.com','Job finished.',computeridentifier);
end
% }}}
catch exception % {{{
	if debugMode == false
		pathToSave = false; %#ok (pathToSave is used by abbieCatchScript) note that false means don't save
		abbieCatchScript;
	else
		rethrow(exception);
	end
end
% }}}

end % function end
