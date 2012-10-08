function scores = normalizeByZscoresPerSubjAndExp(scores,subject,experiment)


	listOfSubjects = unique(subject);
	listOfExperiments = unique(experiment);

	for ss = 1:length(listOfSubjects)
		for ee = 1:length(listOfExperiments)
			logicalMask = (subject==listOfSubjects(ss))&(experiment==listOfExperiments(ee));
			scores(logicalMask) = zscore(scores(logicalMask));
		end
	end
	
	
	
%{ 
% Code for old method	
	indOfNonnan = not(isnan(individScores));
	[~,~,~,subject,session] = ind2sub(size(individScores),indOfNonnan);
	for ii = 1:size(individScores,4)
		for jj = 1:size(individScores,5)
			individScores(indOfNonnan( (subject==ii)&(session==jj) )) = ...
				zscore(individScores(indOfNonnan( (subject==ii)&(session==jj) )));
		end
	end
%}
