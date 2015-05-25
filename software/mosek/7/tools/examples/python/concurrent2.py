##
#  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
# 
#  File:      concurrent2.py
# 
#  Purpose:   To demonstrate a more flexible interface for concurrent optimization. 
##


import sys

import mosek

from mosek.array import array 

# Since the actual value of Infinity is ignores, we define it solely
# for symbolic purposes:
inf = 0.0

# Define a stream printer to grab output from MOSEK
class streamprinter:
    def __init__(self,prefix):
        self.prefix = str(prefix)
    def __call__(self,text):
        #sys.stdout.write (self.prefix + text)
        sys.stdout.write (self.prefix + text)
        sys.stdout.flush()
        pass

# We might write everything directly as a script, but it looks nicer
# to create a function.
def main (args):
    # Open MOSEK and create an environment and task
    # Create a MOSEK environment
    env = mosek.Env ()
    # Attach a printer to the environment
    env.set_Stream (mosek.streamtype.log, streamprinter("[env]"))

    # Create a task
    task = env.Task(0,0)
    # Attach a printer to the task
    task.set_Stream (mosek.streamtype.log, streamprinter("simplex: "))

    # Create a task
    task_list = [env.Task(0,0)]
    # Attach a printer to the task
    task_list[0].set_Stream(mosek.streamtype.log, streamprinter("intpnt: "))

    task.readdata(args[0]);

    # Assign different parameter values to each task. 
    # In this case different optimizers. 
    task.putintparam(mosek.iparam.optimizer,
                           mosek.optimizertype.primal_simplex)
  
    task_list[0].putintparam(mosek.iparam.optimizer,
                             mosek.optimizertype.intpnt)
    

    # Optimize task and task_list[0] in parallel.
    # The problem data i.e. C, A, etc. 
    # is copied from task to task_list[0].
    task.optimizeconcurrent(task_list)
    
    task.solutionsummary(mosek.streamtype.log)


# call the main function
try:
    main (sys.argv[1:])
except mosek.Exception as e:
    print ("ERROR: %s" % str(e.errno))
    if e.msg is not None:
        print ("\t%s" % e.msg)
    sys.exit(1)
except:
    import traceback
    traceback.print_exc()
    sys.exit(1)

 

