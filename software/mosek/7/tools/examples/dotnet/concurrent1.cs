/*
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

   File:      concurrent1.cs

   Purpose:   To demonstrate how to solve a problem 
              with the concurrent optimizer. 
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
    try
    {
      using (mosek.Env env = new mosek.Env())
      { 
        using (mosek.Task task = new mosek.Task(env))
        {
          // Directs the log task stream to the user specified
          // method task_msg_obj.streamCB
          task.set_Stream (mosek.streamtype.log, new msgclass ("[task]"));
          
          task.readdata(args[0]);
          task.putintparam(mosek.iparam.optimizer,
                           mosek.Val.optimizer_concurrent);
          task.putintparam(mosek.iparam.concurrent_num_optimizers,
                           2);
            
          task.optimize();
            
          task.solutionsummary(mosek.streamtype.msg);
        }
      }
    }
    catch (mosek.Exception e)
    {
      Console.WriteLine (e.Code);
      Console.WriteLine (e);
      throw;
    }
  }
}

 

