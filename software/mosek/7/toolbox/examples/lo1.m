% lo1.m 

c     = [1 2 0]';
a     = [[1 0 1];[1 1 0]];
blc   = [4 1]';
buc   = [6 inf]';
blx   = sparse(3,1);
bux   = [];
[res] = msklpopt(c,a,blc,buc,blx,bux);
sol   = res.sol;

% Interior-point solution.

sol.itr.xx'      % x solution.
sol.itr.sux'     % Dual variables corresponding to buc.
sol.itr.slx'     % Dual variables corresponding to blx.

% Basic solution.

sol.bas.xx'      % x solution in basic solution.
