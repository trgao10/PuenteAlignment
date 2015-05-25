% advs6.m. A continuation of advs5.m. 

% Modify the problem.
prob.c       = prob.c(1:end-1);
prob.a       = prob.a(:,1:end-1);
prob.blx     = prob.blx(1:end-1);
prob.bux     = prob.bux(1:end-1);

% Obtain the previous optimal basis.
bas          = res.sol.bas;

% Set the solution to the modified problem.
bas.xx       = bas.xx(1:end-1);
bas.skx      = bas.skx(1:end-1,:);
bas.slx      = bas.slx(1:end-1);
bas.sux      = bas.sux(1:end-1);

% Reuse the basis.
prob.sol.bas = bas;

% Reoptimize.
[rcode,res]  = mosekopt('minimize',prob,param);

res.sol.bas.xx' 
