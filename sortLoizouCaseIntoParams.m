function [aa,bb,cc,dd,howManyValsPerVariable] = sortLoizouCaseIntoParams(str,namingConvention)
	% sortLoizouCaseIntoParams is a function with determines the correct {{{
	% sorting information (i.e. which algorithm, which SNR level, which noise type,
	% and which sentence number) based on the given string
	%
	% Inputs:
	%	str- str is a cell of strings with each case in a row
	%	namingConvention- string which describes the naming convention 
	%		for str (RateFuncs is the default)
	%		Options are {RateFuncs,wav,individScores}
	%
	% Outputs:
	%	aa- identifies the algorithm for each of the strings in the cell str {1:16}
	%	bb- identifies the SNR level for each of the strings in the cell str {1:2}
	%	cc- identifies the noise type for each of the strings in the cell str {1:4}
	%	dd- identifies the sentence number for each of the strings in the 
	%		cell str {1:20} (RateFuncs or wav) or the talker number {1:4} (individScores)
	% }}}

if nargin < 2
	namingConvention = 'RateFuncs';
end

% Check inputs
if not(iscell(str))
	fprintf('Warning: The input should be a cell with a single case in each row.');
	str = {str};
end

%% Initialize the outputs {{{
aa = nan(size(str,1),1); % algorithm
bb = nan(size(str,1),1); % SNR
cc = nan(size(str,1),1); % noise type
dd = nan(size(str,1),1); % sentence number or talker number 
% }}}

%% Load the sorting info {{{
sortingInfo = load('sortingInfo.mat','sortingInfo');
sortingInfo = sortingInfo.sortingInfo;
% }}}

%% Figure out what the vector howManyValsPerVariable is {{{
howManyValsPerVariable = nan(1,4);
for col = 1:size(sortingInfo,2)
	searchForFirstEmptyCell = find(cellfun(@isempty,sortingInfo(:,col)),1);
	if isempty(searchForFirstEmptyCell)
		howManyValsPerVariable(col) =  size(sortingInfo,1) - 1; % subtract one since we don't count the reference case since those are removed eventually
	else
		howManyValsPerVariable(col) = searchForFirstEmptyCell - 2; % don't count cases referring to reference (subtract an extra 1)
	end
end
if strcmp(namingConvention,'RateFuncs') || strcmp(namingConvention,'wav') % {{{
	howManyValsPerVariable(4) = 20; % there are 20 sentences % }}}
elseif strcmp(namingConvention,'individScores') % {{{
	howManyValsPerVariable(4) = 4; % there are 4 talkers % }}}
end
%}}}

%% Load the lookup table for the case 'individScores' {{{
if strcmp(namingConvention,'individScores')
	variableLookupByExpAndCond = load('variableLookupByExpAndCond.mat','variableLookupByExpAndCond');
	variableLookupByExpAndCond = variableLookupByExpAndCond.variableLookupByExpAndCond;
end % }}}

%% Do the sorting for each string
for ii = 1:size(str,1)
	if strcmp(namingConvention,'RateFuncs') % {{{
		sp = strfind(str{ii},'sp');
		sn = strfind(str{ii},'sn');
		str_algo = str{ii}(6:sp-2);
		str_snr = str{ii}(sn:end);
		str_noise = str{ii}(sp+4:sn-1);
		dd(ii) = str2double(str{ii}(sp+2:sp+3)); % }}}
	elseif strcmp(namingConvention,'wav') % {{{
		underscores = strfind(str{ii},'_');
		if isempty(underscores)
			str_algo = 'clean';
			str_snr = 'none';
			str_noise = 'none';
		elseif length(underscores) == 2
			str_algo = 'noisy';
			str_snr = str{ii}(underscores(2)+1:end);
			str_noise = str{ii}(underscores(1)+1:underscores(2)-1);
		elseif length(underscores) >= 3
			str_algo = str{ii}(underscores(3)+1:end);
			str_snr = str{ii}(underscores(2)+1:underscores(3)-1);
			str_noise = str{ii}(underscores(1)+1:underscores(2)-1);
		end	
		dd(ii) = str2double(str{ii}(3:4)); % }}}
	elseif strcmp(namingConvention,'individScores') % {{{
		matchingRow = find(  eq(cell2mat(str(ii,1)),...
			cell2mat(variableLookupByExpAndCond(2:end,1))) & ...
			eq(cell2mat(str(ii,2)),...
			cell2mat(variableLookupByExpAndCond(2:end,2)))  ) + 1; % add one for the title row in variableLookup
		str_algo = variableLookupByExpAndCond{matchingRow,6};
		str_snr = variableLookupByExpAndCond{matchingRow,5};
		str_noise = variableLookupByExpAndCond{matchingRow,4};
		
		% Get talker number {{{
		if strcmp(str{ii,4},'m1')
			dd(ii) = 1;
		elseif strcmp(str{ii,4},'m2')
			dd(ii) = 2;
		elseif strcmp(str{ii,4},'f1')
			dd(ii) = 3;
		elseif strcmp(str{ii,4},'f2')
			dd(ii) = 4;
		end % }}}
	end % }}}
	
	% >> algorithm {{{
	errorMsg = ['"' str_algo '" did not match any of the algorithms.'];
	whichCol = 1;
	aa(ii) = findTheMatchingCase(str_algo,...
		whichCol,howManyValsPerVariable(1)+1,errorMsg);
	% }}}

	% >> SNR {{{
	errorMsg = ['"' str_snr '" did not match any of the SNR categories.'];
	whichCol = 2;
	bb(ii) = findTheMatchingCase(str_snr,...
		whichCol,howManyValsPerVariable(2)+1,errorMsg);
	% }}}

	% >> noise type {{{
	errorMsg = ['"' str_noise '" did not match any of the noise types.'];
	whichCol = 3;
	cc(ii) = findTheMatchingCase(str_noise,...
		whichCol,howManyValsPerVariable(3)+1,errorMsg);
	% }}}
end

%% Subfunction findTheMatchingCase {{{
function yy = findTheMatchingCase(string,whichCol,maxPossible,errorMsg)
	row = 1;
	yy = nan;
	if strcmp(string,'none'), yy=0; end; % for the clean case when there is no snr or noisetype
	while isnan(yy)
		if any(strcmp(string,sortingInfo{row,whichCol}))
			yy = row;
		else
			row = row + 1;
			if row > maxPossible
				error(errorMsg);
			end
		end
	end
end % end of subjection
% }}}

end % end of main function
