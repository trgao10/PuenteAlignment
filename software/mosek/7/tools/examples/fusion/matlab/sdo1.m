function [Xres] = sdo1()
%  Solves the semidefinite optimization problem
%
%                   [2, 1, 0]   
%    minimize    Tr [1, 2, 1] * X
%                   [0, 1, 2]
%
%                   [1, 0, 0]
%    subject to  Tr [0, 1, 0] * X = 1
%                   [0, 0, 1]
%
%                   [1, 1, 1]
%                Tr [1, 1, 1] * X = 0.5
%                   [1, 1, 1]
%
%                   X is PSD

import mosek.fusion.*;

M  = Model('sdo1');
    
% Setting up the variables
X  = M.variable('X', Domain.inPSDCone(3));

C  = DenseMatrix ( [[2.,1.,0.]; [1.,2.,1.]; [0.,1.,2.]] );
A1 = DenseMatrix ( [[1.,0.,0.]; [0.,1.,0.]; [0.,0.,1.]] );
A2 = DenseMatrix ( [[1.,1.,1.]; [1.,1.,1.]; [1.,1.,1.]] );

% Objective
obj = Expr.dot(C, X);

% Constraints
M.constraint('c1', Expr.dot(A1, X), Domain.equalsTo(1.0));
M.constraint('c2', Expr.dot(A2, X), Domain.equalsTo(0.5));
try
    M.objective(ObjectiveSense.Minimize, obj);
catch
    disp('Still buggy..')
end

M.solve()

Xshape = arrayfun(@(i) X.shape.dim(i), 0:X.shape.nd-1);
Xres = fusionLevel(X.level(), Xshape);

function val = fusionLevel(vec, shape)
val = permute(reshape(vec, fliplr(shape)), length(shape):-1:1);
