% nrm4.m. Continuation of nrm1.m.

% Let x(n:(m+n)) play the role as t. Now,
% the problem can be solved as follows

clear prob;

prob.c   = [sparse(n,1)   ; ones(m,1)];
prob.a   = [[f,-speye(m)] ; [f,speye(m)]];
prob.blc = [-inf*ones(m,1); b];
prob.buc = [b             ; inf*ones(m,1)];

[r,res]  = mosekopt('minimize',prob);

% The optimal objective value is given by:
norm(f*res.sol.itr.xx(1:n)-b,1) 
