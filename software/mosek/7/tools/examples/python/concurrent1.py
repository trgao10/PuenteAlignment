##
#   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#   File:    concurrent1.py
#
#   Purpose: To demonstrate how to optimize in parallel using the
#            concurrent optimizer.
##


import sys

import mosek

from mosek.array import array


# Since the actual value of Infinity is ignores, we define it solely
# for symbolic purposes:
inf = 0.0

# Define a stream printer to grab output from MOSEK
def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()


# We might write everything directly as a script, but it looks nicer
# to create a function.
def main (args):
    # Open MOSEK and create an environment and task
    # Create a MOSEK environment
    env = mosek.Env ()
    # Attach a printer to the environment
    env.set_Stream (mosek.streamtype.log, streamprinter)

    # Create a task
    task = env.Task(0,0)
    # Attach a printer to the task
    task.set_Stream (mosek.streamtype.log, streamprinter)

    task.readdata(args[0])
    task.putintparam(mosek.iparam.optimizer,
                     mosek.optimizertype.concurrent)

    task.putintparam(mosek.iparam.concurrent_num_optimizers, 2)
            
    task.optimize()
            
    task.solutionsummary(mosek.streamtype.msg)

# call the main function
try:
    main (sys.argv[1:])
except mosek.Exception as e:
    print ("ERROR: %s" % str(e.code))
    if msg is not None:
        print ("\t%s" % e.msg)
    sys.exit(1)
except:
    import traceback
    traceback.print_exc()
    sys.exit(1)

sys.exit(0)

