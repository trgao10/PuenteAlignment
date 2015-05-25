% lo2.m

clear prob;

% Specify the c vector.
prob.c = [ 1 2 0]';

% Specify a in sparse format.
subi   = [1 2 2 1];
subj   = [1 1 2 3];
valij  = [1.0 1.0 1.0 1.0];

prob.a = sparse(subi,subj,valij);

% Specify lower bounds of the constraints.
prob.blc  = [4.0 1.0]';

% Specify  upper bounds of the constraints.
prob.buc  = [6.0 inf]';

% Specify lower bounds of the variables.
prob.blx  = sparse(3,1);

% Specify upper bounds of the variables.
prob.bux = [];   % There are no bounds.

% Perform the optimization.
[r,res] = mosekopt('minimize',prob); 

% Show the optimal x solution.
res.sol.bas.xx
