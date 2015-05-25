##
#    Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#    File:    milo1.py
#
#    Purpose:  Demonstrates how to solve a small mixed
#              integer linear optimization problem using the MOSEK Python API.
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

  bkc = [ mosek.boundkey.up, mosek.boundkey.lo  ]
  blc = [              -inf,              -4.0  ]
  buc = [             250.0,               inf  ]

  bkx = [ mosek.boundkey.lo, mosek.boundkey.lo  ]
  blx = [               0.0,               0.0  ]
  bux = [               inf,               inf  ]

  c   = [               1.0,               0.64 ]

  asub = [  array([0,   1]),    array([0,    1])   ]
  aval = [ array([50.0, 3.0]), array([31.0, -2.0]) ]

  numvar = len(bkx)
  numcon = len(bkc)

  # Append 'numcon' empty constraints.
  # The constraints will initially have no bounds. 
  task.appendcons(numcon)
     
  #Append 'numvar' variables.
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

  task.putconboundlist(range(numcon),bkc,blc,buc)
        
  # Input the objective sense (minimize/maximize)
  task.putobjsense(mosek.objsense.maximize)
       
  # Define variables to be integers
  task.putvartypelist([ 0, 1 ],
                      [ mosek.variabletype.type_int,
                        mosek.variabletype.type_int ])
        
  # Optimize the task
  task.optimize()

  # Print a summary containing information
  # about the solution for debugging purposes
  task.solutionsummary(mosek.streamtype.msg)

  prosta = task.getprosta(mosek.soltype.itg)
  solsta = task.getsolsta(mosek.soltype.itg)

  # X

  # Output a solution
  xx = zeros(numvar, float)
  task.getxx(mosek.soltype.itg,xx)

  if solsta in [ mosek.solsta.integer_optimal, mosek.solsta.near_integer_optimal ]:
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
    if prosta == mosek.prosta.prim_infeas_or_unbounded:
        print("Problem status Infeasible or unbounded.\n")
    elif prosta == mosek.prosta.prim_infeas:
        print("Problem status Infeasible.\n")
    elif prosta == mosek.prosta.unkown:
        print("Problem status unkown.\n")
    else:
        print("Other problem status.\n")
  else:
      print("Other solution status")

# call the main function
try:
    main ()
except mosek.Exception as msg:
    #print "ERROR: %s" % str(code)
    if msg is not None:
        print ("\t%s" % msg)
        sys.exit(1)
except:
    import traceback
    traceback.print_exc()
    sys.exit(1)
sys.exit(0)

