function cqo1_fusion()
%%
%   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
%
%   File:      cqo1_fusion.m
%
%   Purpose: Demonstrates how to solve the problem
%
%   minimize y1 + y2
%   such that
%            x1 + x2 + x3 + x4 = 1.0
%   and
%            (y1,x1,x2) in C_3,
%            (y2,x3,x4) in C_3
%
%   where C_3 is the quadratic cone of size 3 defined as 
%            C_3 = { z1,z2,z3 : z1 > sqrt(z2^2 + z3^2) }
%
import mosek.fusion.*;

%TAG:begin-create-model
M = Model('cqo1');
%TAG:end-create-model
        
%TAG:begin-create-variable
x = M.variable('x', 4, Domain.greaterThan(0.0));
y = M.variable('y', 2, Domain.unbounded());

% Create the aliases 
%      z1 = [ y[0],x[0],x[1] ]
%  and z2 = [ y[1],x[2],x[3] ]
z1 = Variable.stack(y.index(1), x.slice(2,3));
z2 = Variable.stack(y.index(2), x.slice(3,5));
%TAG:end-create-variable
        
%TAG:begin-create-lincon
% Create the constraint
%      x[0] + x[1] + x[2] + x[3] = 1.0
M.constraint('lc', Expr.sum(x), Domain.equalsTo(1.0));
%TAG:end-create-lincon
        
%TAG:begin-create-concon
% Create the constraints
%      z1 belongs to C_3
%      z2 belongs to C_3
% where C_3 is the quadratic cone of size 3, i.e.
%      z1[0] > sqrt(z1[1]^2 + z1[2]^2)
%  and z2[0] > sqrt(z2[1]^2 + z2[2]^2)
qc1 = M.constraint('qc1', z1.asExpr(), Domain.inQCone());
qc2 = M.constraint('qc2', z2.asExpr(), Domain.inQCone());
%TAG:end-create-concon
        
%TAG:begin-set-objective
% Set the objective function to (y[0] + y[1])
M.objective('obj', ObjectiveSense.Minimize, Expr.sum(y));
%TAG:end-set-objective
        
% Solve the problem
%TAG:begin-solve
M.solve();
%TAG:end-solve
        
%TAG:begin-get-solution
% Get the linearsolution values
solx = x.level();
soly = y.level();

disp(['[x1 x2 x3 x4] = ', mat2str(solx',7)]);
disp(['[y1 y2] = ', mat2str(soly',7)]);
%TAG:begin-get-con-sol
% Get conic solution of qc1
qc1lvl = qc1.level();
qc1sn  = qc1.dual();

disp(['qc1 levels = ', mat2str(qc1lvl',7)]);
disp(['qc1 dual conic var levels = ', mat2str(qc1sn',7)]);
%TAG:end-get-con-sol
