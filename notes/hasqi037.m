% Note: this is with MOS (hasqi034 is similar, but with transformed scores)

retrain=true;
computeLoizou=false;
savethemat=true;
rechoosetrainingset=false;
pathToSave='~/Documents/MATLAB/Data/20120203_YandYhat/vars.mat';
pathToYhat='~/Documents/MATLAB/Data/20120129_YandYhat/vars3.mat';
whichcase=1;

switch whichcase
	case 1 % like Kates
		train_a4=false;
		lower_bound=[];
		upper_bound=[Inf Inf Inf 0 0];
	case 2 % keep a_4=1 restriction but remove other
		train_a4=false;
		lower_bound=[];
		upper_bound=[];
	case 3 % unrestricted
		train_a4=true;
		lower_bound=[];
		upper_bound=[];
end


%% Define Objective measures {{{
labels={'HASQI','tHASQI','PESQ','LLR','fwsegSNR (k=13)',...
	'fwsegSNR (k=25)','CEP','WSS','IS','segSNR'};
funcHandles={@pesq,@comp_llr,@comp_fwseg_k13,@comp_fwseg,...
	@comp_cep,@comp_wss,@comp_is,@comp_snr};
% }}}

%% Set the path {{{
addpath('~/Documents/MATLAB/ObjectiveMeasures/');
addpath(genpath('~/Documents/MATLAB/Loizou/TextbookDatabase/MATLAB_code/'));
addpaths_hasqi
% }}}

%% Load the data {{{
load('~/sym/HuLoizouSubj.mat');
subj_mos=subjRawNoNormalization_subset;
load('~/sym/HuLoizouSubj_zeroToOne.mat');
subj_kates=zeroToOneScores_subset;
load('/Users/abbiekre/Documents/MATLAB/Data/20111014_HasqiWithKatesAddLogToLinForQlin/results.mat');
if ~computeLoizou
	load(pathToYhat);
end
% }}}

%% Set up anonymous functions for training {{{
subset=@(mat) mat([1 2 4:end],:,:,:);
if rechoosetrainingset
	trainingSentInd=randsample(16,8).'; % sentences in the training set
	testingSentInd=setdiff(1:16,trainingSentInd); % sentences in the testing set
else
	trainingSentInd=[3 5 6 7 8 11 14 16];
	testingSentInd=[1 2 4 9 10 12 13 15];
end
grabTraining=@(mat) mat(:,:,:,trainingSentInd);
grabTesting=@(mat) mat(:,:,:,testingSentInd);
trainingSet=@(mat) grabTraining(subset(mat));
testingSet=@(mat) grabTesting(subset(mat));
makeIntoColumn=@(mat) reshape(mat,[],1);
meanIntoColumn=@(x) makeIntoColumn(mean(x,4));
% }}}

%% Training {{{
if retrain 
	if train_a4
		myfun=@(a,x) (a(1)+a(2)*x(:,1)+a(3)*(x(:,1).^2)).*...
			(a(4)+a(5)*x(:,2)+a(6)*x(:,3));
	else
		myfun=@(a,x) (a(1)+a(2)*x(:,1)+a(3)*(x(:,1).^2)).*...
			(1+a(4)*x(:,2)+a(5)*x(:,3));
	end
	X=[meanIntoColumn(trainingSet(cxy)),...
		meanIntoColumn(trainingSet(d1)),meanIntoColumn(trainingSet(d2))];
	Y_kates=makeIntoColumn(subj_kates);
	Y_mos=makeIntoColumn(subj_mos);
	p0=[lsqlin(vandern(X(:,1),2),Y_kates,[],[],vandern(1,2),1);...
		lsqlin([ones(size(X,1),1) X(:,2:3)],Y_kates,[],[],[1 0 0],1)];  % 6-by-1

	if ~train_a4, p0(4)=[]; end;
	options=optimset('MaxFunEvals',1e6);
	p=lsqcurvefit(myfun,p0,X,Y_kates,lower_bound,upper_bound,options);
	if ~train_a4, p=[p(1:3);1;p(4:5)]; end;

	p=round2(p,0.001);
end
% }}}

%% Set up anonymous functions for computing HASQI {{{
qnonlinmodel=@(params,x) params(1)+params(2).*x+params(3).*(x.^2);
qlinmodel=@(params,d1,d2) params(1)+params(2).*d1+params(3).*d2;
% }}}

