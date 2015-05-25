% nrm1.m

% Read data from 'afiro.mps'.
[r,res] = mosekopt('read(afiro.mps)');

% Get data for the problem
%             minimize ||f x - b||_2
f = res.prob.a';
b = res.prob.c;

% Solve the problem
%             minimize 0.5 xf'fx+0.5*b'*b-(f'*b)'*x

% Clear prob
clear prob;

% Compute the fixed term in the objective.
prob.cfix = 0.5*b'*b

% Create the linear objective terms
prob.c = -f'*b;

% Create the quadratic terms. Please note that only the lower triangular
% part of f'*f is used.
[prob.qosubi,prob.qosubj,prob.qoval] = find(sparse(tril(f'*f)))

% Obtain the matrix dimensions.
[m,n]   = size(f);

% Specify a.
prob.a  = sparse(0,n);

[r,res] = mosekopt('minimize',prob);

% The optimality conditions are f'*(f x - b) = 0.
% Check if they are satisfied:

fprintf('\nnorm(f^T(fx-b)): %e',norm(f'*(f*res.sol.itr.xx-b)));
