package com.mosek.example;

/*
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

   File:      mioinitsol.java

   Purpose:   Demonstrates how to solve a MIP with a start guess.

   Syntax:    mioinitsol
 */

 
import mosek.*;

class msgclass extends mosek.Stream {
    public msgclass ()
    {
        super ();
    }

    public void stream (String msg)
    {
        System.out.print (msg);
    }
}
 
public class mioinitsol
{
    public static void main (String[] args)
    {
        mosek.Env
            env = null;
        mosek.Task
            task = null;
        // Since the value infinity is never used, we define
        // 'infinity' symbolic purposes only
        double
            infinity = 0;

        int numvar = 4;
        int numcon = 1;

        double[] c = { 7.0, 10.0, 1.0, 5.0 };
        
        mosek.Env.boundkey[] bkc = {mosek.Env.boundkey.up};
        double[] blc = {-infinity};
        double[] buc = {2.5};
        mosek.Env.boundkey[] bkx
                  = {mosek.Env.boundkey.lo,
                     mosek.Env.boundkey.lo,
                     mosek.Env.boundkey.lo,
                     mosek.Env.boundkey.lo};
        double[] blx = {0.0,
                        0.0,
                        0.0,
                        0.0};
        double[] bux = {infinity,
                        infinity,
                        infinity,
                        infinity};
        
        int[]    ptrb   = {0, 1, 2, 3};
        int[]    ptre   = {1, 2, 3, 4};
        double[] aval   = {1.0, 1.0, 1.0, 1.0};
        int[]    asub   = {0,   0,   0,   0  };
        int[]    intsub = {0, 1, 2};
        mosek.Env.variabletype[] inttype={mosek.Env.variabletype.type_int,
                                          mosek.Env.variabletype.type_int,
                                          mosek.Env.variabletype.type_int};
        double[]    intxx={0.0,2,0,0,0};

        try{
            // Make mosek environment. 
            env  = new mosek.Env ();
            // Create a task object linked with the environment env.
            task = new mosek.Task (env, 0, 0);
            // Directs the log task stream to the user specified
            // method task_msg_obj.print
            msgclass task_msg_obj = new msgclass ();
            task.set_Stream (mosek.Env.streamtype.log,task_msg_obj);

            task.inputdata(numcon,numvar,
                           c, 0.0,
                           ptrb, ptre,
                           asub, aval,
                           bkc, blc, buc,
                           bkx, blx, bux);
                            
            task.putvartypelist(intsub,inttype);

            /* A maximization problem */ 
            task.putobjsense(mosek.Env.objsense.maximize);
                
            // Construct an initial feasible solution from the
            //     values of the integer valuse specified 
            task.putintparam(mosek.Env.iparam.mio_construct_sol,
                             mosek.Env.onoffkey.on.value);
        
            // Set status of all variables to unknown 
            //task.makesolutionstatusunknown(mosek.Env.soltype.itg);

            // Assign values 1,1,0 to integer variables 
            task.putxxslice(mosek.Env.soltype.itg, 0, 3, intxx);

            // solve   
            task.optimize(); 
        }
        catch (mosek.Exception e)
        /* Catch both Error and Warning */
        {
            System.out.println ("An error was encountered");
            System.out.println (e.getMessage ());
            throw e;
        }
        finally
        {
            if (task != null) task.dispose ();
            if (env  != null)  env.dispose ();
        }        
    }
}
