function [x,fval,exitflag,output] = bintprog(f,A,b,B,c,x0,options)
%bintprog Binary integer programming.
%   bintprog solves the binary integer programming problem
%
%       min f'*x  subject to:  A*x <= b,
%                              B*x  = c,
%                              where the elements of X are binary     
%                              integers, i.e., 0's or 1's.             
%
%   x = bintprog(f) solves the problem min f'*x, where the elements of x 
%   are binary integers. 
%
%   x = bintprog(f,A,b) solves the problem min f'*x subject to the linear 
%   inequalities A*x <= b, where the elements of x are binary integers.
%
%   x = bintprog(f,A,b,B,c) solves the problem min f'*x subject to the
%   linear equalities B*x = c, the linear inequalities A*x <= b, where 
%   the elements of x are binary integers.
%
%   x = bintprog(f,A,b,B,c,x0) sets the starting point to x0. The 
%   starting point x0 must be binary integer and feasible, or it will 
%   be ignored.
%
%   x = bintprog(f,A,b,B,c,x0,options) minimizes with the default 
%   optimization parameters replaced by values in the structure options, an
%   argument created with the mskoptimset function.  See mskoptimset for details.
%   Available options are Diagnostics, Display, MaxNodes and MaxTime.
%
%   x = bintprog(problem) finds the minimum for problem, where problem is 
%   a structure with the fields "f", "A" and "b", and optionally the 
%   fields "B", "c", "x0" and "options".
%
%   [x,fval] = bintprog(...) returns the value of the objective function at
%   x: fval = f'*x.
%
%   [x,fval,exitflag] = bintprog(...) returns an exitflag that describes 
%   the exit condition of bintprog. Possible values of exitflag and the 
%   corresponding exit conditions are
%
%      1  bintprog converged to a solution x.
%     -2  Problem is infeasible.
%     -4  MaxNodes reached without converging.              
%     -5  MaxTime reached without converging.               
%
%   [x,fval,exitflag,output] = bintprog(...) returns diagnostics output
%   from the solver.
%
%   Internally bintprog() is a wrapper for the mosekopt() function.
%
%   Example
%     f = [-9; -5; -6; -4]; 
%     A = [6 3 5 2; 0 0 1 1; -1 0 1 0; 0 -1 0 1];
%     b = [9; 1; 0; 0];
%     X = bintprog(f,A,b) 
%
%  See also linprog, mosekopt.
%
%  

defaultopt = mskoptimset;

if ( nargin == 1)
   prob = f;
   if isequal(f,'defaults')
       x = defaultopt;
       return
   elseif ( ~isstruct(prob) ) 
      exitflag = -1;
      output   = []; 
      fval     = []; 
      lambda   = [];
      x        = [];
      mskerrmsg('bintprog','Invalid input argument; problem must be a structure.');
      return; 
   end

   if ( ~all(isfield(prob, {'f','A','b'})) )
      exitflag = -1;
      output   = []; 
      fval     = []; 
      lambda   = [];
      if (isfield(prob,'x0'))      
         x     = x0; 
      end
      mskerrmsg('bintprog','problem must contain at least "f", "A" and "b".');
      return; 
   end

   f = prob.f;
   A = prob.A;
   b = prob.b;

   if (isfield(prob, 'options'))
      options = prob.options;
   else
      options = [];
   end

   if (isfield(prob, 'x0'))
      x0 = prob.options;
   else
      x0 = [];
   end

   if (isfield(prob, 'c'))
      c = prob.options;
   else
      c = [];
   end

   if (isfield(prob, 'B'))
      B = prob.options;
   else
      B = [];
   end

else

   % Handle missing arguments
   if ( nargin < 7 )
      options = [];
   end;   
   if ( nargin < 6 )
      x0 = []; 
   end   
   if ( nargin < 5 )
      c = [];
   end   
   if ( nargin < 4 )
      B = [];
   end   

   if ( nargin<3 )
      exitflag = -1;
      output   = []; 
      x        = x0; 
      fval     = []; 
      lambda   = [];
      mskerrmsg('bintprog','Too few input arguments. At least 3 are required.');
      return;
   end   
end

options
options          = mskoptimset(defaultopt,options)

[cmd,verb,param] = msksetup(1,options);

n                = length(f); 
[r,b,c,l,u]      = mskcheck('bintprog',verb,n,size(A),b,size(B),c,[],[]);

if ( r~=0 )
   exitflag = r;
   output   = []; 
   x        = x0; 
   fval     = []; 
   return;
end   

% Setup the problem that is feed into MOSEK.
prob        = [];
[numineq,t] = size(A);
[numeq,t]   = size(B);
prob.c      = reshape(f,n,1);
prob.a      = [A;B];
if ( isempty(prob.a) )
   prob.a = sparse(0,length(f));
elseif ~issparse(prob.a)
   prob.a = sparse(prob.a);
end   
prob.b      = b;
prob.blc    = [-inf*ones(size(b));c];
prob.buc    = [b;c];
prob.blx    = zeros(n,1);
prob.bux    = ones (n,1);

prob.sol.int.xx  = x0;
prob.ints.sub    = [1:n];

clear f A b B c l u x0 options;

[rcode,res] = mosekopt(cmd,prob,param);

mskstatus('linprog',verb,0,rcode,res);
 
if ( isfield(res,'sol') )
  x = res.sol.int.xx;
else
  x = [];
end

if nargout>1 & length(prob.c) == length(x)
   fval = prob.c'*x; 
else
  fval = [];
end

if nargout>2
   exitflag = mskeflag(rcode,res); 
end

if nargout>3
   output = res;
end


