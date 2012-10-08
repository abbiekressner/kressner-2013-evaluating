function [r,stdout]=pearson(x,y)
% [r,stdout]=pearson(x,y)
% Obtained from Hu & Loizou's JASA_intelligib_testing_noise-reduction
%
% This function computes r_{xy} the same as below:
% function r=rxy(x,y)
	% x=x(:);
	% y=y(:);

	% n=length(x);
	% r=((n*x.'*y)-(sum(x)*sum(y)))/(sqrt(n*sum(x.^2)-(sum(x)^2))*sqrt(n*sum(y.^2)-(sum(y)^2)));
% end
% 

n=length(x);

x_mean=mean(x);
y_mean=mean(y);

num=sum((x-x_mean).*(y-y_mean));
den=n*std(x,1)*std(y,1);


r      = num/den;

stdy   = std(y);
stdout    = stdy*sqrt(1-r*r);




