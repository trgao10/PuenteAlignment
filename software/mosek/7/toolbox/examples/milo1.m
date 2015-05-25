% milo1.m

% Specify the linear problem data as if
% the problem is a linear optimization
% problem.

clear prob       
prob.c        = [-2 -3];
prob.a        = sparse([[195 273];[4 40]]);
prob.blc      = -[inf inf];
prob.buc      = [1365 140];
prob.blx      = [0 0];
prob.bux      = [4 inf];

% Specify indexes of variables that are integer
% constrained.

prob.ints.sub = [1 2];

% Optimize the problem.
[r,res] = mosekopt('minimize',prob);

try 
  % Display the optimal solution.
  res.sol.int
  res.sol.int.xx'
catch
  fprintf('MSKERROR: Could not get solution')
end
