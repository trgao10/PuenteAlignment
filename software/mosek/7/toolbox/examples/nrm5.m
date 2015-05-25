% nrm5.m

% Read data from a file.
[rcode,res] = mosekopt('read(lsqpd.mps) echo(0)');

% Define the problem data.
F           = res.prob.a;
f           = res.prob.blc;
blx         = res.prob.blx;
bux         = [];

% In this case there are no linear constraints
% First we solve the primal problem:
%
% minimize   0.5|| z ||^2
% subject to F x - z = f
%            l <= x <= u

% Note that m>>n
[m,n]       = size(F);

prob        = [];

prob.qosubi = n+(1:m);
prob.qosubj = n+(1:m);
prob.qoval  = ones(m,1);
prob.a      = [F,-speye(m,m)];
prob.blc    = f;
prob.buc    = f;
prob.blx    = [blx;-inf*ones(m,1)];
prob.bux    = bux;


fprintf('m=%d  n=%d\n',m,n);

fprintf('First try\n');

tic
[rcode,res] = mosekopt('minimize echo(0)',prob);

% Display the solution time.
fprintf('Time           : %-.2f\n',toc);

try 
  % x solution:
  x = res.sol.itr.xx;

  % objective value:
  fprintf('Objective value: %-6e\n',norm(F*x(1:n)-f)^2);

  % Check feasibility.
  fprintf('Feasibility    : %-6e\n',min(x(1:n)-blx(1:n)));
catch
  fprintf('MSKERROR: Could not get solution')
end

% Clear prob.
prob=[];

%
% Next, we solve the dual problem.

% Index of lower bounds that are finite:
lfin        = find(blx>-inf);

% Index of upper bounds that are finite:
ufin        = find(bux<inf);

prob.qosubi = 1:m;
prob.qosubj = 1:m;
prob.qoval  = -ones(m,1);
prob.c      = [f;blx(lfin);-bux(ufin)];
prob.a      = [F',...
               sparse(lfin,(1:length(lfin))',...
                      ones(length(lfin),1),...
                      n,length(lfin)),...
               sparse(ufin,(1:length(ufin))',...
                      -ones(length(ufin),1),...
                      n,length(ufin))];
prob.blc    = sparse(n,1);
prob.buc    = sparse(n,1);
prob.blx    = [-inf*ones(m,1);...
               sparse(length(lfin)+length(ufin),1)];
prob.bux    = [];

fprintf('\n\nSecond try\n');
tic
[rcode,res] = mosekopt('maximize echo(0)',prob);

% Display the solution time.
fprintf('Time           : %-.2f\n',toc);

try
  % x solution:
  x = res.sol.itr.y;

  % objective value:
  fprintf('Objective value: %-6e\n',...
          norm(F*x(1:n)-f)^2);

  % Check feasibility.
  fprintf('Feasibility    : %-6e\n',...
          min(x(1:n)-blx(1:n)));
catch
  fprintf('MSKERROR: Could not get solution')
end
