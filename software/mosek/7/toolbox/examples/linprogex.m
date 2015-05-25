f = [-5; -4; -6];
A =  [1 -1  1
      3  2  4
      3  2  0];
b = [20; 42; 30];
lb = zeros(3,1);

% Get default options
opt = optimset('');
% Turn on diagnostic output
opt = optimset(opt,'Diagnostics','on');
% Set a MOSEK option, in this case turn basic identification off.
opt = optimset(opt,'MSK_IPAR_INTPNT_BASIS','MSK_OFF');
% Modefy a MOSEK parameter with double value
opt = optimset(opt,'MSK_DPAR_INTPNT_TOL_INFEAS',1e-12);

[x,fval,exitflag,output,lambda] = linprog(f,A,b,[],[],lb,[],[],opt);

x
fval
exitflag
output
lambda



