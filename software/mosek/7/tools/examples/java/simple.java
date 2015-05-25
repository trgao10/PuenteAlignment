/*
  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  File:    simple.java

  Purpose: Demonstrates a very simple example using MOSEK by
  reading a problem file, solving the problem and
  writing the solution to a file.
*/

package com.mosek.example;
  
import mosek.*;

public class simple
{
  public static void main (String[] args)
  {
    mosek.Env   env = null;
    mosek.Task task = null;

    if (args.length == 0)
    {
      System.out.println ("Missing argument, syntax is:");
      System.out.println ("  simple inputfile [ solutionfile ]");
    }
    else
    {
      try
      {
        // Create the mosek environment.
        env = new mosek.Env ();

        // Create a task object linked with the environment env.
        // We create it with 0 variables and 0 constraints initially,
        // since we do not know the size of the problem.
        task = new mosek.Task (env, 0, 0);
        task.set_Stream (mosek.Env.streamtype.log, 
                         new mosek.Stream() 
                         { 
                           public void stream(String msg) { System.out.print(msg); }
                         });
        // We assume that a problem file was given as the first command
        // line argument (received in `args')
        task.readdata (args[0]);

        // Solve the problem
        task.optimize ();

        // Print a summary of the solution
        task.solutionsummary (mosek.Env.streamtype.log);

        // If an output file was specified, write a solution
        if (args.length >= 2)
        {
          // We define the output format to be OPF, and tell MOSEK to
          // leave out parameters and problem data from the output file.
          task.putintparam (mosek.Env.iparam.write_data_format,    mosek.Env.dataformat.op.value);
          task.putintparam (mosek.Env.iparam.opf_write_solutions,  mosek.Env.onoffkey.on.value);
          task.putintparam (mosek.Env.iparam.opf_write_hints,      mosek.Env.onoffkey.off.value);
          task.putintparam (mosek.Env.iparam.opf_write_parameters, mosek.Env.onoffkey.off.value);
          task.putintparam (mosek.Env.iparam.opf_write_problem,    mosek.Env.onoffkey.off.value);

          task.writedata (args[1]);
        }
      }
      finally
      {
        // Dispose of task and environment
        if (task != null) task.dispose ();
        if (env  != null)  env.dispose ();
      }
    }
  }
}
