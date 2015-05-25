package com.mosek.example;
/*
  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  File:      response.java

  Purpose:   This examples demonstrates proper response handling.
*/

import mosek.*;



public class response
{
  public static void main(String[] argv)
  {
    if (argv.length < 1)
    {
      System.out.println("No input file specified");
    }
    else
    {
      mosek.Env  env  = null;
      mosek.Task task = null;

      try
      {
        // Make mosek environment. 
        env  = new mosek.Env ();

        // Create a task object. 
        task = new mosek.Task (env, 0, 0);

        // Directs the log task stream to the user specified
        // method task_msg_obj.stream
        task.set_Stream(
          Env.streamtype.log,
          new mosek.Stream() 
            { public void stream(String msg) { System.out.print(msg); }});

        task.readdata(argv[0]);

        Env.rescode trm = task.optimize();

        Env.solsta[] solsta = new Env.solsta[1]; task.getsolsta(Env.soltype.itr,solsta);
        switch( solsta[0] )
        {
          case optimal:   
          case near_optimal:
            System.out.println("An optimal basic solution is located.");

            task.solutionsummary(Env.streamtype.msg);
            break;
          case dual_infeas_cer:
          case near_dual_infeas_cer:
            System.out.println("Dual infeasibility certificate found.");
            break;
          case prim_infeas_cer:
          case near_prim_infeas_cer:
            System.out.println("Primal infeasibility certificate found.");
            break;
          case unknown:
          {
            StringBuffer symname = new StringBuffer();
            StringBuffer desc = new StringBuffer();

            /* The solutions status is unknown. The termination code 
               indicating why the optimizer terminated prematurely. */

            System.out.println("The solution status is unknown.");
            /* No system failure e.g. an iteration limit is reached.  */

            Env.getcodedesc(trm,symname,desc);
            System.out.printf("  Termination code: %s\n",symname);
            break;
          }
          default:
            System.out.println("An unexpected solution status is obtained.");
            break;
        }
      }
      finally
      {
        if (task != null) task.dispose();
        if (env != null) env.dispose();
      }
    }
  }
}

