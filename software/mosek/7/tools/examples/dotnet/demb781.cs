/*
 * Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
 *
 * File:    demb781.cs
 *
 * Purpose: Demonstrates how to solve a simple non-liner separable problem
 * using the SCopt interface for C#. Then problem is this:
 *   Minimize   e^x2 + e^x3
 *   Such that  e^x4 + e^x5                        <= 1
 *                  x0 + x1 - x2                   = 0 
 *                - x0 - x1      - x3              = 0           
 *              0.5 x0                - x4         = 1.3862944
 *                       x1                  - x5  = 0               
 *             x0 ... x5 are unrestricted
 *
 */
namespace mosek
{
  namespace example
  {
    class msgclass : mosek.Stream 
    {
      public msgclass () { }
      public override void streamCB (string msg) { System.Console.Write ("{0}", msg); }
    }
    
    public class demb781
    {
      public static void Main(string[] args)
      {
        using (mosek.Env env = new mosek.Env())
        {
          using (mosek.Task task = new mosek.Task(env,0,0))
          {
            task.set_Stream( mosek.streamtype.log,new msgclass());
            int numvar = 6;
            int numcon = 5;
          

            mosek.boundkey[] 
              bkc = new mosek.boundkey[] { mosek.boundkey.up, 
                                           mosek.boundkey.fx, 
                                           mosek.boundkey.fx, 
                                           mosek.boundkey.fx, 
                                           mosek.boundkey.fx };
            double[] 
              blc = new double[] { 0.0, 0.0, 0.0, 1.3862944, 0.0 },
              buc = new double[] { 1.0, 0.0, 0.0, 1.3862944, 0.0 };

            mosek.boundkey[]
              bkx = new mosek.boundkey[] { mosek.boundkey.fr,
                                               mosek.boundkey.fr, 
                                               mosek.boundkey.fr, 
                                               mosek.boundkey.fr, 
                                               mosek.boundkey.fr, 
                                               mosek.boundkey.fr };
            double[]
              blx = new double[] { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }, 
              bux = new double[] { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };

            long[]
              aptrb = new long[] { 0, 0, 3, 6, 8 },
              aptre = new long[] { 0, 3, 6, 8, 10 };
            int[] 
              asubi = new int[] { 0, 1, 2, 3, 4 },
              asubj = new int[] { 0, 1, 2,
                                  0, 1, 3,
                                  0, 4,
                                  1, 5 };
            double[]
              aval = new double[] {  1.0,  1.0, -1.0,
                                    -1.0, -1.0, -1.0,
                                     0.5, -1.0,
                                     1.0, -1.0 };
            
            task.appendvars(numvar);
            task.appendcons(numcon);

            task.putobjsense(mosek.objsense.minimize);

            task.putvarboundslice(0, numvar, bkx, blx, bux);
            task.putconboundslice(0, numcon, bkc, blc, buc);

            task.putarowlist(asubi, aptrb, aptre, asubj, aval );

            mosek.scopr[]
              opro  = new mosek.scopr[] { mosek.scopr.exp, 
                                              mosek.scopr.exp };
            int[] 
              oprjo = new int[] { 2, 3 };
            double[]
              oprfo = new double[] { 1.0, 1.0 },
              oprgo = new double[] { 1.0, 1.0 },
              oprho = new double[] { 0.0, 0.0 };

            mosek.scopr[]
              oprc = new mosek.scopr[] { mosek.scopr.exp, 
                                             mosek.scopr.exp };
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
            task.solutionsummary(mosek.streamtype.msg); 
            double[] res = new double[numvar];
            task.getsolutionslice(mosek.soltype.itr,
                                  mosek.solitem.xx,
                                  0, numvar,
                                  res);

            System.Console.Write("Solution is: [ " + res[0]);
            for (int i = 1; i < numvar; ++i) System.Console.Write(", " + res[i]);
            System.Console.Write(" ]\n");
            
          }
        }
      }      
    }
  }
}

