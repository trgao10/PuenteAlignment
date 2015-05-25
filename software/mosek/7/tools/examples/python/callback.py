##
#   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#   File:      callback.py
#
#   Purpose:   To demonstrate how to use the progress 
#              callback. 
#
#              Use this script as follows:
#              callback.py psim  25fv47.mps
#              callback.py dsim  25fv47.mps
#              callback.py intpnt 25fv47.mps
#
#              The first argument tells which optimizer to use
#              i.e. psim is primal simplex, dsim is dual simplex
#              and intpnt is interior-point. 
##
from __future__ import with_statement

import sys

import mosek
from mosek import *


def makeUserCallback(maxtime):
    def userCallback(caller,
                     douinf,
                     intinf,
                     lintinf):
        opttime = 0.0

        if   caller == callbackcode.begin_intpnt:
            print ("Starting interior-point optimizer")
        elif caller == callbackcode.intpnt:
            itrn    = intinf[iinfitem.intpnt_iter      ]
            pobj    = douinf[dinfitem.intpnt_primal_obj]
            dobj    = douinf[dinfitem.intpnt_dual_obj  ]
            stime   = douinf[dinfitem.intpnt_time      ]
            opttime = douinf[dinfitem.optimizer_time   ]

            print ("Iterations: %-3d" % itrn)
            print ("  Elapsed time: %6.2f(%.2f) " % (opttime,stime))
            print ("  Primal obj.: %-18.6e  Dual obj.: %-18.6e" % (pobj,dobj))
        elif caller == callbackcode.end_intpnt:
            print ("Interior-point optimizer finished.")
        elif caller == callbackcode.begin_primal_simplex:
            print ("Primal simplex optimizer started.")
        elif caller == callbackcode.update_primal_simplex:
            itrn    = intinf[iinfitem.sim_primal_iter  ]
            pobj    = douinf[dinfitem.sim_obj          ]
            stime   = douinf[dinfitem.sim_time         ]
            opttime = douinf[dinfitem.optimizer_time   ]
            
            print ("Iterations: %-3d" % itrn)
            print ("  Elapsed time: %6.2f(%.2f)" % (opttime,stime))
            print ("  Obj.: %-18.6e" % pobj )
        elif caller == callbackcode.end_primal_simplex:
            print ("Primal simplex optimizer finished.")
        elif caller == callbackcode.begin_dual_simplex:
            print ("Dual simplex optimizer started.")
        elif caller == callbackcode.update_dual_simplex:
            itrn    = intinf[iinfitem.sim_dual_iter    ]
            pobj    = douinf[dinfitem.sim_obj          ]
            stime   = douinf[dinfitem.sim_time         ]
            opttime = douinf[dinfitem.optimizer_time   ]
            print ("Iterations: %-3d" % itrn)
            print ("  Elapsed time: %6.2f(%.2f)" % (opttime,stime))
            print ("  Obj.: %-18.6e" % pobj)
        elif caller == callbackcode.end_dual_simplex:
            print ("Dual simplex optimizer finished.")
        elif caller == callbackcode.begin_bi:
            print ("Basis identification started.")
        elif caller == callbackcode.end_bi:
            print ("Basis identification finished.")
        else:
            pass

        if opttime >= maxtime:
            # mosek is spending too much time. Terminate it.
            return 1
      
        return 0
    return userCallback

def msgPrinter(msg):
    sys.stdout.write(msg)
    sys.stdout.flush()

def main(args):

  if len(args) < 3:
      print ("Too few input arguments. Syntax:")
      print ("\tcallback.py psim inputfile")
      print ("\tcallback.py dsim inputfile")
      print ("\tcallback.py intpnt inputfile")
      return 
  
  with mosek.Env() as env:
      with mosek.Task(env) as task:
          filename = args[2]
          task.readdata(filename)

          task.set_Stream(streamtype.log, msgPrinter)

          if   args[1] == 'psim':
              task.putintparam(iparam.optimizer,optimizertype.primal_simplex)
          elif args[1] == "dsim":
              task.putintparam(iparam.optimizer,optimizertype.dual_simplex)
          elif args[1] == "intpnt":
              task.putintparam(iparam.optimizer,optimizertype.intpnt)

          # Turn all MOSEK logging off (note that errors and other messages 
          # are still sent through the log stream)
          task.putintparam(iparam.log, 0)
        
          usercallback = makeUserCallback(maxtime = 3600)
          task.set_Progress(usercallback)

          task.optimize()

          task.solutionsummary(streamtype.msg)

if __name__ == '__main__':
    main(sys.argv)
