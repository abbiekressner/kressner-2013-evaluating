whichcase=5;

switch whichcase
	case 1
		train_a4=true;
		lower_bound=[];
		upper_bound=[];
        p0_method=3;
	case 2
		train_a4=true;
		lower_bound=-10*ones(6,1);
		upper_bound=[10 10 10 1 0 0];
        p0_method=3;
	case 3
		train_a4=true;
		lower_bound=-10*ones(6,1);
		upper_bound=[10 10 10 10 0 0];
        p0_method=3;
	case 4
		train_a4=false;
		lower_bound=[];
		upper_bound=[];
        p0_method=3;
	case 5
		train_a4=false;
		lower_bound=-10*ones(5,1);
		upper_bound=10*ones(5,1);
        p0_method=3;
    case 6
		train_a4=false;
		lower_bound=-10*ones(5,1);
		upper_bound=10*ones(5,1);
        p0_method=2;
    case 7
		train_a4=false;
		lower_bound=-10*ones(5,1);
		upper_bound=10*ones(5,1);
        p0_method=1;
end

%% Set the path {{{
addpath('~/Documents/MATLAB/ObjectiveMeasures/');
addpaths_hasqi
% }}}

%% Load the data {{{
load('~/sym/HuLoizouSubj.mat');
subj=subjRawNoNormalization_subset;
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
if train_a4
	myfun=@(a,x) (a(1)+a(2)*(x(:,1).^2)+a(3)*(x(:,1).^2)).*(a(4)+a(5)*x(:,2)+a(6)*x(:,3));
else
	myfun=@(a,x) (a(1)+a(2)*(x(:,1).^2)+a(3)*(x(:,1).^2)).*(1+a(4)*x(:,2)+a(5)*x(:,3));
end
X=[meanIntoColumn(trainingSet(cxy)),...
    meanIntoColumn(trainingSet(d1)),meanIntoColumn(trainingSet(d2))];
Y=makeIntoColumn(subj);
switch p0_method
    case 1
        p0=vertcat([0.550;-1.944;2.284]./(0.550-1.944+2.284),[0.939;-0.376;-0.590]./0.939);
    case 2
        p0=[vandern(X(:,1),2)\Y;[ones(size(X,1),1) X(:,2:3)]\Y];
    case 3
        p0=[lsqlin(vandern(X(:,1),2),Y,[],[],vandern(1,2),1);...
            lsqlin([ones(size(X,1),1) X(:,2:3)],Y,[],[],[1 0 0],1)]; 
end

if ~train_a4
	p0(4)=[]; % remove
end

options=optimset('MaxFunEvals',1e6);
p=lsqcurvefit(myfun,p0,X,Y,lower_bound,upper_bound,options);

if ~train_a4
    p=[p(1:3);1;p(4:5)]; % put p(4) back in
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
    qnonlinmodel(p(1:3),allpossibleX),...
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
plot(meanIntoColumn(qnonlinmodel(p(1:3),testingSet(cxy))),...
    makeIntoColumn(subj),...
    'sc','MarkerSize',markersize);
% xlim([-0.05 1.05]); 
% ylim([-0.05 1.05]); 
xlabel('Qnonlin');
ylabel('Subjective');
legend({createString(KatesNonlinRegressionModel(testingSet(cxy))),...
    createString(qnonlinmodel(p(1:3),testingSet(cxy)))},...
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
mesh(allx1,allx2,qlinmodel(p(4:6),allx1,allx2)); 
alpha(thetransparency); % constrained
scatter3(0,0,1,50,'r','filled'); % plot constraining point
xlabel('d1'); ylabel('d2'); zlabel('Subjective');
view(113,10);

subplot(2,3,5); hold on;
plot(meanIntoColumn(KatesLinearRegressionModel(testingSet(d1),testingSet(d2))),...
    makeIntoColumn(subj),...
    '+b','MarkerSize',markersize);
plot(meanIntoColumn(qlinmodel(p(4:6),testingSet(d1),testingSet(d2))),...
    makeIntoColumn(subj),...
    'sc','MarkerSize',markersize);
% xlim([-0.05 1.05]); 
% ylim([-0.05 1.05]);
xlabel('Qlin');
ylabel('Subjective');
legend({createString(KatesLinearRegressionModel(testingSet(d1),testingSet(d2))),...
    createString(qlinmodel(p(4:6),testingSet(d1),testingSet(d2)))},...
    'Location','Best');
% }}}

%% Plot HASQI {{{
subplot(2,3,6); hold on;
prediction_Kates=KatesNonlinRegressionModel(testingSet(cxy)).*...
    KatesLinearRegressionModel(testingSet(d1),testingSet(d2));
prediction_trained=myfun(p,[makeIntoColumn(testingSet(cxy)),...
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

getp=@(ind) num2str(round2(p(ind),0.001));
thefunc=['(' getp(1) ' + ' getp(2) '*Cxy + ' getp(3) '*Cxy^2) * '...
    '(' getp(4) ' + ' getp(5) '*d1 + ' getp(6) '*d2)'];
suptitle(thefunc);
