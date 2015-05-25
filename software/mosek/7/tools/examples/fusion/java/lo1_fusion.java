package com.mosek.fusion.examples;
//
// Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
//
// File:      lo1_fusion.java
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
import mosek.fusion.*;

public class lo1_fusion
{
    public static void main(String[] args) 
      throws SolutionError
    {
        double[][] A = 
            { { 3.0, 2.0, 0.0, 1.0 },
              { 2.0, 3.0, 1.0, 1.0 },
              { 0.0, 0.0, 3.0, 2.0 } };
        double[] c = { 3.0, 5.0, 1.0, 1.0  };
        
        // Create a model with the name 'lo1'
        Model M = new Model("lo1");
        try
        {
          // Create variable 'x' of length 3
          Variable x = M.variable("x", 3, Domain.greaterThan(0.0));
          // Create variable 'y' of length 1
          Variable y = M.variable("y", 1, Domain.inRange(0.0, 10.0));
          // Create a variable vector consisting of x and y
          Variable z = Variable.vstack(x,y);

          // Create three constraints
          M.constraint("c1", Expr.dot(A[0], z), Domain.equalsTo(30.0));
          M.constraint("c2", Expr.dot(A[1], z), Domain.greaterThan(15.0));
          M.constraint("c3", Expr.dot(A[2], z), Domain.lessThan(25.0));

          // Set the objective function to (c^t * x)
          M.objective("obj", ObjectiveSense.Maximize, Expr.dot(c, z));
        
          // Solve the problem
          M.solve();


          // Get the solution values
          double[] sol = z.level();
          System.out.printf("x1,x2,x3,y = %e, %e, %e, %e\n",sol[0],sol[1],sol[2],sol[3]);
        }
        finally
        {
          M.dispose();
        }
    }
}

