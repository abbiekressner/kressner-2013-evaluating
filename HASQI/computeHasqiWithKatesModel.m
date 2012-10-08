function [Qnonlin,Qlin,HASQI,cxy,d1,d2] = computeHasqiWithKatesModel(...
		pathToDynastat,pathToNoizeus,resampIfNecessary,debugMode,verbose)

try

%% Check inputs {{{
	if nargin < 5
		verbose = true;
	end
	if nargin < 4
		debugMode = false;
	end
	if nargin < 3
		resampIfNecessary = true;
	end
	if nargin < 2
		pathToNoizeus='~/sym/noizeus/';
	end
	if nargin < 1
		pathToDynastat='~/sym/Dynastat';
	end
	if pathToDynastat(end)~='/'
		pathToDynastat = [pathToDynastat '/'];
	end
	if pathToNoizeus(end)~='/'
		pathToNoizeus = [pathToNoizeus '/'];
	end
% }}}

if verbose, totalruntime=tic; lastPrintedProgress=0; end; % initialize

%% Get the filename of each wav file and identify the respective conditions {{{
namesOfAllCases = namesOfAllCases_load(pathToDynastat,{'*.wav'},debugMode);
numberOfCasesBeforeNoizeus = length(namesOfAllCases); 
	% the first half will be in pathToDynastat; 2nd half in pathToNoizeus
namesOfAllCases = [namesOfAllCases; namesOfControlCases_load];
if debugMode % {{{
	namesOfAllCases = namesOfAllCases(1:3) %#ok disp the test cases to the command window
end % }}}
[algorithm,snr,noisetype,sentnumber,maxSizeInfo] = sortLoizouCaseIntoParams(namesOfAllCases,'wav');
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
hearingThresholds = zeros(1,6); % normal hearing
delayEqualization = 1; % 1 = delay input to match output timing in each freq band
for ss = 1:length(namesOfAllCases)

	if verbose
		newProgressEstimate=round((ss/length(namesOfAllCases))*100);
		if newProgressEstimate==(lastPrintedProgress+5)
			fprintf(['\t%1.0f%% done (' datestr(now) ')' '\n'],newProgressEstimate);
			lastPrintedProgress=newProgressEstimate;
		end
	end
	x = wavread([pathToDynastat 'sp' sprintf('%02.0f',sentnumber(ss))]);
	% Define the appropriate path {{{
	if ss <= numberOfCasesBeforeNoizeus
		path = pathToDynastat;
	else
		path = pathToNoizeus;
	end % }}}
	[y,fs_orig] = wavread([path namesOfAllCases{ss}]);

	%% Set fsQualmetric and do the necessary resampling % {{{
	fsQualmetric = 16e3; % default sampling frequency according to Kates' original Qual_metric code
	if resampIfNecessary && (fsQualmetric~=fs_orig)
		x = resample(x,fsQualmetric,fs_orig);
		y = resample(y,fsQualmetric,fs_orig);
	elseif not(resampIfNecessary)
		fsQualmetric = fs_orig;
	end % }}}

	[unsortedQnonlin(ss),unsortedQlin(ss),unsortedHASQI(ss),...
		unsortedcxy(ss),unsortedd1(ss),unsortedd2(ss)]=...
		Qual_metric(x,y,hearingThresholds,delayEqualization,fsQualmetric);
end
% }}} 

%% Initialize the sorted outputs {{{
Qnonlin = nan(maxSizeInfo);
Qlin = nan(maxSizeInfo);
HASQI = nan(maxSizeInfo);
cxy=nan(maxSizeInfo);
d1=nan(maxSizeInfo);
d2=nan(maxSizeInfo);
% }}} 

%% Sort all the outputs {{{
ind = sub2ind(maxSizeInfo,algorithm,snr,noisetype,sentnumber);
Qnonlin(ind) = unsortedQnonlin;
Qlin(ind) = unsortedQlin;
HASQI(ind) = unsortedHASQI;
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
% d1 = mean(d1,4);
% d2 = mean(d2,4);
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
