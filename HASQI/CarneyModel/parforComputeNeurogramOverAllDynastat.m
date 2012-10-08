pathToSaveTo='~/Documents/MATLAB/Data/20110909_DynastatNeurograms79dB_8msWindows/';
dB=79; % this is what Hu and Loizou use in the subjective testing (Y. Hu and P. C. Loizou, “Subjective comparison and evaluation of speech enhancement algorithms,” Speech Communication, vol. 49, no. 7, pp. 588–601, Jul. 2007.)

overalltime=tic;
[filelist,filenames]=getListOfCasesThatArentAlreadyDone('wavToMat_Dynastat','~/sym/Dynastat/',pathToSaveTo);

matlabpool('open',4);
nfiles=length(filelist);

parfor ii=1:length(filelist)
	individtime=tic;
	computeNeurogram(filelist{ii},dB,pathToSaveTo);
	fprintf(['Completed %4.0f/' num2str(nfiles) ' (' secs2hms(toc(individtime)) ')\t' filelist{ii} '\n'],ii);
end

fprintf(['\n--> Total time: ' secs2hms(toc(overalltime))]);
[~,compname]=system('uname -n');
ind=strfind(compname,sprintf('\n'));
if any(ind)
	compname(ind)='';
end
send_mail('abbiekressner@gmail.com',['Job done on ' compname(1:end-1)],'Done computing neurograms.');
