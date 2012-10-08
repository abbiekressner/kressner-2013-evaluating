function [filelist,filenames] = getListOfCasesThatArentAlreadyDone(format,...
        pathToStart,pathToEnd)
    % Function that finds the cases in pathToStart that aren't in pathToEnd

if pathToStart(end)~='/'
	pathToStart=[pathToStart '/'];
end
if nargin>=3
	if pathToEnd(end)~='/'
		pathToEnd=[pathToEnd '/'];
	end
end
    
if strcmp(format,'wavToMat')
    startExt = '*.wav';
    endExt = '*.mat';
elseif strcmp(format,'matToMat')
    startExt = '*.mat';
    endExt = '*.mat';
elseif strcmp(format,'wavToMat_Dynastat')
	startExt = '*.wav';
	endExt = '*.mat';
else
    error('The format you entered is unspecified.');
end

    
    filelist = ls2list([pathToStart startExt]);
    filenames = cell(size(filelist));
    for ii = 1:length(filelist)
        ind = find(filelist{ii} == '/');
        if strcmp(format,'wavToMat')
            filenames{ii} = [filelist{ii}([ind(4)+1:ind(5)-1 ind(5)+1:ind(6)-1 ...
                ind(6)+1:ind(7)-1 ind(7)+1:end-4]) '.mat'];
        elseif strcmp(format,'matToMat')
            filenames{ii} = filelist{ii}(ind(end)+1:end);
		elseif strcmp(format,'wavToMat_Dynastat')
			filenames{ii} = filelist{ii}(ind(end)+1:end-4);
        end
    end

	if nargin>2
		% Get list of files from the end path
		alreadyexists = ls2list([pathToEnd endExt]);
		
		% Make alreadyexists a cell if there is only one file (ls2list returns a char)
		if ischar(alreadyexists) 
			alreadyexists = {alreadyexists};
		end

		% Get all the local filenames from the fullfile names
		alreadyexistsFilenames = cell(size(alreadyexists));
		for ii = 1:length(alreadyexists)
			ind = find(alreadyexists{ii} =='/');
			alreadyexistsFilenames{ii}=alreadyexists{ii}(ind(end)+1:end-4);
		end

		% Find the set in the starting path that is not in the ending path
		[filenames,keeps] = setdiff(filenames,alreadyexistsFilenames);
		filelist = filelist(keeps);
	end
end
