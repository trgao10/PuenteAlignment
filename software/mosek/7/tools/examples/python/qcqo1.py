#
#  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#  File:    qcqo1.py
#
#  Purpose: Demonstrates how to solve small linear
#           optimization problem using the MOSEK Python API.
##

import sys

import mosek
# If numpy is installed, use that, otherwise use the 
# Mosek's array module.
try:
    from numpy import array,zeros,ones
except ImportError:
    from mosek.array import array, zeros, ones

# Since the actual value of Infinity is ignores, we define it solely
# for symbolic purposes:
inf = 0.0

# Define a stream printer to grab output from MOSEK
def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()

# We might write everything directly as a script, but it looks nicer
# to create a function.
def main ():
  # Make a MOSEK environment
  env = mosek.Env ()
  # Attach a printer to the environment
  env.set_Stream (mosek.streamtype.log, streamprinter)
  
  # Create a task
  task = env.Task(0,0)
  # Attach a printer to the task
  task.set_Stream (mosek.streamtype.log, streamprinter)
  

  # Set up and input bounds and linear coefficients
  bkc   = [ mosek.boundkey.lo ]
  blc   = [ 1.0 ]
  buc   = [ inf ]
    
  bkx   = [ mosek.boundkey.lo,
            mosek.boundkey.lo,
            mosek.boundkey.lo ]
  blx   = [ 0.0,  0.0, 0.0 ]
  bux   = [ inf,  inf, inf ]

  c     = [ 0.0, -1.0, 0.0 ]

  asub  = [   array([0]),   array([0]),   array([0]) ]
  aval  = [  array([1.0]),  array([1.0]),  array([1.0]) ]
  
  numvar = len(bkx)
  numcon = len(bkc)
  NUMANZ = 3
  # Append 'numcon' empty constraints.
  # The constraints will initially have no bounds. 
  task.appendcons(numcon)
     
  #Append 'numvar' variables.
  # The variables will initially be fixed at zero (x=0). 
  task.appendvars(numvar)

  #Optionally add a constant term to the objective. 
  task.putcfix(0.0)

  for j in range(numvar):
    # Set the linear term c_j in the objective.
    task.putcj(j,c[j])
    # Set the bounds on variable j
    # blx[j] <= x_j <= bux[j] 
    task.putbound(mosek.accmode.var,j,bkx[j],blx[j],bux[j])
    # Input column j of A 
    task.putacol(j,                  # Variable (column) index.
                 asub[j],            # Row index of non-zeros in column j.
                 aval[j])            # Non-zero Values of column j. 

  for i in range(numcon):
    task.putbound(mosek.accmode.con,i,bkc[i],blc[i],buc[i])
       
  # Set up and input quadratic objective

  qsubi = [ 0,   1,    2,   2   ]
  qsubj = [ 0,   1,    0,   2   ]
  qval  = [ 2.0, 0.2, -1.0, 2.0 ]

  task.putqobj(qsubi,qsubj,qval)

  # The lower triangular part of the Q^0
  # matrix in the first constraint is specified.
  # This corresponds to adding the term
  # - x0^2 - x1^2 - 0.1 x2^2 + 0.2 x0 x2

  qsubi = [  0,    1,    2,   2   ]
  qsubj = [  0,    1,    2,   0   ]
  qval  = [ -2.0, -2.0, -0.2, 0.2 ]

  # put Q^0 in constraint with index 0. 

  task.putqconk (0, qsubi,qsubj, qval); 

  # Input the objective sense (minimize/maximize)
  task.putobjsense(mosek.objsense.minimize)
       
  # Optimize the task
  task.optimize()

  # Print a summary containing information
  # about the solution for debugging purposes
  task.solutionsummary(mosek.streamtype.msg)

  prosta = task.getprosta(mosek.soltype.itr)
  solsta = task.getsolsta(mosek.soltype.itr)

  # Output a solution
  xx = zeros(numvar, float)
  task.getxx(mosek.soltype.itr,
                        xx)

  if solsta == mosek.solsta.optimal or solsta == mosek.solsta.near_optimal:
      print("Optimal solution: %s" % xx)
  elif solsta == mosek.solsta.dual_infeas_cer: 
      print("Primal or dual infeasibility.\n")
  elif solsta == mosek.solsta.prim_infeas_cer:
      print("Primal or dual infeasibility.\n")
  elif solsta == mosek.solsta.near_dual_infeas_cer:
      print("Primal or dual infeasibility.\n")
  elif  solsta == mosek.solsta.near_prim_infeas_cer:
      print("Primal or dual infeasibility.\n")
  elif mosek.solsta.unknown:
    print("Unknown solution status")
  else:
    print("Other solution status")
    
# call the main function
try:
    main ()
except mosek.Exception as e:
    print ("ERROR: %s" % str(code))
    if msg is not None:
        print ("\t%s" % e.msg)
        sys.exit(1)
except:
    import traceback
    traceback.print_exc()
    sys.exit(1)
sys.exit(0)
