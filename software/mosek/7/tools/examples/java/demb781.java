package com.mosek.example;
/*
 * Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
 *
 * File:    demb781.java
 *
 * Purpose: Demonstrates how to solve a simple non-liner separable problem
 * using the SCopt interface for Java. Then problem is this:
 *
 *   Minimize   e^x2 + e^x3
 *   Such that  e^x4 + e^x5                        <= 1
 *                  x0 + x1 - x2                   = 0 
 *                - x0 - x1      - x3              = 0           
 *              0.5 x0                - x4         = 1.3862944
 *                       x1                  - x5  = 0               
 *             x0 ... x5 are unrestricted
 *
 */
public class demb781
{
  public static void main(String[] args)
  {
    mosek.Env env = null;
    mosek.Task task = null;
    
    try
    {
      env = new mosek.Env();
      task = new mosek.Task(env,0,0);
      task.set_Stream(
        mosek.Env.streamtype.log,
        new mosek.Stream() 
          { public void stream(String msg) { System.out.print(msg); }});
        
      int numvar = 6;
      int numcon = 5;
    

      mosek.Env.boundkey[]
        bkc = new mosek.Env.boundkey[] { mosek.Env.boundkey.up, 
                                         mosek.Env.boundkey.fx, 
                                         mosek.Env.boundkey.fx, 
                                         mosek.Env.boundkey.fx, 
                                         mosek.Env.boundkey.fx };
      double[] 
        blc = { 0.0, 0.0, 0.0, 1.3862944, 0.0 },
        buc = { 1.0, 0.0, 0.0, 1.3862944, 0.0 };

      mosek.Env.boundkey[]
        bkx = new mosek.Env.boundkey[] { mosek.Env.boundkey.fr,
                                         mosek.Env.boundkey.fr, 
                                         mosek.Env.boundkey.fr, 
                                         mosek.Env.boundkey.fr, 
                                         mosek.Env.boundkey.fr, 
                                         mosek.Env.boundkey.fr };
      double[]
        blx = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }, 
        bux = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };

      int[]
        aptrb = { 0, 0, 3, 6, 8 },
        aptre = { 0, 3, 6, 8, 10 };
      int[]
        asubi = { 0, 1, 2, 3, 4 },
        asubj = { 0, 1, 2,
                            0, 1, 3,
                            0, 4,
                            1, 5 };
      double[]
        aval  = {  1.0,  1.0, -1.0,
                  -1.0, -1.0, -1.0,
                   0.5, -1.0,
                   1.0, -1.0 };
      
      task.appendvars(numvar);
      task.appendcons(numcon);

      task.putobjsense(mosek.Env.objsense.minimize);

      task.putvarboundslice( 0, numvar, bkx, blx, bux);
      task.putconboundslice( 0, numcon, bkc, blc, buc);

      task.putarowlist(asubi, aptrb, aptre, asubj, aval );

      mosek.Env.scopr[]
        opro  = new mosek.Env.scopr[] { mosek.Env.scopr.exp, 
                                        mosek.Env.scopr.exp };
      int[] 
        oprjo = new int[] { 2, 3 };
      double[]
        oprfo = new double[] { 1.0, 1.0 },
        oprgo = new double[] { 1.0, 1.0 },
        oprho = new double[] { 0.0, 0.0 };

      mosek.Env.scopr[]
        oprc = new mosek.Env.scopr[] { mosek.Env.scopr.exp, 
                                       mosek.Env.scopr.exp };
      int[]
        opric = new int[] { 0, 0 },
        oprjc = new int[] { 4, 5 };
      double[]
        oprfc = new double[] { 1.0, 1.0 },
        oprgc = new double[] { 1.0, 1.0 },
        oprhc = new double[] { 0.0, 0.0 };

      task.putSCeval(opro, oprjo, oprfo, oprgo, oprho,
                     oprc, opric, oprjc, oprfc, oprgc, oprhc);

      task.optimize();

      double[] res = new double[numvar];
      task.getsolutionslice(mosek.Env.soltype.itr,
                            mosek.Env.solitem.xx,
                            0, numvar,
                            res);

      System.out.print("Solution is: [ " + res[0]);
      for (int i = 1; i < numvar; ++i) System.out.print(", " + res[i]);
      System.out.println(" ]");
    }
    catch (mosek.Exception e)
    {
      System.out.println ("An error/warning was encountered");
      System.out.println (e.toString());
      throw e;
    }
    finally
    {
      if (task != null) task.dispose();
      if (env  != null) env.dispose();
    }
  }      
}

