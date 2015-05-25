package com.mosek.example;
import mosek.Stream;

/*
  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  File     :  solvelinear.java
 
  Purpose  :  To demonstrate the usage of MSK_solvewithbasis
              when solving the linear system:
               
  1.0  x1             = b1
  -1.0  x0  +  1.0  x1 = b2

  with two different right hand sides

  b = (1.0, -2.0)

  and

  b = (7.0, 0.0)
*/

public class solvelinear
{
    static public void put_a(
        mosek.Task task,
        double[][] aval,
        int[][]    asub,
        int[]      ptrb,
        int[]      ptre,
        int        numvar,
        int[]      basis )
    {
      // Since the value infinity is never used, we define
      // 'infinity' symbolic purposes only
      double
        infinity = 0;
      
      mosek.Env.stakey[] skx = new mosek.Env.stakey [numvar];
      mosek.Env.stakey[] skc = new mosek.Env.stakey [numvar];
      
      for (int i=0;i<numvar ;++i)
      {
        skx[i] = mosek.Env.stakey.bas;
        skc[i] = mosek.Env.stakey.fix;
      }
      
      task.appendvars(numvar);
      task.appendcons(numvar);
      
      for (int i=0;i<numvar ;++i)
        task.putacol(i,
                     asub[i],
                     aval[i]);

      for (int i=0 ; i<numvar ;++i)
        task.putconbound(
                      i,
                      mosek.Env.boundkey.fx,
                      0.0,
                      0.0);

      for (int i=0 ; i<numvar ;++i)
        task.putvarbound(
                      i,
                      mosek.Env.boundkey.fr,
                      -infinity,
                      infinity);

      //task.makesolutionstatusunknown(mosek.soltype.bas);
      

      /* Define a basic solution by specifying
         status keys for variables & constraints. */ 

      for (int i=0 ; i<numvar ;++i)
        task.putsolutioni (
                           mosek.Env.accmode.var,
                           i,  
                           mosek.Env.soltype.bas, 
                           skx[i],     
                           0.0,
                           0.0,
                           0.0,
                           0.0);
      
      for (int i=0 ; i<numvar ;++i)
        task.putsolutioni (
                           mosek.Env.accmode.con,
                           i,
                           mosek.Env.soltype.bas,       
                           skc[i], 
                           0.0,
                           0.0,
                           0.0,
                           0.0);
      
      
      
      task.initbasissolve(basis);    
    }
    
  public static void main (String[] argv)
  {
    int numcon = 2;
    int numvar = 2;

    double[][] aval = { { -1.0 },
                        {  1.0, 1.0 } };
    int[][]    asub = { {  1},
                        {  0,   1   } };
    int []      ptrb  = new int[] {0,1};
    int []      ptre  = new int[] {1,3};

    int[]       bsub  = new int[numvar];
    double[]    b     = new double[numvar];
    int[]       basis = new int[numvar];
    
    mosek.Task task = null;
    mosek.Env  env  = null;
        
    try
    {
      // Make mosek environment. 
      env  = new mosek.Env ();
      // Create a task object linked with the environment env.
      task = new mosek.Task (env, numcon,numvar);
      // Directs the log task stream to the user specified
      // method task_msg_obj.streamCB
      task.set_Stream(
        mosek.Env.streamtype.log,
        new mosek.Stream() 
          { public void stream(String msg) { System.out.print(msg); }});


      /* Put A matrix and factor A.
         Call this function only once for a given task. */ 

      put_a(
            task,
            aval,
            asub,
            ptrb,
            ptre,
            numvar,
            basis
            );

      /* now solve rhs */
      b[0] = 1;
      b[1] = -2;
      bsub[0] = 0;
      bsub[1] = 1;
      int[] nz_ = { 2 };
      task.solvewithbasis(0,nz_,bsub,b);
      int nz = nz_[0];
      System.out.println("\nSolution to Bx = b:\n");
      
      /* Print solution and show correspondents
         to original variables in the problem */
      for (int i=0;i<nz;++i) 
      {    
        if (basis[bsub[i]] < numcon)
          System.out.println ("This should never happen");
        else   
          System.out.println("x" + (basis[bsub[i]] - numcon) + " = " + b[bsub[i]]);   
      }
      
      b[0] = 7;
      bsub[0] = 0;
      nz_[0] = 1;
      task.solvewithbasis(0,nz_,bsub,b);
      nz = nz_[0];
      
      System.out.println ("\nSolution to Bx = b:\n");
      /* Print solution and show correspondents
         to original variables in the problem */
      for (int i=0;i<nz;++i) 
      {    
        if (basis[bsub[i]] < numcon)
          System.out.println("This should never happen");
        else   
          System.out.println("x" + (basis[bsub[i]] - numcon) + " = " + b[bsub[i]] );   
      }   
    }
    finally
    {
      if (task != null) task.dispose ();
      if (env  != null)  env.dispose ();
    }
  }
}
