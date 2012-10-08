function alphas=hasqi035(restrict_a4,lb,ub)

if isscalar(ub)
	if restrict_a4
		ub=ub*ones(1,5);
	else
		ub=ub*ones(1,6);
	end
end
if isscalar(lb)
	if restrict_a4
		lb=lb*ones(1,5);
	else
		lb=lb*ones(1,6);
	end
end

%% Set the path {{{
addpath('~/Documents/MATLAB/ObjectiveMeasures/');
addpaths_hasqi
% }}}

%% Load the data {{{
load('~/sym/HuLoizouSubj_zeroToOne.mat');
subj=zeroToOneScores_subset;
load('/Users/abbiekre/Documents/MATLAB/Data/20111014_HasqiWithKatesAddLogToLinForQlin/results.mat');
% }}}

%% Set up anonymous functions for training {{{
subset=@(mat) mat([1 2 4:end],:,:,:);
trainingSentInd=randsample(16,8); % sentences in the training set
testingSentInd=setdiff(1:16,trainingSentInd); % sentences in the testing set
grabTraining=@(mat) mat(:,:,:,trainingSentInd);
grabTesting=@(mat) mat(:,:,:,testingSentInd);
trainingSet=@(mat) grabTraining(subset(mat));
testingSet=@(mat) grabTesting(subset(mat));
makeIntoColumn=@(mat) reshape(mat,[],1);
meanIntoColumn=@(x) makeIntoColumn(mean(x,4));
% }}}

%% Training {{{
X=[meanIntoColumn(trainingSet(cxy)),...
    meanIntoColumn(trainingSet(d1)),meanIntoColumn(trainingSet(d2))];
Y=makeIntoColumn(subj);

themodel=@(a,u) (a(1)+a(2)*u(:,1)+a(3)*u(:,1).^2).*...
	(a(4)+a(5)*u(:,2)+a(6)*u(:,3));

if restrict_a4
	add_a4=@(a) [a(1:3) 1 a(end-1:end)];
	objfun=@(a) sum((Y-themodel(add_a4(a),X)).^2);
	alphas=GODLIKE(objfun,500,lb,ub);
	alphas=add_a4(alphas);
else
	objfun=@(a) sum((Y-themodel(a,X)).^2);
	alphas=GODLIKE(objfun,500,lb,ub);
end

% }}}

%% Set up anonymous functions for plotting {{{
clipToZeroAndOne=@(x) min(max(x,0),1);
% qnonlinmodel=@(params,x) clipToZeroAndOne(polyval(params,x));
% qlinmodel=@(params,d1,d2) clipToZeroAndOne(params(1)+params(2).*d1+params(3).*d2);
qnonlinmodel=@(params,x) polyval(params,x);
qlinmodel=@(params,d1,d2) params(1)+params(2).*d1+params(3).*d2;
getRho=@(mat) pearson(meanIntoColumn(mat),makeIntoColumn(subj));
createString=@(mat) ['r=' num2str(getRho(mat),3) '; mse=' num2str(meansquareerror(mean(mat,4),subj),3)];
% }}}

%% Plot Qnonlin {{{
markersize=7;
h=figure;
maximize(h);

subplot(2,3,1); hold on; % SHOW THE MODELS
allpossibleX=linspace(0,1,50);
plot(meanIntoColumn(trainingSet(cxy)),...
	makeIntoColumn(subj),'ok','MarkerSize',markersize);
plot(allpossibleX,...
	KatesNonlinRegressionModel(allpossibleX),...
	'--b','linewidth',2);
plot(allpossibleX,...
	qnonlinmodel(alphas(1:3),allpossibleX),...
	'-.c','linewidth',2);
plot(1,1,'rx','linewidth',5);
% xlim([-0.05 1.05]); 
% ylim([-0.05 1.05]);
xlabel('Cxy');
ylabel('Subjective');
legend({'Data points','Kates model','Trained model'},'Location','Best');

subplot(2,3,4); hold on;
plot(meanIntoColumn(KatesNonlinRegressionModel(testingSet(cxy))),...
	makeIntoColumn(subj),...
	'+b','MarkerSize',markersize);
plot(meanIntoColumn(qnonlinmodel(alphas(1:3),testingSet(cxy))),...
	makeIntoColumn(subj),...
	'sc','MarkerSize',markersize);
% xlim([-0.05 1.05]); 
% ylim([-0.05 1.05]); 
xlabel('Qnonlin');
ylabel('Subjective');
legend({createString(KatesNonlinRegressionModel(testingSet(cxy))),...
	createString(qnonlinmodel(alphas(1:3),testingSet(cxy)))},...
	'Location','Best');
% }}}

%% Plot Qlin {{{ 
subplot(2,3,2); hold on; % SHOW THE MODELS
scatter3(meanIntoColumn(trainingSet(d1)),meanIntoColumn(trainingSet(d2)),...
	makeIntoColumn(subj),'k','filled'); % plot data points
thedensity=30;
[allx1,allx2]=meshgrid(linspace(0,.2,thedensity),linspace(0,0.2,thedensity));
thetransparency=0.4;
mesh(allx1,allx2,KatesLinearRegressionModel(allx1,allx2));
alpha(thetransparency); % Kates
mesh(allx1,allx2,qlinmodel(alphas(4:6),allx1,allx2)); 
alpha(thetransparency); % constrained
scatter3(0,0,1,50,'r','filled'); % plot constraining point
xlabel('d1'); ylabel('d2'); zlabel('Subjective');
view(113,10);

subplot(2,3,5); hold on;
plot(meanIntoColumn(KatesLinearRegressionModel(testingSet(d1),testingSet(d2))),...
	makeIntoColumn(subj),...
	'+b','MarkerSize',markersize);
plot(meanIntoColumn(qlinmodel(alphas(4:6),testingSet(d1),testingSet(d2))),...
	makeIntoColumn(subj),...
	'sc','MarkerSize',markersize);
% xlim([-0.05 1.05]); 
% ylim([-0.05 1.05]);
xlabel('Qlin');
ylabel('Subjective');
legend({createString(KatesLinearRegressionModel(testingSet(d1),testingSet(d2))),...
	createString(qlinmodel(alphas(4:6),testingSet(d1),testingSet(d2)))},...
	'Location','Best');
% }}}

%% Plot HASQI {{{
subplot(2,3,6); hold on;
prediction_Kates=KatesNonlinRegressionModel(testingSet(cxy)).*...
	KatesLinearRegressionModel(testingSet(d1),testingSet(d2));
prediction_trained=themodel(alphas,[makeIntoColumn(testingSet(cxy)),...
	makeIntoColumn(testingSet(d1)),makeIntoColumn(testingSet(d2))]);prediction_trained=reshape(prediction_trained,size(prediction_Kates));
plot(meanIntoColumn(prediction_Kates),...
	makeIntoColumn(subj),'+b','MarkerSize',markersize);
plot(meanIntoColumn(prediction_trained),...
	makeIntoColumn(subj),'sc','MarkerSize',markersize);
% xlim([-0.05 1.05]); 
% ylim([-0.05 1.05]); 
xlabel('HASQI');
ylabel('Subjective');
legend({createString(prediction_Kates),...
	createString(prediction_trained)},...
	'Location','Best');
% }}}

getalpha=@(ind) num2str(round2(alphas(ind),0.001));
thefunc=['(' getalpha(1) ' + ' getalpha(2) '*Cxy + ' getalpha(3) '*Cxy^2) * '...
	'(' getalpha(4) ' + ' getalpha(5) '*d1 + ' getalpha(6) '*d2)'];
suptitle(thefunc);
