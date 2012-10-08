function h=plotObjSubj(obj,subj,xlabelstring,xlabelinterpreter,wheretoputtext,yrange)

	if nargin<6
		yrange=[0 1];
	end
	if nargin<5
		wheretoputtext='bottomright';
	end
	if nargin<4
		xlabelinterpreter='latex';
	end
	if nargin<3
		xlabelstring='';
	end
	if nargin<2
		error('Not enough input arguments.');
	end




	fontSize=20;
	fontName='Times';

	h=figure;
	plot(obj,subj,'k.','MarkerSize',12)
	set(gca,'FontSize',fontSize,'FontName',fontName);
	
	xlim([0 1]);
	xlabel(xlabelstring,...
		'FontSize',fontSize,'FontName',fontName,...
		'interpreter',xlabelinterpreter);

	ylim(yrange);
	ylabel('Subjective quality score','FontSize',fontSize,'FontName',fontName);

	if strcmp(wheretoputtext,'bottomright')
		x=0.7; y=yrange(1)+0.125*diff(yrange);
	else
		x=0.1; y=yrange(2)-0.125*diff(yrange);
	end
	text(x,y,['r=' num2str(pearson(obj,subj),2)],...
		'FontSize',fontSize,'FontName','Times','interpreter','latex');

	% set(gca,'Position',[0.13,0.16,0.8,0.8]);
	axis('square');
	set(gca,'XTick',0:.2:1);
