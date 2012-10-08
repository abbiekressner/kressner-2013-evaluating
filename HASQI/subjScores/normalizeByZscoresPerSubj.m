function scores = normalizeByZscoresPerSubj(scores,subject,experiment)
% the third input (experiment) is included so that it has the same call 
% format as the other normalization functions

	listOfSubjects = unique(subject);

	for ss = 1:length(listOfSubjects)
		logicalMask = (subject==listOfSubjects(ss));
		scores(logicalMask) = zscore(scores(logicalMask));
	end
