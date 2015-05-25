% nrm2.m. Continuation of nrm1.m.

% Assume that the same objective should be
% minimized subject to -1 <= x <= 1

prob.blx = -ones(n,1);
prob.bux = ones(n,1);

[r,res] = mosekopt('minimize',prob);

% Check if the solution is feasible.
norm(res.sol.itr.xx,inf)
