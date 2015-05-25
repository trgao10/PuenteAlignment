% cqo3.m

[r,res]=mosekopt('minimize',prob);

% Solution record.
res.sol

% Dual variables for lower
% bounds of constraints.
res.sol.itr.slc'

% Dual variables for upper
% bounds of constraints.
res.sol.itr.suc'

% Dual variables for lower
% bounds on variables.
res.sol.itr.slx'

% Dual variables for upper
% bounds on variables.
res.sol.itr.sux'

% Dual variables with respect
% to the conic constraints.
res.sol.itr.snx'
