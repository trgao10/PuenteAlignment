##
#  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#  File:      simple.py
#
#  Purpose:   Demonstrate a very simple Fusion model. 
#
#  The problem: 
#    max        x+y
#    such that  0  < x < 1
#               -1 < y-x < 2
#
##

from   mosek.fusion import *
import mosek.array

# Create a model object
with Model('simple') as M:
# Add two variables
  x = M.variable('x',1,Domain.inRange(0.0,1.0))
  y = M.variable('y',1,Domain.unbounded())
# Add a constraint on the variables
  M.constraint('bound y', Expr.sub(y,x), Domain.inRange(-1.0, 2.0))
# Define the objective
  M.objective("obj", ObjectiveSense.Maximize, Expr.add(x,y))
# Solve the problem
  M.solve()
# Print the solution
  print "Solution x = %f, y = %f" % (x.level()[0],y.level()[0])


