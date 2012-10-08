function h=plotCxySubj(pathToCxy,pathToSubj,whichObjMeasure,handleToFit,h,color)
	
	%% Check inputs {{{
	if nargin<2
		pathToSubj=['~/sym/hasqiLoizouData/'...
			'subjective/subj_normalizeRawOvrlByZscoresPerSubjAndExp.mat'];
	end
	if isempty(pathToSubj)
		pathToSubj=['~/sym/hasqiLoizouData/'...
			'subjective/subj_normalizeRawOvrlByZscoresPerSubjAndExp.mat'];
	end
	if nargin<3
		whichObjMeasure='cxy';
	end
	if nargin<4
		handleToFit=@cxyToQnonlin_KatesModel;
	end
	if nargin<6
		color=[0 0 1];
	end
	% }}}

	%% Load data {{{
	subj=load(pathToSubj);
	obj=load(pathToCxy,whichObjMeasure);
	% }}}
	
	%% Do averaging over sentences if it hasn't already been done {{{
	if strcmp(whichObjMeasure,'cxy')
		obj.cxy=mean(obj.cxy,4);
	end
	% }}}
	
	%% Set the current figure % {{{
	if nargin<3 
		h=figure('color','white');
		hold on;
	else
		figure(h);
		hold on;
	end
	% }}}

	%% Plot the points {{{
	plot(obj.(whichObjMeasure)(:),subj.subj(:),'.','Color',color);
	% }}}
   
	%% Plot Kates's fit {{{
	x=linspace(0,1,100);
	Qnonlin=handleToFit(x);
	plot(x,Qnonlin,'y','linewidth',2);
	% }}}
	
	%% Format the figure {{{
	xlabel(whichObjMeasure,'fontsize',16);
	ind=find(pathToSubj=='/');
	string=pathToSubj(ind(end)+1:end);
	string(string=='_')=' ';
	ylabel(string,'fontsize',16);
	% }}}
