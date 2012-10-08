addpath('~/Documents/MATLAB/ObjectiveMeasures/');
addpaths_hasqi;

load(['/Users/abbiekre/Documents/MATLAB/Data/'...
	'20120118_112by10MatrixOfAllSubjAndObj/X.mat']);
names={'Subjective','fwseg(k=13)','fwseg(k=25)','segSNR',...
	'WSS','PESQ','LLR',...
	'IS','CEP','HASQI'};

results=zeros(size(X,2)-1,3);
for ii=1:size(X,2)-1
	results(ii,1)=meansquareerror(X(:,ii+1),X(:,1));
	results(ii,2)=meansquareerror(rescalextoy(X(:,ii+1),X(:,1)),X(:,1));
	results(ii,3)=results(ii,1)/diff(minAndMax(X(:,ii+1)));
end

% Print results
resultsdisp=cell(size(results)+1);
resultsdisp(2:end,1)=names(2:end);
resultsdisp{1,2}='MSE';
resultsdisp{1,3}='MSE of rescaled';
resultsdisp{1,4}='Normalized MSE';
resultsdisp(2:end,2:end)=num2cell(round2(results,0.001));
disp(resultsdisp)

% Plot results
orderThis=@(mat,i) mat(i);
callThePlottingFunc=@(vals,order) prettyBarPlot(vals,...
	orderThis(names(2:end),order),'MSE');
[mse,order]=sort(results(:,2),1,'descend');
callThePlottingFunc(mse,order);
title('MSE with re-scaled objective measures');
[mse,order]=sort(results(:,3),1,'descend');
callThePlottingFunc(mse,order);
title('MSE/(max(x)-min(x))');
