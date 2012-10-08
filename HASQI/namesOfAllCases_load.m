function allCaseStrs = namesOfAllCases_load(paths,searchPattern,debugMode)

	%% Check inputs {{{
	if nargin < 3
		debugMode = false;
	end
	if nargin < 2
		searchPattern = {'proc'};
	end
	if not(iscell(paths))
		paths = {paths};
	end
    removeTheseCases = {'sp05','sp10','sp15','sp20'}; % REMOVE THESE LIKE HU & LOIZOU
                                    % (see Loizou Textbook, Speech Enhancement 2007)
	% }}}

	%% Get the list for each element of the paths cell {{{
	allCaseStrs = cell(length(paths),1); % initialize
	for iter = 1:length(paths)	
		if paths{iter}(end)~='/'
			paths{iter} = [paths{iter} '/'];
		end
		allCaseStrs{iter} = getThem(paths{iter},searchPattern,removeTheseCases);
	end
	allCaseStrs = vertcat(allCaseStrs{:}); % convert from cell to mat
	% }}}

	%% Shorten the list if debugging and if not debugging, remove clean cases {{{
	if debugMode
		% just pick two random cases for testing
		allCaseStrs = allCaseStrs(ceil(length(allCaseStrs)*rand(1,2)));
	else % if not in debugMode, remove the clean cases
		for ss=[1:4 6:9 11:14 16:19]
			allCaseStrs(strcmp(['sp' sprintf('%02d',ss)],allCaseStrs))=[];
		end
	end
	% }}}

end % end of main function
	

%% Subfunction which actually gets the list {{{
function caseStrs = getThem(thepath,thepattern,removeTheseCases)
	for ss = 1:length(thepattern)
		caseStrs = dir([thepath thepattern{ss} '*']);
		caseStrs = struct2cell(caseStrs);
		caseStrs = caseStrs(1,:).'; % only take the filename (exclude date, filesize, ect)
	
		% drop the file extensions
		for ll = 1:length(caseStrs)
			[~,ind] = find(caseStrs{ll} == '.');
			caseStrs(ll) = {caseStrs{ll}(1:ind-1)};
		end

		% remove the specified cases
		for ii = 1:length(removeTheseCases)
			whichOnes = strfind(caseStrs,removeTheseCases{ii});
			caseStrs = caseStrs(cellfun(@isempty,whichOnes));
		end
	end
end
% }}}
