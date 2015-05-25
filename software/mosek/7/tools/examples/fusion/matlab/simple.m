package mosek.fusion.examples;
/*
*  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
*
*  File:      simple.java
*
*  Purpose:   Demonstrate a very simple Fusion model. 
*
*  The problem: 
*    max        x+y
*    such that  0  < x < 1
*               -1 < y-x < 2
*
*/

import mosek.fusion.*;

class simple
{
  public static void main(String[] args) 
    throws SolutionError
  {
    // Create a model object
    Model M = new Model("simple");

    // Add two variables
    Variable x = M.variable("x",1,Domain.inRange(0.0,1.0));
    Variable y = M.variable("y",1,Domain.unbounded());

    // Add a constraint on the variables
    M.constraint("bound y", Expr.sub(y,x), Domain.inRange(-1.0, 2.0));

    // Define the objective
    M.objective("obj", ObjectiveSense.Maximize, Expr.add(x,y));

    // Solve the problem
    M.solve();
  }
}

