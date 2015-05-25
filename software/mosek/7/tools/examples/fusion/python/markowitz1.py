#  
#  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
# 
#  File: markowitz1.py
# 
#  Solves the Markowitz portfolio optimization problem
#
#    minimize    x'*Sigma*x
#    subject to  mu'*x >= delta
#                e'*x   = 1
#                x >= 0
#
#  or equivalently
#
#    minimize    t
#    subject to  (1/2, t, Vx) \in Qr
#                mu'*x >= delta
#                e'*x   = 1
#                x >= 0
#
#  where Sigma = V'*V.
# 
import sys
import mosek
import mosek.fusion
from   mosek.fusion import *

# average returns
mu   = [ 1.05, 1.3, 0.9, 1.0, 0.9, 1.5 ];

# lower bound on return of investment
delta = 1.0;

# factor of covariance (we use the data-matrix)
V = DenseMatrix( 
    [ [-0.0644 , -0.0352 , -0.0019 ,  0.1015 ],
      [ 0.1183 , -0.0428 , -0.0013 , -0.0741 ],
      [-0.0798 , -0.1201 ,  0.1040 ,  0.0958 ],
      [-0.0855 , -0.1174 ,  0.1042 ,  0.0987 ],
      [-0.0158 , -0.0074 ,  0.0110 ,  0.0123 ],
      [ 0.0636 , -0.1341 ,  0.0206 ,  0.0497 ] ]).transpose();

with Model('Markowitz1') as M:

# variables
  x = M.variable('x', 6, Domain.greaterThan(0.0))
  t = M.variable('t', 1, Domain.greaterThan(0.0))

# mu'*x >= delta
  M.constraint(Expr.dot(mu,x),Domain.greaterThan(delta))

# e'*x = 1
  M.constraint(Expr.sum(x), Domain.equalsTo(1.0))

# (1/2, t, V*x) \in Qr
  M.constraint(Expr.vstack( Expr.constTerm(1, 0.5), 
                            t.asExpr(), 
                            Expr.mul(V,x) ), 
               Domain.inRotatedQCone())

# Minimize t (risk)
  M.objective(ObjectiveSense.Minimize, t)

# Solve the problem
  M.solve()

  print "x=", x.level()
