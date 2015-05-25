package com.mosek.example;
import mosek.Env;
/* 
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

   File:      sdo1.java

   Purpose:   Solves the following small semidefinite optimization problem 
              using the MOSEK API.

     minimize    Tr [2, 1, 0; 1, 2, 1; 0, 1, 2]*X + x0
 
     subject to  Tr [1, 0, 0; 0, 1, 0; 0, 0, 1]*X + x0           = 1
                 Tr [1, 1, 1; 1, 1, 1; 1, 1, 1]*X      + x1 + x2 = 0.5
                 (x0,x1,x2) \in Q,  X \in PSD
*/

public class sdo1 
{

  public static void main(String[] argv)
  {
    mosek.Env  env  = null;
    mosek.Task task = null;


    int    numcon      = 2;  /* Number of constraints.              */
    int    numvar      = 3;  /* Number of conic quadratic variables */
    int    numanz      = 3;  /* Number of non-zeros in A            */
    int    numbarvar   = 1;  /* Number of semidefinite variables    */
    int    dimbarvar[] = {3};         /* Dimension of semidefinite cone */
    int    lenbarvar[] = {3*(3+1)/2}; /* Number of scalar SD variables  */

    mosek.Env.boundkey bkc[] = { mosek.Env.boundkey.fx,
                                 mosek.Env.boundkey.fx };
    double[]     blc     = { 1.0, 0.5 };
    double[]     buc     = { 1.0, 0.5 };

    int[]        barc_i  = {0, 1, 1, 2, 2},
                 barc_j  = {0, 0, 1, 1, 2};
    double[]     barc_v  = {2.0, 1.0, 2.0, 1.0, 2.0};

    int[][]      asub    = {{0}, {1, 2}}; /* column subscripts of A */
    double[][]   aval    = {{1.0}, {1.0, 1.0}};

    int[][]      bara_i  = { {0,   1,   2},   {0,   1 ,  2,   1,   2,   2 } },
                 bara_j  = { {0,   1,   2},   {0,   0 ,  0,   1,   1,   2 } };
    double[][]   bara_v  = { {1.0, 1.0, 1.0}, {1.0, 1.0, 1.0, 1.0, 1.0, 1.0}};
    int[]        conesub = { 0, 1, 2};


    try
    {
      // Make mosek environment. 
      env  = new mosek.Env ();
      // Create a task object. 
      task = new mosek.Task (env, 0, 0);

      // Directs the log task stream to the user specified
      // method task_msg_obj.stream
      task.set_Stream(
        mosek.Env.streamtype.log,
        new mosek.Stream() 
          { public void stream(String msg) { System.out.print(msg); }});

      /* Append 'NUMCON' empty constraints.
         The constraints will initially have no bounds. */
      task.appendcons(numcon);

      /* Append 'NUMVAR' variables.
         The variables will initially be fixed at zero (x=0). */
      task.appendvars(numvar);

      /* Append 'NUMBARVAR' semidefinite variables. */
      task.appendbarvars(dimbarvar);

      /* Optionally add a constant term to the objective. */
      task.putcfix(0.0);

      /* Set the linear term c_j in the objective.*/
      task.putcj(0,1.0);

      for (int j = 0; j<numvar; ++j)
        task.putvarbound(j,mosek.Env.boundkey.fr,-0.0,0.0);

      /* Set the linear term barc_j in the objective.*/  
      {
        long[] idx = new long[1];
        double[] falpha = { 1.0 };
        idx[0] = task.appendsparsesymmat(dimbarvar[0],
                                         barc_i,
                                         barc_j,
                                         barc_v);
        task.putbarcj(0, idx, falpha); 
      }

      /* Set the bounds on constraints.
        for i=1, ...,numcon : blc[i] <= constraint i <= buc[i] */

      for(int i = 0; i < numcon; ++i)
        task.putconbound(i,           /* Index of constraint.*/
                         bkc[i],      /* Bound key.*/
                         blc[i],      /* Numerical value of lower bound.*/
                         buc[i]);     /* Numerical value of upper bound.*/

      /* Input A row by row */
      for (int i=0; i<numcon; ++i)
        task.putarow(i,
                     asub[i],
                     aval[i]);

      /* Append the conic quadratic cone */
      task.appendcone(mosek.Env.conetype.quad,
                      0.0,
                      conesub);

      /* Add the first row of barA */
      {
        long[] idx = new long[1];
        double[] falpha = {1.0};
        task.appendsparsesymmat(dimbarvar[0],
                                bara_i[0],
                                bara_j[0],
                                bara_v[0],
                                idx);

        task.putbaraij(0, 0, idx, falpha);
      }

      {
        long[] idx = new long[1];
        double[] falpha = {1.0};
        /* Add the second row of barA */
        task.appendsparsesymmat(dimbarvar[0],
                                bara_i[1],
                                bara_j[1],
                                bara_v[1],
                                idx);

        task.putbaraij(1, 0, idx, falpha);
      }

      /* Run optimizer */
      task.optimize();

      /* Print a summary containing information
         about the solution for debugging purposes*/
      task.solutionsummary (mosek.Env.streamtype.msg);

      mosek.Env.solsta[] solsta = new mosek.Env.solsta[1];
      task.getsolsta (mosek.Env.soltype.itr,solsta);

      switch(solsta[0])
      {
      case optimal:
      case near_optimal:
        double[] xx = new double[numvar];
        double[] barx = new double[lenbarvar[0]];

        task.getxx(mosek.Env.soltype.itr,xx);
        task.getbarxj(mosek.Env.soltype.itr,    /* Request the interior solution. */
                      0,
                      barx);
        System.out.println("Optimal primal solution");
        for(int i=0; i < numvar; ++i)
          System.out.println("x[" + i + "]   : " + xx[i]);

        for(int i=0; i<lenbarvar[0]; ++i)
          System.out.println("barx[" + i + "]: " + barx[i]);
        break;
      case dual_infeas_cer:
      case prim_infeas_cer:
      case near_dual_infeas_cer:
      case near_prim_infeas_cer:  
        System.out.println("Primal or dual infeasibility certificate found.");
        break;
      case unknown:
        System.out.println("The status of the solution could not be determined.");
        break;  
      default:
        System.out.println("Other solution status.");
        break;
      }
    }
    finally
    {
      if (task != null) task.dispose();
      if (env != null)  env.dispose();
    }
  }
}

