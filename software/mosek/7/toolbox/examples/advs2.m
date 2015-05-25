% advs2.m. Continuation of advs1.m.

prob.c       = [prob.c;-1.0];
prob.a       = [prob.a,sparse([1.0 0.0]')];
prob.blx     = sparse(4,1);

% Reuse the old optimal basic solution.
bas          = res.sol.bas;

% Add to the status key.
bas.skx      = [res.sol.bas.skx;'LL'];

% The new variable is at it lower bound.
bas.xx       = [res.sol.bas.xx;0.0];
bas.slx      = [res.sol.bas.slx;0.0];
bas.sux      = [res.sol.bas.sux;0.0];

prob.sol.bas = bas;

[rcode,res]  = mosekopt('minimize',prob,param);

% The new primal optimal solution
res.sol.bas.xx'
