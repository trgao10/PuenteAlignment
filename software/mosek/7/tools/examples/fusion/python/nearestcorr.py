##
#  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#  File:      nearestcorr.py
#
#  Purpose: 
#  Solves the nearest correlation matrix problem
# 
#    minimize   || A - X ||_F   s.t.  diag(X) = e, X is PSD
#
#  as the equivalent conic program
#
#    minimize     t
#   
#    subject to   (t, vec(A-X)) in Q
#                 diag(X) = e
#                 X >= 0
#    where
#                 vec : M(n x n) -> R^(n*(n+1)/2)
#                 vec(M)_k = M_ij           for k = i * (i+1) / 2 + j, and i == j
#                          | sqrt(2) * M_ij for k = i * (i+1) / 2, i < j
import sys
import mosek
import mosek.fusion
from   mosek.fusion import *

def vec(e):
    """
    Assuming that e is an NxN expression, return the lower triangular part as a vector.
    """
    N = e.getShape().dim(0)
    S = Matrix.sparse(N * (N+1) / 2,
                      N * N,
                      range(N * (N+1) / 2),
                      [ (i*N+j) for i in xrange(N) for j in xrange(i+1) ],
                      [ (1.0 if i == j else 2**(0.5)) for i in xrange(N) for j in xrange(i+1) ])

    
    r = Expr.mul(S,Expr.reshape( e, N * N ))

    return r

def main(args):
    N = 5
    A = [ [ 0.0,  0.5,  -0.1,  -0.2,   0.5],
          [ 0.5,  1.25, -0.05, -0.1,   0.25],
          [-0.1, -0.05,  0.51,  0.02, -0.05],
          [-0.2, -0.1,   0.02,  0.54, -0.1],
          [ 0.5,  0.25, -0.05, -0.1,   1.25]]

    # Create a model with the name 'NearestCorrelation
    with Model("NearestCorrelation") as M:

      # Setting up the variables
      X = M.variable("X", Domain.inPSDCone(N))
      t = M.variable("t", 1, Domain.unbounded())

      # (t, vec (A-X)) \in Q
      M.constraint("C1", Expr.vstack(t, vec(Expr.sub(DenseMatrix(A),X))), Domain.inQCone() );

      # diag(X) = e
      M.constraint("C2",X.diag(), Domain.equalsTo(1.0));

      # Objective: Minimize t
      M.objective(ObjectiveSense.Minimize, t)
                        
      # Solve the problem
      M.solve()

      M.writeTask('nearestcorr.opf')
      # Get the solution values
      print "X = ", X.level()
      
      print t.level()

if __name__ == '__main__':
    main(sys.argv[1:])


