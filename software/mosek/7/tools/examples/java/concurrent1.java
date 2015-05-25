/*
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

   File:      concurrent1.java

   Purpose:   To demonstrate how to solve a problem 
              with the concurrent optimizer. 
 */
package com.mosek.example;

import mosek.*;

public class concurrent1
{
  public static void main (String[] args)
  {
    mosek.Env env = null;
    mosek.Task task = null;
    
    try
    {
      // Create mosek environment. 
      env  = new mosek.Env ();
      // Create a task object linked with the environment env.
      task = new mosek.Task (env, 0, 0);
      // Directs the log task stream to the user specified
      // method task_msg_obj.print
      task.set_Stream(
        mosek.Env.streamtype.log,
        new mosek.Stream() 
          { public void stream(String msg) { System.out.print(msg); }});
      task.readdata(args[0]);
      task.putintparam(mosek.Env.iparam.optimizer,
                       mosek.Env.optimizertype.concurrent.value);
      task.putintparam(mosek.Env.iparam.concurrent_num_optimizers,
                       2);

      task.optimize();

      task.solutionsummary(mosek.Env.streamtype.msg);
      System.out.println ("Done.");
    }
    catch (mosek.Exception e)
    /* Catch both mosek.Error and mosek.Warning */
    {
        System.out.println ("An error or warning was encountered");
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

