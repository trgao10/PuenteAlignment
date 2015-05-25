% milo2.m

clear prob
clear param
[r,res]         = mosekopt('symbcon');
sc              = res.symbcon;


prob.c          = [7 10 1 5];
prob.a          = sparse([1 1 1 1 ]);
prob.blc        = -[inf];
prob.buc        = [2.5];
prob.blx        = [0 0 0 0];
prob.bux        = [inf inf inf inf];
prob.ints.sub   = [1 2 3];

prob.sol.int.xx = [0 2 0 0.5]';

% Optionally set status keys too. 
% prob.sol.int.skx = [sc.MSK_SK_SUPBAS;sc.MSK_SK_SUPBAS;...
%                     sc.MSK_SK_SUPBAS;sc.MSK_SK_BAS] 
% prob.sol.int.skc = [sc.MSK_SK_UPR]

[r,res] = mosekopt('maximize',prob);

try
  % Display the optimal solution.
  res.sol.int.xx'
catch
  fprintf('MSKERROR: Could not get solution')
end

