/*
*  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
*
*  File:      simple.cs
*
*  Purpose:   Demonstrate a very simple Fusion model. 
*
*  The problem: 
*    max        x+y
*    such that  0  < x < 1
*               -1 < y-x < 2
*
*/

using System;
using mosek.fusion;

namespace mosek
{
  namespace fusion
  {
    namespace example
    {
      class simple
      {
        public static void Main(string[] args)
        {
          // Create a model object
          using (Model M = new Model("simple"))
          {
      
            // Add two variables
            Variable x = M.Variable("x",1,Domain.InRange(0.0,1.0));
            Variable y = M.Variable("y",1,Domain.Unbounded());
        
            // Add a constraint on the variables
            M.Constraint("bound y", Expr.Sub(y,x), Domain.InRange(-1.0, 2.0));
        
            // Define the objective
            M.Objective("obj", ObjectiveSense.Maximize, Expr.Add(x,y));
        
            // Solve the problem
            M.Solve();
        
            // Print the solution
            Console.WriteLine("Solution. x = {0}, y = {1}",x.Level()[0],y.Level()[0]);
          }
        }
      }
    }
  }
}
