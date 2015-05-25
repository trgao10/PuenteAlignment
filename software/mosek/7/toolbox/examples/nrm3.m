% nrm3.m. Continuation of nrm1.m.

% Let x(n+1) play the role as tau, then the problem is
% solved as follows.

clear prob;

prob.c   = sparse(n+1,1,1.0,n+1,1);
prob.a   = [[f,ones(m,1)];[f,-ones(m,1)]];
prob.blc = [b            ; -inf*ones(m,1)];
prob.buc = [inf*ones(m,1); b             ];

[r,res]  = mosekopt('minimize',prob);

% The optimal objective value is given by:
norm(f*res.sol.itr.xx(1:n)-b,inf) 
