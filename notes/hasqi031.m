alpha=0.05;
computeX=false;

addpath('~/Documents/MATLAB/ObjectiveMeasures');
addpaths_hasqi;
addpath(['~/Documents/MATLAB/Loizou/TextbookDatabase/'...
	'MATLAB_code/obj_evaluation/']);

load('~/sym/HuLoizouSubj.mat','subjRawNoNormalization_subset');

funcHandles={@comp_fwseg_k13,@comp_fwseg,@comp_snr,@comp_wss,...
	@pesq,@comp_llr,@comp_is,@comp_cep};

if computeX
	X=zeros(length(subjRawNoNormalization_subset(:)),...
		length(funcHandles)+2);
	X(:,1)=subjRawNoNormalization_subset(:);
	for ii=1:length(funcHandles)
		obj=computeStandardmetricForLoizouData(funcHandles{ii});
		obj=obj([1 2 4:15],:,:);
		X(:,ii+1)=obj(:);
	end
	load(['/Users/abbiekre/Documents/MATLAB/Data/'...
		'20111014_HasqiWithKatesAddLogToLinForQlin/results.mat'],...
		'hasqi_subset');
	X(:,end)=hasqi_subset(:);
else
	load('/Users/abbiekre/Documents/MATLAB/Data/20120118_112by10MatrixOfAllSubjAndObj/X.mat');
end

% NOTE The columns of X are ordered as follows:
%	1. Subjective
%	2. fwseg(k=13)
%	3. fwseg(k=25)
%	4. segSNR
%	5. WSS
%	6. PESQ
%	7. LLR
%	8. IS
%	9. CEP
%	10.HASQI
names={'fwseg(k=13)','fwseg(k=25)','segSNR',...
	'WSS','PESQ','LLR',...
	'IS','CEP','HASQI'};

numberOfInterestingCorrs=9;
pairs = [9*ones(numberOfInterestingCorrs-1,1),[1:numberOfInterestingCorrs-1]'];
displaycell=cell(size(pairs,1)+1,4);
wolfe_pval=zeros(size(pairs,1),1);
displaycell{1,3}='p-val';
displaycell{1,4}=['p<' num2str(alpha)];
for pp=1:size(pairs,1)
	wolfe_pval(pp)=wolfestest(X(:,[1 pairs(pp,:)+1]));
	displaycell{pp+1,1}=names{pairs(pp,1)};
	displaycell{pp+1,2}=names{pairs(pp,2)};
	displaycell{pp+1,3}=num2str(wolfe_pval(pp),3);
	displaycell{pp+1,4}=wolfe_pval(pp)<alpha;
end

% PRINT
disp(displaycell)
