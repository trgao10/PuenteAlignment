% mpsrd.m

% Read data from the file wp12-20.mps.

[r,res] = mosekopt('read(wp12-20.mps)');

% Looking at the problem data
prob = res.prob;
clear res;

% Form the quadratic term in the objective.
q = sparse(prob.qosubi,prob.qosubj,prob.qoval);

% Get a graphical picture.
spy(q) % Notice that only the lower triangular part is defined.
