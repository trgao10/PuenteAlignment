% micqo1.m

clear prob;

[r, res] = mosekopt('symbcon');

% Specify the non-confic part of the problem.

prob.c   = [0 0 0 0 1 1];
prob.a   = sparse([1 1 1 1 0 0]);
prob.blc = 1;
prob.buc = 1;
prob.blx = [0 0 0 0 -inf -inf];
prob.bux = inf*ones(6,1);

% Specify the cones.%
prob.cones.type   = [res.symbcon.MSK_CT_QUAD, res.symbcon.MSK_CT_QUAD];
prob.cones.sub    = [5, 3, 1, 6, 2, 4];
prob.cones.subptr = [1, 4];

% indices of integer variables
prob.ints.sub = [5 6];

% Optimize the problem. 

[r,res]=mosekopt('minimize',prob);

% Display the primal solution.

res.sol.int.xx'
