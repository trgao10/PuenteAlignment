% sk1.m

% Obtain all symbolic constants
% defined in MOSEK.

clear prob bas;

[r,res]  = mosekopt('symbcon');
sc       = res.symbcon;

% Specify an initial basic solution.
% Please note that symbolic constants are used.
% I.e. sc.MSK_SK_LOW instead of 4.
bas.skc      = [sc.MSK_SK_LOW;sc.MSK_SK_LOW];
bas.skx      = [sc.MSK_SK_BAS;sc.MSK_SK_LOW;sc.MSK_SK_BAS];
bas.xc       = [4 1]';
bas.xx       = [1 3 0]';
prob.sol.bas = bas;

% Specify the problem data.
prob.c   = [ 1 2 0]';
subi     = [1 2 2 1];
subj     = [1 1 2 3];
valij    = [1.0 1.0 1.0 1.0];
prob.a   = sparse(subi,subj,valij);
prob.blc = [4.0 1.0]';
prob.buc = [6.0 inf]';
prob.blx = sparse(3,1);
prob.bux = [];

% Use the primal simplex optimizer.
clear param;
param.MSK_IPAR_OPTIMIZER = sc.MSK_OPTIMIZER_PRIMAL_SIMPLEX;

[r,res] = mosekopt('minimize statuskeys(1)',prob,param)

% Status keys will be numeric now i.e.

res.sol.bas.skc'

% is a vector of numeric values.
