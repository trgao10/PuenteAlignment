% qco1.m

clear prob;

% Specify the linear objective terms.
prob.c      = ones(3,1);

% Specify the quadratic terms of the constraints.
prob.qcsubk = [1   1   1   2  ]';
prob.qcsubi = [1   2   3   2  ]';
prob.qcsubj = [1   2   3   2  ]';
prob.qcval  = [2.0 2.0 2.0 0.2]';

% Specify the linear constraint matrix
prob.a      = [sparse(1,3);sparse([1 0 1])];

prob.buc    = [1 0.5]';

[r,res]     = mosekopt('minimize',prob);

% Display the solution.
fprintf('\nx:');
fprintf(' %-.4e',res.sol.itr.xx');
fprintf('\n||x||: %-.4e',norm(res.sol.itr.xx));
