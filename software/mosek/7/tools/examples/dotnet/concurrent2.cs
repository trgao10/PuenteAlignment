/*
 * Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
 *
 * File:      concurrent2.cs
 *
 * Purpose:   To demonstrate a more flexible interface for concurrent optimization. 
*/

using System;

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

public class concurrent1
{
  
  public static void Main (String[] args)
    {
      mosek.Env
        env = null;
      mosek.Task
        task = null;
      mosek.Task[]
        task_list = new mosek.Task[] { null };
            
      try
        {
          // Create mosek environment. 
          env  = new mosek.Env ();
          // Create a task object linked with the environment env.
          task = new mosek.Task (env, 0,0);
          // Directs the log task stream to the user specified
          // method task_msg_obj.streamCB
          task.set_Stream (mosek.streamtype.log, new msgclass ("simplex: "));

          task_list[0] = new mosek.Task (env, 0,0);
          task_list[0].set_Stream (mosek.streamtype.log, new msgclass ("intrpnt: "));

          task.readdata(args[0]);

          // Assign different parameter values to each task. 
          // In this case different optimizers. 
          task.putintparam(mosek.iparam.optimizer,
                           mosek.optimizertype.primal_simplex);
  
          task_list[0].putintparam(mosek.iparam.optimizer,
                                   mosek.optimizertype.intpnt);
  

          // Optimize task and task_list[0] in parallel.
          // The problem data i.e. C, A, etc. 
          // is copied from task to task_list[0].
          task.optimizeconcurrent(task_list);
          
          task.solutionsummary(mosek.streamtype.log);
        }
      catch (mosek.Exception e)
      {
        Console.WriteLine (e.Code);
        Console.WriteLine (e);
      }
          
      if (task != null) task.Dispose ();
      if (env  != null)  env.Dispose ();
          
    }
}
