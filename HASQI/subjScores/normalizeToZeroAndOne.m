function scores = normalizeToZeroAndOne(scores,subject,experiment)

	if iscell(scores)
		scores=cell2mat(scores);
	end
	if iscell(subject)
		subject=cell2mat(subject);
	end
	if iscell(experiment)
		experiment=cell2mat(experiment);
	end

	listOfSubjects = unique(subject);
	listOfExperiments = unique(experiment);

	for ss = 1:length(listOfSubjects)
		for ee = 1:length(listOfExperiments)
			logicalMask = (subject==listOfSubjects(ss))&(experiment==listOfExperiments(ee));
			scores(logicalMask) = scores(logicalMask) - min(scores(logicalMask)); % subtract the minimum
			scores(logicalMask) = scores(logicalMask)/max(scores(logicalMask)); % normalize to one
		end
	end


%{ 
% old method	
	indOfNonnan = not(isnan(individScores));
	[~,~,~,subject,~] = ind2sub(size(individScores),indOfNonnan);
	for ii = 1:size(individScores,4)
		whichInds = find( subject == ii );
		x = individScores(indOfNonnan(whichInds)); % for ease of reading, temporarily store the scores
		x = x - min(x(:)); % subtract out the subject's lowest rating
		x = x/max(x(:)); % divide by the largest number
		individScores(indOfNonnan(whichInds)) = x;
	end

%}
