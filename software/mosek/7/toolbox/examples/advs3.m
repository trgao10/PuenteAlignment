% advs3.m. Continuation of advs2.m.

prob.blx(4)  = 1;
prob.bux     = [inf inf inf 1]';

% Reuse the basis.
prob.sol.bas = res.sol.bas;

[rcode,res]  = mosekopt('minimize',prob,param);

% Display the optimal solution.
res.sol.bas.xx'
