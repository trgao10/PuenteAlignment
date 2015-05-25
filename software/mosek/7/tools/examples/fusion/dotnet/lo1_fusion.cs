//
// Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
//
// File:      lo1_fusion.cs
//
// Purpose: Demonstrates how to solve the problem
//
// minimize 3*x1 + 5*x2 + x3 + y
// such that
//          3*x1 + 2*x2        +   y = 30,
//          2*x1 + 3*x2 +   x3 +   y > 15,
//                      + 3*x3 + 2*y < 25
// and
//          x0,x1,x2 > 0,
//          0 < y < 10
//

using System;
using mosek.fusion;

namespace mosek
{
  namespace fusion
  {
    namespace example
    {
      public class lo1_fusion
      {
        public static void Main(string[] args)
        {
          double[][] A =
            { new double[] { 3.0, 2.0, 0.0, 1.0 },
              new double[] { 2.0, 3.0, 1.0, 1.0 },
              new double[] { 0.0, 0.0, 3.0, 2.0 } };
          double[] c = { 3.0, 5.0, 1.0, 1.0  };

          // Create a model with the name 'lo1'
          Model M = new Model("lo1");
            
          // Create variable 'x' of length 3
          Variable x = M.Variable("x", 3, Domain.GreaterThan(0.0));
          // Create variable 'y' of length 1
          Variable y = M.Variable("y", 1, Domain.InRange(0.0, 10.0));
          // Create a variable vector consisting of x and y
          Variable z = Variable.Vstack(x,y);
            
          // Create three constraints
          M.Constraint("c1", Expr.Dot(A[0], z), Domain.EqualsTo(30.0));
          M.Constraint("c2", Expr.Dot(A[1], z), Domain.GreaterThan(15.0));
          M.Constraint("c3", Expr.Dot(A[2], z), Domain.LessThan(25.0));
            
          // Set the objective function to (c^t * x)
          M.Objective("obj", ObjectiveSense.Maximize, Expr.Dot(c, z));
                  
          // Solve the problem
          M.Solve();
            
          // Get the solution values
          double[] sol = z.Level();
          Console.WriteLine("x1,x2,x3,y = {0}, {1}, {2}, {3}",sol[0],sol[1],sol[2],sol[3]);
        }
      }
    }
  }
}
   
