#
#  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#  File:    lo1.py
#
#  Purpose: Demonstrates how to solve small linear
#           optimization problem using the MOSEK Python API.
##
from __future__ import with_statement

import sys
import mosek

# If numpy is installed, use that, otherwise use the 
# Mosek's array module.
try:
    from numpy import array,zeros,ones
except ImportError:
    from mosek.array import array, zeros, ones

# Since the value of infinity is ignored, we define it solely
# for symbolic purposes
inf = 0.0

# Define a stream printer to grab output from MOSEK
def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()

def main ():
  # Make mosek environment
  with mosek.Env() as env:
    # Create a task object
    with env.Task(0,0) as task:
      # Attach a log stream printer to the task
      task.set_Stream (mosek.streamtype.log, streamprinter)

      # Bound keys for constraints
      bkc = [mosek.boundkey.fx,
             mosek.boundkey.lo,
             mosek.boundkey.up]

      # Bound values for constraints
      blc = [30.0, 15.0, -inf]
      buc = [30.0, +inf, 25.0]

      # Bound keys for variables
      bkx = [mosek.boundkey.lo,
             mosek.boundkey.ra,
             mosek.boundkey.lo,
             mosek.boundkey.lo]

      # Bound values for variables
      blx = [ 0.0,  0.0,  0.0,  0.0]
      bux = [+inf, 10.0, +inf, +inf]

      # Objective coefficients
      c = [ 3.0, 1.0, 5.0, 1.0 ] 
      
      # Below is the sparse representation of the A
      # matrix stored by column. 
      asub = [ array([0, 1]),
               array([0, 1, 2]),
               array([0, 1]),
               array([1, 2])]
      aval = [ array([3.0, 2.0]),
               array([1.0, 1.0, 2.0]),
               array([2.0, 3.0]),
               array([1.0, 3.0]) ]

      numvar = len(bkx)
      numcon = len(bkc)

      # Append 'numcon' empty constraints.
      # The constraints will initially have no bounds. 
      task.appendcons(numcon)
      
      # Append 'numvar' variables.
      # The variables will initially be fixed at zero (x=0). 
      task.appendvars(numvar)
            
      for j in range(numvar):
        # Set the linear term c_j in the objective.
        task.putcj(j,c[j])

        # Set the bounds on variable j
        # blx[j] <= x_j <= bux[j] 
        task.putvarbound(j,bkx[j],blx[j],bux[j])

        # Input column j of A 
        task.putacol(j,                  # Variable (column) index.
                     asub[j],            # Row index of non-zeros in column j.
                     aval[j])            # Non-zero Values of column j. 

      # Set the bounds on constraints.
     # blc[i] <= constraint_i <= buc[i]
      for i in range(numcon):
          task.putconbound(i,bkc[i],blc[i],buc[i])
      task.putconboundslice(0,numcon, bkc,blc,buc);

      # Input the objective sense (minimize/maximize)
      task.putobjsense(mosek.objsense.maximize)
      
      # Solve the problem
      task.optimize()
      
      # Print a summary containing information
      # about the solution for debugging purposes
      task.solutionsummary(mosek.streamtype.msg)
      
      # Get status information about the solution
      solsta = task.getsolsta(mosek.soltype.bas)

      if (solsta == mosek.solsta.optimal or 
          solsta == mosek.solsta.near_optimal):
        xx = zeros(numvar, float)
        task.getxx(mosek.soltype.bas, # Request the basic solution. 
                   xx)
        print ("Optimal solution: ")
        for i in range(numvar):
           print ("x["+str(i)+"]="+str(xx[i]))
      elif (solsta == mosek.solsta.dual_infeas_cer or
            solsta == mosek.solsta.prim_infeas_cer or
            solsta == mosek.solsta.near_dual_infeas_cer or
            solsta == mosek.solsta.near_prim_infeas_cer):
        print("Primal or dual infeasibility certificate found.\n")
      elif solsta == mosek.solsta.unknown:
        print("Unknown solution status")
      else:
        print("Other solution status")

# call the main function
try:
    main ()
except mosek.Exception as e:
    print ("ERROR: %s" % str(e.errno))
    if e.msg is not None:
        print ("\t%s" % e.msg)
        sys.exit(1)
except:
    import traceback
    traceback.print_exc()
    sys.exit(1)
sys.exit(0)