%% Fill in Yhat for HASQI and trained HASQI {{{
if retrain 
	if computeLoizou, Yhat=zeros(length(Y),length(funcHandles)+2); end;
	Qnonlin=cell(1,2);
	Qlin=cell(1,2);
	Qnonlin{1}=KatesNonlinRegressionModel(testingSet(cxy));
	Qnonlin{2}=qnonlinmodel(p(1:3),testingSet(cxy));
	Qlin{1}=KatesLinearRegressionModel(testingSet(d1),testingSet(d2));
	Qlin{2}=qlinmodel(p(4:6),testingSet(d1),testingSet(d2));
	Yhat(:,1)=meanIntoColumn(Qnonlin{1}.*Qlin{1});
	Yhat(:,2)=meanIntoColumn(Qnonlin{2}.*Qlin{2});
end
% }}}

%% Plot scatters {{{
markersize=7;
h=figure;
pos=get(0,'ScreenSize');
set(h,'Position',[pos(1:3) pos(4)/2]);
% createString=@(vec) ['r=' num2str(round2(pearson(vec,Y_kates),0.01)) '; mse=' ...
	% num2str(round2(meansquareerror(vec,Y_kates),0.001))];

%% Plot Qnonlin {{{
subplot(131); hold on;
plot(meanIntoColumn(Qnonlin{1}),Y_kates,...
    '+b','MarkerSize',markersize);
plot(meanIntoColumn(Qnonlin{2}),Y_kates,...
    'oc','MarkerSize',markersize);
% xlim([-0.05 1.05]); 
% ylim([-0.05 1.05]); 
xlabel('Qnonlin');
ylabel('Subjective');
axis('square');
xlim([0 1.11]); set(gca,'XTick',0:.2:1);
ylim([0 1.11]); set(gca,'YTick',0:.2:1);
text(-0.2,1.1,'a)')
% legend({createString(meanIntoColumn(Qnonlin{1})),...
    % createString(meanIntoColumn(Qnonlin{2}))},...
    % 'Location','Best');
% }}}

%% Plot Qlin {{{ 
subplot(132); hold on;
plot(meanIntoColumn(Qlin{1}),Y_kates,...
    '+b','MarkerSize',markersize);
plot(meanIntoColumn(Qlin{2}),Y_kates,...
    'oc','MarkerSize',markersize);
% xlim([-0.05 1.05]); 
% ylim([-0.05 1.05]);
xlabel('Qlin');
ylabel('');
axis('square');
xlim([0 1.11]); set(gca,'XTick',0:.2:1);
ylim([0 1.11]); set(gca,'YTick',0:.2:1);
text(-0.2,1.1,'b)')
% legend({createString(meanIntoColumn(Qlin{1})),...
    % createString(meanIntoColumn(Qlin{2}))},...
    % 'Location','Best');
% }}}

%% Plot HASQI {{{
subplot(133); hold on;
plot(Yhat(:,1),Y_kates,...
	'+b','MarkerSize',markersize);
plot(Yhat(:,2),Y_kates,...
	'oc','MarkerSize',markersize);
% xlim([-0.05 1.05]); 
% ylim([-0.05 1.05]); 
xlabel('HASQI');
ylabel('');
axis('square');
xlim([0 1.11]); set(gca,'XTick',0:.2:1);
ylim([0 1.11]); set(gca,'YTick',0:.2:1);
text(-0.2,1.1,'c)')
% legend({createString(Yhat(:,1)),...
    % createString(Yhat(:,2))},...
    % 'Location','Best');
legend('HASQI','tHASQI','Location','Best');
% }}}
% }}}

%% Compute all the Loizou measures with the testing set {{{
if computeLoizou 
	for ii=1:length(funcHandles)
		fprintf(['Computing ' labels{ii+2} '...\n']);
		Yhat(:,ii+2)=makeIntoColumn(subset(computeStandardmetricForLoizouData(funcHandles{ii},...
			'~/sym/Dynastat/',false,trainingSentInd)));
	end
	fprintf('Done.\n');
end
% }}}

%% Save vars {{{
if savethemat 
	if exist(pathToSave,'file')==2
		savethemat=input('The path you specified already exists. Do you want to replace the file? (0;1)');
	end
	if savethemat 
		save(pathToSave,'Y_kates','Y_mos','Yhat','Qnonlin','Qlin','p');
	end
end
% }}}

%% Get the correlation coefficients {{{
r=corr(Y_mos,Yhat);
[sorted_r,sorted_r_i]=sort(abs(r));
% }}}

