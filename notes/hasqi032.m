cd ~/Documents/MATLAB/ObjectiveMeasures/
addpaths_hasqi

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

%% Set up the training matrices {{{
C_qnonlin=vandern(meanIntoColumn(trainingSet(cxy)),2);
C_qlin=[ones(size(meanIntoColumn(trainingSet(d1)))) ...
	meanIntoColumn(trainingSet(d1)) meanIntoColumn(trainingSet(d2))];
d=makeIntoColumn(subj);
% }}}

%% Train Qnonlin {{{
modelParams_qnonlin_constr=lsqlin(C_qnonlin,d,[],[],vandern(1,2),1);
modelParams_qnonlin_unconstr=C_qnonlin\d; % same as using lsqlin without constraints, but faster
% }}}

%% Train Qlin {{{
modelParams_qlin_constr=lsqlin(C_qlin,d,[],[],[1 0 0],1);
modelParams_qlin_unconstr=C_qlin\d; % same as using lsqlin without constraints, but faster
% }}}

%% Set up anonymous functions for plotting {{{
clipToZeroAndOne=@(x) min(max(x,0),1);
qnonlinmodel=@(params,x) clipToZeroAndOne(polyval(params,x));
qlinmodel=@(params,d1,d2) clipToZeroAndOne(params(1)+params(2).*d1+params(3).*d2);
getRho=@(mat) pearson(meanIntoColumn(mat),makeIntoColumn(subj));
createString=@(mat) ['r=' num2str(getRho(mat),3) '; mse=' num2str(meansquareerror(mean(mat,4),subj),3)];
% }}}

%% Plot Qnonlin {{{
markersize=7;
figure; 
subplot(2,1,1); hold on; % SHOW THE MODELS
allpossibleX=linspace(0,1,50);
plot(meanIntoColumn(trainingSet(cxy)),...
	makeIntoColumn(subj),'.k','MarkerSize',markersize); % plot data points
plot(allpossibleX,...
	KatesNonlinRegressionModel(allpossibleX),... % Kates model
	'--b','linewidth',2);
plot(allpossibleX,...
	qnonlinmodel(modelParams_qnonlin_constr,allpossibleX),... % constrained model
	'-.c','linewidth',2);
plot(allpossibleX,...
	qnonlinmodel(modelParams_qnonlin_unconstr,allpossibleX),... % unconstrained model
	':g','linewidth',2);
plot(1,1,'rx','linewidth',5); % constraining point
xlim([-0.05 1.05]); 
ylim([-0.05 1.05]);
xlabel('Cxy');
ylabel('Subjective');
legend('Data points','Kates model','Constrained model','Unconstrained model');

subplot(2,1,2); hold on;
plot(meanIntoColumn(KatesNonlinRegressionModel(testingSet(cxy))),... % Kates model
	makeIntoColumn(subj),...
	'+b','MarkerSize',markersize);
plot(meanIntoColumn(qnonlinmodel(modelParams_qnonlin_constr,testingSet(cxy))),... % constrained model
	makeIntoColumn(subj),...
	'sc','MarkerSize',markersize);
plot(meanIntoColumn(qnonlinmodel(modelParams_qnonlin_unconstr,testingSet(cxy))),... % unconstrained model
	makeIntoColumn(subj),...
	'og','MarkerSize',markersize);
xlim([-0.05 1.05]); 
ylim([-0.05 1.05]); 
xlabel('Qnonlin');
ylabel('Subjective');
legend({createString(KatesNonlinRegressionModel(testingSet(cxy))),...
	createString(qnonlinmodel(modelParams_qnonlin_constr,testingSet(cxy))),...
	createString(qnonlinmodel(modelParams_qnonlin_unconstr,testingSet(cxy))),...
	});
% }}}

%% Plot Qlin {{{ 
figure;
subplot(2,1,1); hold on; % SHOW THE MODELS
scatter3(meanIntoColumn(trainingSet(d1)),meanIntoColumn(trainingSet(d2)),...
	makeIntoColumn(subj),'k','filled'); % plot data points
thedensity=30;
[allx1,allx2]=meshgrid(linspace(0,.2,thedensity),linspace(0,0.2,thedensity));
thetransparency=0.4;
mesh(allx1,allx2,KatesLinearRegressionModel(allx1,allx2)); alpha(thetransparency); % Kates
mesh(allx1,allx2,qlinmodel(modelParams_qlin_constr,allx1,allx2)); alpha(thetransparency); % constrained
mesh(allx1,allx2,qlinmodel(modelParams_qlin_unconstr,allx1,allx2)); alpha(thetransparency); % unconstrained
scatter3(0,0,1,50,'r','filled'); % plot constraining point
xlabel('d1'); ylabel('d2'); zlabel('Subjective');
view(113,10);
fprintf('\nREMINDER: Add labels to the Qlin models\n');

subplot(2,1,2); hold on;
plot(meanIntoColumn(KatesLinearRegressionModel(testingSet(d1),testingSet(d2))),... % Kates
	makeIntoColumn(subj),...
	'+b','MarkerSize',markersize);
plot(meanIntoColumn(qlinmodel(modelParams_qlin_constr,testingSet(d1),testingSet(d2))),... % constrained
	makeIntoColumn(subj),...
	'sc','MarkerSize',markersize);
plot(meanIntoColumn(qlinmodel(modelParams_qlin_unconstr,testingSet(d1),testingSet(d2))),... % unconstrained
	makeIntoColumn(subj),...
	'og','MarkerSize',markersize);
xlim([-0.05 1.05]); xlabel('Qlin');
ylim([-0.05 1.05]); ylabel('Subjective');
legend({createString(KatesLinearRegressionModel(testingSet(d1),testingSet(d2))),...
	createString(qlinmodel(modelParams_qlin_constr,testingSet(d1),testingSet(d2))),...
	createString(qlinmodel(modelParams_qlin_unconstr,testingSet(d1),testingSet(d2))),...
	});
% }}}

%% Plot HASQI {{{
figure; hold on;
prediction_Kates=KatesNonlinRegressionModel(testingSet(cxy)).*...
	KatesLinearRegressionModel(testingSet(d1),testingSet(d2));
prediction_constrained=qnonlinmodel(modelParams_qnonlin_constr,testingSet(cxy)).*...
	qlinmodel(modelParams_qlin_constr,testingSet(d1),testingSet(d2));
prediction_unconstrained=qnonlinmodel(modelParams_qnonlin_unconstr,testingSet(cxy)).*...
	qlinmodel(modelParams_qlin_unconstr,testingSet(d1),testingSet(d2));
plot(meanIntoColumn(prediction_Kates),... % Kates
	makeIntoColumn(subj),'+b','MarkerSize',markersize);
plot(meanIntoColumn(prediction_constrained),... % constrained
	makeIntoColumn(subj),'sc','MarkerSize',markersize);
plot(meanIntoColumn(prediction_unconstrained),... % unconstrained
	makeIntoColumn(subj),'og','MarkerSize',markersize);
xlim([-0.05 1.05]); xlabel('HASQI');
ylim([-0.05 1.05]); ylabel('Subjective');
legend({createString(prediction_Kates),...
	createString(prediction_constrained),...
	createString(prediction_unconstrained),...
	});
% }}}
