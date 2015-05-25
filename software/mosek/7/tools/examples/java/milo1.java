package com.mosek.example;

/*
  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  File:      milo1.java

  
   Purpose:   Demonstrates how to solve a small mixed
              integer linear optimization problem using the MOSEK Java API.
*/

public class milo1
{
  static final int numcon = 2;
  static final int numvar = 2;

  public static void main (String[] args)
  {
    // Since the value infinity is never used, we define
    // 'infinity' symbolic purposes only
    double infinity = 0;

    mosek.Env.boundkey[] bkc    
      = { mosek.Env.boundkey.up, mosek.Env.boundkey.lo };
    double[] blc = { -infinity,         -4.0 };
    double[] buc = { 250.0,             infinity }; 
      
    mosek.Env.boundkey[] bkx
        = { mosek.Env.boundkey.lo, mosek.Env.boundkey.lo  };
    double[] blx = { 0.0,               0.0 };
    double[] bux = { infinity,          infinity };
        
    double[] c   = {1.0, 0.64 };

    int[][] asub    = { {0,   1},    {0,    1}   };
    double[][] aval = { {50.0, 3.0}, {31.0, -2.0} };

    int[] ptrb = { 0, 2 };
    int[] ptre = { 2, 4 };
        
    double[] xx  = new double[numvar];
    
    mosek.Env env = null;
    mosek.Task task = null;
        
    try
      {
      // Make mosek environment. 
      env  = new mosek.Env ();
      // Create a task object linked with the environment env.
      task = new mosek.Task (env, 0, 0);
      // Directs the log task stream to the user specified
      // method task_msg_obj.stream
      task.set_Stream(
        mosek.Env.streamtype.log,
        new mosek.Stream() 
          { public void stream(String msg) { System.out.print(msg); }});
      /* Append 'numcon' empty constraints.
     The constraints will initially have no bounds. */
      task.appendcons(numcon);
      
      /* Append 'numvar' variables.
     The variables will initially be fixed at zero (x=0). */
      task.appendvars(numvar);
        
      for(int j=0; j<numvar; ++j)
      {
        /* Set the linear term c_j in the objective.*/  
        task.putcj(j,c[j]);
        /* Set the bounds on variable j.
           blx[j] <= x_j <= bux[j] */
          task.putvarbound(j,bkx[j],blx[j],bux[j]);
          /* Input column j of A */   
          task.putacol(j,                     /* Variable (column) index.*/
                       asub[j],               /* Row index of non-zeros in column j.*/
                       aval[j]);              /* Non-zero Values of column j. */
      }
      /* Set the bounds on constraints.
       for i=1, ...,numcon : blc[i] <= constraint i <= buc[i] */
      for(int i=0; i<numcon; ++i)
        task.putconbound(i,bkc[i],blc[i],buc[i]);

      /* Specify integer variables. */
      for(int j=0; j<numvar; ++j)
        task.putvartype(j,mosek.Env.variabletype.type_int);
      
      /* A maximization problem */ 
      task.putobjsense(mosek.Env.objsense.maximize);
      /* Solve the problem */
      try
        {
        task.optimize();
      }
      catch (mosek.Warning e)
      {
        System.out.println (" Mosek warning:");
        System.out.println (e.toString ());
      }

      // Print a summary containing information
      //   about the solution for debugging purposes
      task.solutionsummary(mosek.Env.streamtype.msg);
      task.getxx(mosek.Env.soltype.itg, // Integer solution.     
                 xx);
      mosek.Env.solsta solsta[] = new mosek.Env.solsta[1];
      /* Get status information about the solution */ 
      task.getsolsta(mosek.Env.soltype.itg,solsta);

      switch(solsta[0])
      {
      case integer_optimal:
      case near_integer_optimal:      
        System.out.println("Optimal solution\n");
        for(int j = 0; j < numvar; ++j)
          System.out.println ("x[" + j + "]:" + xx[j]);
        break;
      case prim_feas:
        System.out.println("Feasible solution\n");
        for(int j = 0; j < numvar; ++j)
          System.out.println ("x[" + j + "]:" + xx[j]);
        break;
        
      case unknown:
        mosek.Env.prosta prosta[] = new mosek.Env.prosta[1];
        task.getprosta(mosek.Env.soltype.itg,prosta);
        switch(prosta[0])
        {
        case prim_infeas_or_unbounded:
          System.out.println("Problem status Infeasible or unbounded");
          break;
        case prim_infeas:
          System.out.println("Problem status Infeasible.");
          break;
        case unknown:
          System.out.println("Problem status unknown.");
          break;
        default:
          System.out.println("Other problem status.");
          break;
        }
        break;
      default:
        System.out.println("Other solution status");
        break;
      }
    }
    catch (mosek.Exception e)
    {
      System.out.println ("An error or warning was encountered");
      System.out.println (e.getMessage ());
      throw e;
    }
    
    if (task != null) task.dispose ();
    if (env  != null)  env.dispose ();
  }
}
 
