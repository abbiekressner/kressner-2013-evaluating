C=[ones(size(carney.d1_subset(:))) -carney.d1_subset(:) -carney.d2_subset(:)];
d=subjRawNoNormalization_subset(:);

A = [];
b = [];
Aeq = [1 0 0];
beq = 5;
lb = 0;
ub = [];
x0 = [1; 0.400; 0.628];
options = optimset('lsqlin');
options = optimset(options,'LargeScale','off');

x=lsqlin(C,d,A,b,Aeq,beq,lb,ub,x0,options);
