# 
# Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
# 
# File:      response.py
# 
# Purpose:   This examples demonstrates proper response handling.
# 

import mosek
import sys

def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()

def main(args):
  if len(args) < 1:
    print ("No input file specified")
    return
  else:
    print ("Inputfile: %s" % args[0])

  with mosek.Env() as env:
    with env.Task(0,0) as task:
      task.set_Stream (mosek.streamtype.log, streamprinter)
      
      task.readdata(args[0])
      e = None
      trmcode = None
      try:
        trmcode = task.optimize()
      except mosek.MosekException as err:
        e = err
      
      solsta = task.getsolsta(mosek.soltype.itr)

      if   solsta in [ mosek.solsta.optimal,
                       mosek.solsta.near_optimal ]:
        print ("An optimal basic solution is located.")
        task.solutionsummary(mosek.streamtype.log)
      elif solsta in [ mosek.solsta.dual_infeas_cer,
                       mosek.solsta.near_dual_infeas_cer ]:
        print ("Dual infeasibility certificate found.")
      elif solsta in [ mosek.solsta.prim_infeas_cerl,
                       mosek.solsta.near_prim_infeas_cer ]:
        printf("Primal infeasibility certificate found.\n");
      elif solsta == mosek.solsta.sta_unknown:
        # The solutions status is unknown. The termination code 
        # indicating why the optimizer terminated prematurely. 
        print ("The solution status is unknown.")
        if trmcode is not None:
          print ("Termination code: %s" % str(trmcode))
          #print mosek.getcodedesc(trmcode)
        elif e is not None:
          print ("Error:")
          print (e)
      else:
        print ("An unexpected solution status is obtained.")

if __name__ == '__main__':
  import sys
  main(sys.argv[1:])
