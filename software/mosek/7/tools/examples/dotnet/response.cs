
/*
  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  File:      response.cs

  Purpose:   This examples demonstrates proper response handling.
*/

using System;
using mosek;
using System.Text;

class msgclass : mosek.Stream 
{
  public msgclass () {}
  
  public override void streamCB (string msg)
  {
    Console.Write ("{0}", msg);
  }
}

public class response
{
  public static void Main(string[] argv)
  {
    if (argv.Length < 1)
    {
      Console.WriteLine("No input file specified");
    }
    else
    {
      using (Env env = new Env())
      {
        using (Task task = new Task(env,0,0))
        {
        
          // Directs the log task stream to the user specified
          // method task_msg_obj.stream
          task.set_Stream (streamtype.log, new msgclass ());

          task.readdata(argv[0]);

          rescode trm = task.optimize();

          solsta solsta; task.getsolsta(soltype.itr,out solsta);
          switch( solsta )
          {
            case solsta.optimal:   
            case solsta.near_optimal:
              Console.WriteLine("An optimal basic solution is located.");

              task.solutionsummary(streamtype.msg);
              break;
            case solsta.dual_infeas_cer:
            case solsta.near_dual_infeas_cer:
              Console.WriteLine("Dual infeasibility certificate found.");
              break;
            case solsta.prim_infeas_cer:
            case solsta.near_prim_infeas_cer:
              Console.WriteLine("Primal infeasibility certificate found.");
              break;
            case solsta.unknown:
            {
              StringBuilder symname = new StringBuilder();
              StringBuilder desc = new StringBuilder();

              /* The solutions status is unknown. The termination code 
                 indicating why the optimizer terminated prematurely. */

              Console.WriteLine("The solution status is unknown.");
              /* No system failure e.g. an iteration limit is reached.  */

              Env.getcodedesc(trm,symname,desc);
              Console.WriteLine("  Termination code: %{0}",symname);
              break;
            }
            default:
              Console.WriteLine("An unexpected solution status is obtained.");
              break;
          }
        }
      }
    }
  }
}