%% Compute the confidence intervals on each r {{{
confInt=intervalEstimationOfCorrCoeff(sorted_r,length(Y_mos));
confWidths=[sorted_r.'-confInt(:,1) confInt(:,2)-sorted_r.'];
% }}}

%% Test for significance {{{
significance_displaycell=cell(size(Yhat,2)+1,2);
significance_displaycell{1,2}='p-val';
significance_displaycell{1,3}='p-val';
for ii=1:size(Yhat,2)
	significance_displaycell{ii+1,1}=labels{ii};
	significance_displaycell{ii+1,2}=...
		round2(wolfestest([Y_mos Yhat(:,[1 ii])]),0.001);
	significance_displaycell{ii+1,3}=...
		round2(wolfestest([Y_mos Yhat(:,[2 ii])]),0.001);
end
% }}}

%% Compute the MSE {{{
mse=zeros(size(Yhat,2),1);
mse_rescaled=zeros(size(Yhat,2),1);
for ii=1:size(Yhat,2)
	mse(ii)=meansquareerror(Yhat(:,ii),Y_mos);
	mse_rescaled(ii)=meansquareerror(rescalextoy(Yhat(:,ii),Y_mos),Y_mos);
end
[sorted_mse,sorted_mse_i]=sort(mse,1,'descend');
[sorted_mse_rescaled,sorted_mse_rescaled_i]=sort(mse_rescaled,1,'descend');
% }}}

%% Make bar plots {{{
figPos=[1 1 1000 425];
axesPos=[0.21 0.2 0.75 0.7];

prettyBarPlot(sorted_r,labels(sorted_r_i),'|r|',confWidths);
set(gcf,'Position',figPos);
set(gca,'Position',axesPos);

prettyBarPlot_breakaxis(sorted_mse,labels(sorted_mse_i),...
	'MSE',[],[],[],3,[0 40 200 4310],0.90);
set(gcf,'Position',figPos);
set(gca,'Position',axesPos);

prettyBarPlot(sorted_mse_rescaled,labels(sorted_mse_rescaled_i),'MSE',[],[],[],3);
set(gcf,'Position',figPos);
set(gca,'Position',axesPos);
% }}}

%% Display information to screen {{{
getp=@(ind) num2str(round2(p(ind),0.001));
getcorrmse=@(vec,ref) ['r=' num2str(round2(pearson(vec,ref),0.01)) '; mse=' ...
	num2str(round2(meansquareerror(vec,ref),0.001))];
thefunc=['(' getp(1) ' + ' getp(2) '*Cxy + ' getp(3) '*Cxy^2) * '...
    '(' getp(4) ' + ' getp(5) '*d1 + ' getp(6) '*d2)'];

fprintf('\nTraining set:\n');
disp(trainingSentInd);
fprintf('\nTesting set\n');
disp(testingSentInd);
fprintf('The new model:\n');
fprintf(['\t' thefunc '\n\n']);

fprintf('Correlation and MSE for the transformed scores:\n');
fprintf('\t\tHASQI\t\t\ttHASQI\n');
fprintf(['Qnonlin -> ' getcorrmse(meanIntoColumn(Qnonlin{1}),Y_kates) '\t'...
	getcorrmse(meanIntoColumn(Qnonlin{2}),Y_kates) '\n']);
fprintf(['Qlin    -> ' getcorrmse(meanIntoColumn(Qlin{1}),Y_kates) '\t'...
	getcorrmse(meanIntoColumn(Qlin{2}),Y_kates) '\n']);
fprintf(['HASQI   -> ' getcorrmse(Yhat(:,1),Y_kates) '\t' ...
	getcorrmse(Yhat(:,2),Y_kates) '\n\n']);

fprintf('Correlation and MSE for the MOS:\n');
fprintf('\t\tHASQI\t\t\ttHASQI\n');
fprintf(['Qnonlin -> ' getcorrmse(meanIntoColumn(Qnonlin{1}),Y_mos) '\t'...
	getcorrmse(meanIntoColumn(Qnonlin{2}),Y_mos) '\n']);
fprintf(['Qlin    -> ' getcorrmse(meanIntoColumn(Qlin{1}),Y_mos) '\t'...
	getcorrmse(meanIntoColumn(Qlin{2}),Y_mos) '\n']);
fprintf(['HASQI   -> ' getcorrmse(Yhat(:,1),Y_mos) '\t' ...
	getcorrmse(Yhat(:,2),Y_mos) '\n\n']);

fprintf('Significance testing:\n');
disp(significance_displaycell);

fprintf('\n\nDo not forget to label the significance.\n\n');
% }}}

