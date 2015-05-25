package com.mosek.example;
     
/*
  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  File:      feasrepairex1.java

  Purpose:    To demonstrate how to use the MSK_relaxprimal function to
              locate the cause of an infeasibility.

  Syntax: On command line
          java  feasrepairex1.feasrepairex1 feasrepair.lp
          feasrepair.lp is located in mosek\<version>\tools\examples.
*/

import mosek.*;

public class feasrepairex1
{

  public static void main (String[] args)
  { 
    mosek.Env env = new mosek.Env();
    try
    {
      mosek.Task task = new mosek.Task(env,0,0);
      try
      {
        task.set_Stream(
          mosek.Env.streamtype.log,
          new mosek.Stream() 
            { public void stream(String msg) { System.out.print(msg); }});

        task.readdata(args[0]);

        task.putintparam(mosek.Env.iparam.log_feas_repair,3);

        task.primalrepair(null,null,null,null);

        double sum_viol = task.getdouinf(mosek.Env.dinfitem.primal_repair_penalty_obj);

        System.out.println("Minimized sum of violations = " + sum_viol);

        task.optimize();

        task.solutionsummary(mosek.Env.streamtype.msg);
      }
      finally
      {
        task.dispose();
      }
    }
    finally
    {
      env.dispose();
    }
  } 
}
    
