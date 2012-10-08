function neurogram=computeNeurogram(stimuli,desired_dB,windowlength,pathToSaveNeurogram)

	% FUNCTION neurogram=computeNeurogram(stimuli,desired_dB,windowlength,pathToSaveNeurogram)
	%
	% stimuli				string to the wav file or a vector containing the stimuli
	% desired_dB			scalar which specifies the desired SPL of the stimuli in dB
	% windowlength			scalar specifying the window length in milliseconds
	% pathToSaveNeurogram	string which specifies where to save the neurogram (optional)
	
%% Specify model parameters {{{
CF = logspace(log10(0.18e3),log10(7.04e3),128);
modelFs = 100e3; % model firing rate in Hz
cohc = 1.0; % 1.0 is normal OHC function
cihc = 1.0; % 1.0 is normal IHC function
interRepTime = 0; % percent of stimulation duration to wait between reps
nrep = 1; % number of reps
SR = [0.1,5,50];  % spontaneous firing rate in Hz
SRweights = [0.2 0.2 0.6]; % weights for averaging over SRs; NOTE adjust for impaired case see Zilany_2007_Predictions of Speech Intelligibility, p. 482
% }}}

%% Load the sentence, resample it, and convert amplitude {{{
if ischar(stimuli)
	if nargin>=4
		indOfSlashes=findstr(stimuli,'/');
		pathToSaveNeurogram=[pathToSaveNeurogram stimuli(indOfSlashes(end):end-4)];
	end
	[stimuli,origFs]=wavread(stimuli);
	stimuli=resample(stimuli,modelFs,origFs);
	stimuli=convertToPascals(stimuli,desired_dB);
end
% }}}

%% Initialize the output vars {{{
stimT=length(stimuli)*(1/modelFs);
numRows=round(stimT*(1+interRepTime)*modelFs); % when interRepTime=0, numRow=length(stimuli)
rates=nan(numRows,length(CF),length(SR));
% }}}

% Get each of the 3D rates matrices (time by CF by SR) {{{
for cf = 1:length(CF) % loop through characteristic freqs
	for sr = 1:length(SR) % loop through spontaneous firing rates
		[~,~,~,~,~,~,~,rates(:,cf,sr),~] = zbcatmodel(...
			stimuli(:).',...
			CF(cf),nrep,1/modelFs,stimT.*(1+interRepTime),cohc,cihc,SR(sr));
	end
end
% }}}

% Average across spontaneous rates to get a 2D rate matrix (time by CF) {{{
rates=SRweights(1).*rates(:,:,1)+...
	SRweights(2).*rates(:,:,2)+SRweights(3).*rates(:,:,3);
% }}}

% Set up the window for averaging {{{
nwin=round((windowlength*1e-3)*modelFs); % segment size in samples (Bruce lab uses 16ms Hamming windows w 50% overlap - email communication with R.A. Ibrahim on 9 June 2011), Kates uses a 8ms window for his model
if (nwin-2*floor(nwin/2))>0 % if it's odd
	nwin=nwin+1;
end
window=hamming(nwin).';
% }}}

% Compute the number of frames (aka segments) and initialize storage {{{
npts=size(rates,1);
n=-nwin/2+1; % starting point for 50% overlap
nseg=1; % mark the first segment
while (n+nwin/2)<=npts % if another segment can fit
	nseg=nseg+1; % mark another segment
	n=n+nwin/2; % and advance n
end
clear('n'); % don't need n
neurogram=zeros(nseg,size(rates,2)); % initialize
% }}}

% Compute the averages {{{
for nn=1:nseg
	nstart=(nn-2)*(nwin/2)+1;
	winstart=1;
	nstop=nstart+nwin-1;
	winstop=nwin;
	if nstart<1
		nstart=1;
		winstart=nwin-length(nstart:nstop)+1;
	elseif nstop>npts
		nstop=npts;
		winstop=length(nstart:nstop);
	end
	neurogram(nn,:)=window(winstart:winstop)*...
		rates(nstart:nstop,:)./sum(window(winstart:winstop));
end
% }}}

%% Save the neurogram if the path is specified {{{
if nargin>=4
	save(pathToSaveNeurogram,'neurogram');
end
% }}}
