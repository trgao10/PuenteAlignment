##
#  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#  File:      lo1_fusion.py
#
#  Purpose: Demonstrates how to solve the problem
#
#  minimize 3*x1 + 5*x2 + x3 + y
#  such that
#           3*x1 + 2*x2        +   y = 30,
#           2*x1 + 3*x2 +   x3 +   y > 15,
#                       + 3*x3 + 2*y < 25
#  and
#           x0,x1,x2 > 0,
#           0 < y < 10
##

import sys
import mosek
import mosek.fusion
from   mosek.fusion import *

def main(args):
    A = [ [ 3.0, 2.0, 0.0, 1.0 ],
          [ 2.0, 3.0, 1.0, 1.0 ],
          [ 0.0, 0.0, 3.0, 2.0 ] ]
    c = [ 3.0, 5.0, 1.0, 1.0  ]

    # Create a model with the name 'lo1'
    with Model("lo1") as M:

      # Create variable 'x' of length 3
      x = M.variable("x", 3, Domain.greaterThan(0.0))
      # Create variable 'y' of length 1
      y = M.variable("y", 1, Domain.inRange(0.0, 10.0))
      # Create a variable vector consisting of x and y
      z = Variable.vstack(x,y)

      # Create three constraints
      M.constraint("c1", Expr.dot(A[0], z), Domain.equalsTo(30.0))
      M.constraint("c2", Expr.dot(A[1], z), Domain.greaterThan(15.0))
      M.constraint("c3", Expr.dot(A[2], z), Domain.lessThan(25.0))

      # Set the objective function to (c^t * x)
      M.objective("obj", ObjectiveSense.Maximize, Expr.dot(c, z))
        
      # Solve the problem
      M.solve()


      # Get the solution values
      sol = z.level()
      print "x1,x2,x3,y = ", sol

if __name__ == '__main__':
    main(sys.argv[1:])
