% Wrapper function to send computeQualmetricForLoizouData.m

debugMode = false; % if true, change the number of workers to a number less than your test size
resamp = true;
whichFunction = @Qual_metric; % FIXME depending on function
whichConfig = 'local';
minNumWorkers = 4;
maxNumWorkers = 4;

if strcmp(whichConfig,'local') % {{{
    pathToDynastat = '~/sym/Dynastat/';
	pathToNoizeus = '~/sym/noizeus/';
	pathToCarneyModel = '/Users/abbiekre/Documents/MATLAB/CarneyModels/Bruce01_zbcatmodel2007v2/';
elseif strcmp(whichConfig,'NeuroCluster')
    pathToDynastat = '/mnt/data/akressner/LoizouWavFiles/';
	pathToNoizeus = '/mnt/data/akressner/Noizeus/';
	pathToCarneyModel = '/mnt/data/akressner/Bruce01_zbcatmodel2007v2/';
else 
    error('You have not specified a valid configuration.');
end % }}}
funcInputs = {pathToDynastat,pathToNoizeus,resamp,debugMode,whichFunction};
numberOfOutputs = 4;
theFileDeps = [getFileDependencies('computeQualmetricForLoizouData');...
	'~/sym/sortingInfo.mat';...
	getFileDependencies(['/Users/abbiekre/Documents/MATLAB/ObjectiveMeasures/HASQI/'...
	'Kates/Qual_metric'])]; % FIXME depending on function
thePathDeps = {pathToDynastat;pathToNoizeus;pathToCarneyModel}; % just include Carney model either way

sch = findResource('scheduler','Configuration',whichConfig);
job = createMatlabPoolJob(sch);
set(job,'MinimumNumberOfWorkers',minNumWorkers);
set(job,'MaximumNumberOfWorkers',maxNumWorkers);
set(job,'FileDependencies',theFileDeps);
set(job,'PathDependencies',thePathDeps);
task = createTask(job, @computeQualmetricForLoizouData, ...
    numberOfOutputs, funcInputs, ...
    'CaptureCommandWindowOutput', true);
submit(job);

if debugMode
	wait(job);
	system('say job finished');
end


% RUN THE FOLLOWING CODE AFTER COMPLETION ... 
%{
whereToSave = '';

out = getAllOutputArguments(job);
save([whereToSave 'out.mat']);

destroy(j);
%}
