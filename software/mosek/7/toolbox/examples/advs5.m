% advs5.m. A continuation of advs4.m. 

% Modify the problem.
prob.a       = prob.a(1:end-1,:);
prob.blc     = prob.blc(1:end-1);
prob.buc     = prob.buc(1:end-1);

% Obtain the previous optimal basis.
bas          = res.sol.bas;

% Set the solution to the modified problem.
bas.skc      = bas.skc(1:end-1,:);
bas.xc       = bas.xc(1:end-1);
bas.y        = bas.y(1:end-1);
bas.slc      = bas.slc(1:end-1);
bas.suc      = bas.suc(1:end-1);

% Reuse the basis.
prob.sol.bas = bas;

% Reoptimize.
[rcode,res]  = mosekopt('minimize',prob,param);

res.sol.bas.xx' 
