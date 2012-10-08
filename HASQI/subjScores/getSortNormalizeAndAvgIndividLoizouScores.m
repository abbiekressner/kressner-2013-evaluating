function subj = getSortNormalizeAndAvgIndividLoizouScores(normalizationMethod,subjTest,pathToXls)

	%% Check inputs and define variables based on normalizationMethod {{{
	if nargin < 3 % {{{
		pathToXls = ['/Users/abbiekre/Documents/MATLAB/Loizou/' ...
			'Hu_SubjListenerResults/individSubjectiveQualityScores.xls'];
	end % }}}
	if nargin < 2 % {{{
		subjTest = 3; % {1=sig, 2=bak, 3 = ovrl} NOTE: sig and bak contains 0s, which are not a choice, so you should deal with that in some way (exclude those scores perhaps??)
	end % }}}
	switch normalizationMethod
		case 1
			xlssheet = 'Raw-ratings';
			funcHandle = @normalizeByZscoresPerSubjAndExp;
			normalize = true;
		case 2
			xlssheet = 'Transformed-ratings';
			funcHandle = @normalizeToZeroAndOne;
			normalize = true;
		case 3
			xlssheet = 'Raw-ratings';
			funcHandle = @normalizeToZeroAndOne;
			normalize = true;
		case 4
			xlssheet = 'Raw-ratings';
			funcHandle = @normalizeByZscoresPerSubj;
			normalize = true;
		case 5
			xlssheet = 'Transformed-ratings';
			normalize = false;
		case 6
			xlssheet = 'Raw-ratings';
			normalize = false;
	end
	% }}}

	%% Load the scores {{{
	[~,~,xls] = xlsread(pathToXls,xlssheet);
	xls = xls(2:end,:); % get rid of title line
	scores = cell2mat(xls(:,subjTest+4)); % put the scores into a vector
		% add 4 since sig, bak, and ovrl are in cols 5:7
		%
	experimentNumber = cell2mat(xls(:,1));
	subjectNumber = cell2mat(xls(:,3));
	% }}}
	
	%% Get the sorting info {{{
	[algorithm,snr,noisetype,talker,howManyValsPerVariable] = sortLoizouCaseIntoParams(xls,'individScores');
	% }}}
	
	%% Throw out the "R" cases {{{
	scores(algorithm==16) = [];
	experimentNumber(algorithm==16) = [];
	subjectNumber(algorithm==16) = [];
	snr(algorithm==16) = [];
	noisetype(algorithm==16) = [];
	talker(algorithm==16) = [];
	algorithm(algorithm==16) = [];
	% }}}

	%% Call the appropriate function to normalize the scores {{{
	if normalize
		scores = funcHandle(scores,subjectNumber,experimentNumber);
	end
	% }}}
	
	%% Sort scores into the multi-dimensional subj matrix {{{
	subj = nan([howManyValsPerVariable max(subjectNumber) max(experimentNumber)]); 
	ind = sub2ind(size(subj),algorithm,snr,noisetype,talker,subjectNumber,experimentNumber);
	subj(ind) = scores; 
	% }}}

	%% Get rid of extra NaNs and average over talker, subject, and experiment {{{
	% The code in this section accomplishes the following, but about 2.3 times faster {{{
	%{
	mean = nan(size(subj,1),size(subj,2),size(subj,3));
	for ii = 1:size(subj,1),
		for jj = 1:size(subj,2),
			for kk = 1:size(subj,3),
				temp = reshape(subj(ii,jj,kk,:,:,:),1,[]);
				if isnan(temp(1))
					mean(ii,jj,kk) = mean(temp(length(temp)/2+1:end));
				else
					mean(ii,jj,kk) = mean(temp(1:length(temp)/2));
				end
			end
		end
	end
	%}
	% }}}
	A = size(subj,1);
	B = size(subj,2);
	C = size(subj,3);

	subj = reshape(subj,A,B,C,[]);
	subj = shiftdim(subj,3);
	subj = reshape(subj,[],1);
	subj(isnan(subj)) = [];
	subj = reshape(subj,[],A,B,C);
	subj = shiftdim(subj,1);
	subj = mean(subj,4);
	% }}}
