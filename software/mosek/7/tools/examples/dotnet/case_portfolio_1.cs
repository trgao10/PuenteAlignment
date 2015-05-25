using System;

/*
  File : case_portfolio_1.cs

  Copyright : Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  Description :  Implements a basic portfolio optimization model.
*/


class msgclass : mosek.Stream  
{ 
  string prefix; 
  public msgclass (string prfx)  
  { 
    prefix = prfx; 
  } 
   
  public override void streamCB (string msg) 
  { 
    Console.Write ("{0}{1}", prefix,msg); 
  } 
} 


public class case_portfolio_1
{

    public static void Main (String[] args)
    {

        const int n = 3;

        // Since the value infinity is never used, we define
        // 'infinity' symbolic purposes only
        double infinity = 0.0;
        double gamma = 0.05;
        double[]   mu = {0.1073,  0.0737,  0.0627};
        double[,] GT={
            {0.1667,  0.0232,  0.0013},
            {0.0000,  0.1033, -0.0022},
            {0.0000,  0.0000,  0.0338}
        };
        double[] x0 = {0.0, 0.0, 0.0};
        double   w = 1.0;

        int numvar = 2*n +1;
        int numcon = n+1;


        //Offset of variables into the API variable.  
        int offsetx = 0;
        int offsets = n;
        int offsett = n+1;

        // Make mosek environment. 
        using (mosek.Env env = new mosek.Env()) 
        {   
            // Create a task object. 
            using (mosek.Task task = new mosek.Task(env,0,0)) 
            { 
                // Directs the log task stream to the user specified 
                // method msgclass.streamCB 
                task.set_Stream (mosek.streamtype.log, new msgclass ("")); 

                
                //Constraints.
                task.appendcons(numcon);
                for( int i=1; i<=n; ++i)
                    {
                        w+=x0[i-1];
                        task.putconbound(i, mosek.boundkey.fx, infinity,infinity);
                        task.putconname(i,"GT["+i+"]");
                    }
                task.putconbound(0, mosek.boundkey.fx,w,w);
                task.putconname(0,"budget");

                //Variables.
                task.appendvars(numvar);

                int[] xindx={offsetx+0,offsetx+1,offsetx+2};
                task.putclist(xindx,mu);

                for( int i=0; i<n; ++i)
                    {
                        for( int j=i; j<n;++j)
                            task.putaij(i+1,offsetx+j, GT[i,j]); 

                        task.putaij(i+1, offsett+i,-1.0);

                        task.putvarbound(offsetx+i, mosek.boundkey.lo,infinity,infinity);

                        task.putvarname(offsetx+i,"x["+(i+1)+"]");
                        task.putvarname(offsett+i,"t["+(i+1)+"]");
                        task.putvarbound(offsett+i, mosek.boundkey.fr,infinity,infinity);
                    }
                task.putvarbound(offsets, mosek.boundkey.fx,gamma,gamma);
                task.putvarname(offsets,"s");

                double[] e={1.0,1.0,1.0};
                task.putarow(0,xindx,e);

                //Cones.
                int[] csub = {offsets,offsett+0,offsett+1,offsett+2};
                task.appendcone( mosek.conetype.quad, 
                                 0.0, /* For future use only, can be set to 0.0 */
                                 csub);
                task.putconename(0,"stddev");

                /* A maximization problem */ 
                task.putobjsense(mosek.objsense.maximize);

                task.solutionsummary(mosek.streamtype.log);

                task.writedata("dump.opf");

                task.optimize();


                double expret=0.0,stddev=0.0;
                double[] xx = new double[numvar];

                task.getxx(mosek.soltype.itr,xx);
                for(int j=0; j<n; ++j)  
                    expret += mu[j]*xx[j+offsetx];

                Console.WriteLine("\neglected return {0:E} for gamma {1:E}\n",expret, xx[offsets]); 
            }
        }  
    }
}       
