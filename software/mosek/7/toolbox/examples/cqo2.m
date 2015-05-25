% cqo2.m

[r, res] = mosekopt('symbcon');

% Set up the non-conic part of the problem.
prob          = [];
prob.c        = [1 1 1 0 0 0 0]';
prob.a        = sparse([[1 0 1 0 1 0 0];...
                        [0 1 0 0 0 0 -1]]);
prob.blc      = [0.5 0];
prob.buc      = [0.5 0];
prob.blx      = [-inf -inf -inf 1 -inf 1 -inf];
prob.bux      = [inf   inf  inf 1  inf 1  inf];

% Set up the cone information.
prob.cones.type   = [res.symbcon.MSK_CT_QUAD, ...
                     res.symbcon.MSK_CT_RQUAD];
prob.cones.sub    = [4, 1, 2, 3, 5, 6, 7];
prob.cones.subptr = [1, 5];

[r,res]       = mosekopt('minimize',prob);

% Display the solution.
res.sol.itr.xx'
