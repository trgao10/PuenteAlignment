package com.mosek.example;
//
//   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
//
//   File:      callback.java
//
//   Purpose:   To demonstrate how to use the progress 
//              callback. 
//
//              Use this script as follows:
//              callback psim  25fv47.mps
//              callback dsim  25fv47.mps
//              callback intpnt 25fv47.mps
//
//              The first argument tells which optimizer to use
//              i.e. psim is primal simplex, dsim is dual simplex
//              and intpnt is interior-point. 
//

import mosek.*;
import java.util.Formatter;

public class callback
{
    private static Progress makeUserCallback(final double maxtime)
    {
      return new Progress() 
      {
          public int progress(int code, 
                              double[] douinf,
                              int[]    intinf,
                              long[]   lintinf)
          {
            Env.callbackcode caller = Env.callbackcode.fromValue(code);
            double opttime = 0.0;
            int itrn;
            double pobj, dobj, stime;

            Formatter f = new Formatter(System.out);
            switch (caller)
            {
              case begin_intpnt:
                  f.format("Starting interior-point optimizer");
              case intpnt:
                  itrn    = intinf[Env.iinfitem.intpnt_iter.value      ];
                  pobj    = douinf[Env.dinfitem.intpnt_primal_obj.value];
                  dobj    = douinf[Env.dinfitem.intpnt_dual_obj.value  ];
                  stime   = douinf[Env.dinfitem.intpnt_time.value      ];
                  opttime = douinf[Env.dinfitem.optimizer_time.value   ];

                  f.format("Iterations: %-3d",itrn);
                  f.format("Time: %6.2f(%.2f) ",opttime,stime);
                  f.format("Primal obj.: %-18.6e  Dual obj.: %-18.6e",pobj,dobj);
              case end_intpnt:
                  f.format("Interior-point optimizer finished.");
              case begin_primal_simplex:
                  f.format("Primal simplex optimizer started.");
              case update_primal_simplex:
                  itrn    = intinf[Env.iinfitem.sim_primal_iter.value  ];
                  pobj    = douinf[Env.dinfitem.sim_obj.value          ];
                  stime   = douinf[Env.dinfitem.sim_time.value         ];
                  opttime = douinf[Env.dinfitem.optimizer_time.value   ];
            
                  f.format("Iterations: %-3d", itrn);
                  f.format("  Elapsed time: %6.2f(%.2f)",opttime,stime);
                  f.format("Obj.: %-18.6e", pobj );
              case end_primal_simplex:
                  f.format("Primal simplex optimizer finished.");
              case begin_dual_simplex:
                  f.format("Dual simplex optimizer started.");
              case update_dual_simplex:
                  itrn    = intinf[Env.iinfitem.sim_dual_iter.value    ];
                  pobj    = douinf[Env.dinfitem.sim_obj.value          ];
                  stime   = douinf[Env.dinfitem.sim_time.value         ];
                  opttime = douinf[Env.dinfitem.optimizer_time.value   ];
                  f.format("Iterations: %-3d", itrn);
                  f.format("  Elapsed time: %6.2f(%.2f)",opttime,stime);
                  f.format("Obj.: %-18.6e", pobj);
              case end_dual_simplex:
                  f.format("Dual simplex optimizer finished.");
              case begin_bi:
                  f.format("Basis identification started.");
              case end_bi:
                  f.format("Basis identification finished.");
              default:
            }
            System.out.flush();
            if (opttime >= maxtime)
              // mosek is spending too much time. Terminate it.
              return 1;
            
            return 0;
          }
      };
    }

    public static void main(String[] args)
    {
      if (args.length < 2)
      {
        for (int i=0;i<args.length;++i)
        {
          System.out.println(args[i]);
        }
        
        System.out.println("Too few input arguments. Syntax:");
        System.out.println("\tcallback.py psim inputfile");
        System.out.println("\tcallback.py dsim inputfile");
        System.out.println("\tcallback.py intpnt inputfile");
      }
      else
      {
        Env env = null;
        Task task = null;
        try
        {
          String filename = args[1];
          env = new Env();
          task = new Task(env,0,0);

          task.set_Stream(
            mosek.Env.streamtype.log,
            new mosek.Stream() 
            { public void stream(String msg) { System.out.print(msg); }});

          task.readdata(filename);                    

          if   (args[0] == "psim")
            task.putintparam(Env.iparam.optimizer,Env.optimizertype.primal_simplex.value);
          else if (args[0] == "dsim")            
            task.putintparam(Env.iparam.optimizer,Env.optimizertype.dual_simplex.value);
          else if (args[0] == "intpnt")
            task.putintparam(Env.iparam.optimizer,Env.optimizertype.intpnt.value);

          // Turn all MOSEK logging off (note that errors and other messages 
          // are still sent through the log stream)
          task.putintparam(Env.iparam.log, 0);
        
          task.set_Progress(makeUserCallback(3600));
          
          task.optimize();
          task.putintparam(Env.iparam.log, 1);
          task.solutionsummary(Env.streamtype.msg);

        }
        catch (mosek.Exception e)
        {
          System.out.println ("An error/warning was encountered");
          System.out.println (e.toString());
          throw e;
        }
        finally 
        {
          if (task != null)
            task.dispose();
          if (env != null)
            env.dispose();
        }
      }
   }
}