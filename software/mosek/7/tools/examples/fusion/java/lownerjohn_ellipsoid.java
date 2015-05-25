package com.mosek.fusion.examples;
/*
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

   File:      lownerjohn_ellipsoid.java

   Purpose: 
   Computes the Lowner-John inner and outer ellipsoidal 
   approximations of a polytope.


   The inner ellipsoidal approximation to a polytope 

      S = { x \in R^n | Ax < b }.

   maximizes the volume of the inscribed ellipsoid,

      { x | x = C*u + d, || u ||_2 <= 1 }.

   The volume is proportional to det(C)^(1/n), so the
   problem can be solved as 

     maximize         t
     subject to       t       <= det(C)^(1/n)
                 || C*ai ||_2 <= bi - ai^T * d,  i=1,...,m
                   C is PSD

   which is equivalent to a mixed conic quadratic and semidefinite
   programming problem.


   The outer ellipsoidal approximation to a polytope given 
   as the convex hull of a set of points

       S = conv{ x1, x2, ... , xm }

   minimizes the volume of the enclosing ellipsoid,

     { x | || P*(x-c) ||_2 <= 1 }

   The volume is proportional to det(P)^{-1/n}, so the problem can
   be solved as

     minimize         t
     subject to       t       >= det(P)^(-1/n)
                 || P*xi + c ||_2 <= 1,  i=1,...,m
                   P is PSD.

   References:
   [1] "Lectures on Modern Optimization", Ben-Tal and Nemirovski, 2000. 
 */

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Polygon;
import java.awt.geom.Ellipse2D;
import java.awt.geom.AffineTransform;

import javax.swing.BorderFactory;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;


import mosek.fusion.*;

public class lownerjohn_ellipsoid 
{
  /** 
      Purpose: Models the convex set 

        S = { (x, t) \in R^n x R | x >= 0, t <= (x1 * x2 * ... *xn)^(1/n) }.

      as the intersection of rotated quadratic cones and affine hyperplanes,
      see [1, p. 105].  This set can be interpreted as the hypograph of the 
      geometric mean of x.

      We illustrate the modeling procedure using the following example.
      Suppose we have 

         t <= (x1 * x2 * x3)^(1/3)

      for some t >= 0, x >= 0. We rewrite it as

         t^4 <= x1 * x2 * x3 * x4,   x4 = t

      which is equivalent to (see [1])

         x11^2 <= 2*x1*x2,   x12^2 <= 2*x3*x4,

         x21^2 <= 2*x11*x12,

         sqrt(8)*x21 = t, x4 = t.

      References:
      [1] "Lectures on Modern Optimization", Ben-Tal and Nemirovski, 2000. 
  */ 
  public static void geometric_mean(Model M, Variable x, Variable t)
  {
    int n = (int) x.size();
    int l = (int)Math.ceil(Math.log(n)/Math.log(2));
    int m = pow2(l) - n;
            
    Variable x0;

    if (m == 0)
        x0 = x;
    else    
        x0 = Variable.vstack(x, M.variable(m, Domain.greaterThan(0.0)));

    Variable z = x0;

    for (int i = 0; i < l-1; ++i)
    {
      Variable xi = M.variable(pow2(l-i-1), Domain.greaterThan(0.0));
      for (int k = 0; k < pow2(l-i-1); ++k)
        M.constraint(Variable.vstack(z.index(2*k),z.index(2*k+1),xi.index(k)),
                     Domain.inRotatedQCone());
        z = xi;
    }
        
    Variable t0 = M.variable(1, Domain.greaterThan(0.0));
    M.constraint(Variable.vstack(z, t0), Domain.inRotatedQCone());

    M.constraint(Expr.sub(Expr.mul(Math.pow(2,0.5*l),t),t0), Domain.equalsTo(0.0));

    for (int i = pow2(l-m); i < pow2(l); ++i)
      M.constraint(Expr.sub(x0.index(i), t), Domain.equalsTo(0.0));
  }

  /**
      Purpose: Models the hypograph of the n-th power of the
      determinant of a positive definite matrix.

      The convex set (a hypograph)

        C = { (X, t) \in S^n_+ x R |  t <= det(X)^{1/n} },

      can be modeled as the intersection of a semidefinite cone
      
        [ X, Z; Z^T Diag(Z) ] >= 0  

      and a number of rotated quadratic cones and affine hyperplanes,

        t <= (Z11*Z22*...*Znn)^{1/n}  (see geometric_mean).

      References:
      [1] "Lectures on Modern Optimization", Ben-Tal and Nemirovski, 2000. 
   */

  public static void det_rootn(Model M, Variable X, Variable t)
  {
    int n = X.shape.dim(0);

    // Setup variables
    Variable Y = M.variable(Domain.inPSDCone(2*n));
    
    // Setup Y = [X, Z; Z^T diag(Z)] 
    Variable Y11 = Y.slice(new int[] {0, 0}, new int[] {n, n});
    Variable Y21 = Y.slice(new int[] {n, 0}, new int[] {2*n, n});
    Variable Y22 = Y.slice(new int[] {n, n}, new int[] {2*n, 2*n});
    
    double[] ones= new double[n];
    for (int i = 0; i < n; ++i)
      ones[i] = 1.0;

    Matrix S = Matrix.sparse(n, n, irange(0,n), irange(0,n), ones);
    M.constraint( Expr.sub(Expr.mulElm(S,Y21), Y22), Domain.equalsTo(0.0));
    M.constraint( Expr.sub(X, Y11), Domain.equalsTo(0.0) );

    // t^n <= (Z11*Z22*...*Znn)
    Variable[] tmpv = new Variable[n];
    for (int i = 0; i < n; ++i) tmpv[i] = Y22.index(i,i);
    Variable z = Variable.reshape(Variable.vstack(tmpv), n);
    geometric_mean(M, z, t);
  }

  public static int[] irange(int first, int last) 
  { 
    int[] r = new int[last-first];
    for (int i = 0; i < last-first; ++i)
      r[i] = i+first;
    return r;
  }

  public static int pow2(int n)
  {
    return (int) (1 << n);
  }

  public static double[] lownerjohn_inner(double[][] A, double[] b)
    throws SolutionError
  {
    Model M = new Model("lownerjohn_inner");
    try
    {
      int m = A.length;
      int n = A[0].length; 

      // Setup variables
      Variable t = M.variable("t", 1, Domain.greaterThan(0.0));   
      Variable C = M.variable("C", new NDSet(n,n), Domain.unbounded());
      Variable d = M.variable("d", n, Domain.unbounded());        
      
      // (bi - ai^T*d, C*ai) \in Q 
      for (int i = 0; i < m; ++i)
        M.constraint( "qc" + i, Expr.vstack(Expr.sub(b[i],Expr.dot(A[i],d)), Expr.mul(C,A[i])), Domain.inQCone() );

      // t <= det(C)^{1/n}
      //model_utils.det_rootn(M, C, t);
      det_rootn(M, C, t);
                             
      // Objective: Maximize t
      M.objective(ObjectiveSense.Maximize, t);
      M.solve();
      
      double[] Clvl = C.level();
      double[] dlvl = d.level();

      double[] Cd = new double[Clvl.length + dlvl.length];

      for(int j = 0; j < n; ++j)
      {
        for (int i = 0; i < n; ++i)
        {
          System.out.println("i,j = " + i + "," + j);
          Cd[n*i+j] = Clvl[n*j+i];
        }
        Cd[n*n+j] = dlvl[j];
      }

      System.out.print("C  = [ " + Clvl[0]); for (int i = 1; i < Clvl.length; ++i) System.out.print("," + Clvl[i]); System.out.println(" ]");
      System.out.print("d  = [ " + dlvl[0]); for (int i = 1; i < dlvl.length; ++i) System.out.print("," + dlvl[i]); System.out.println(" ]");
      System.out.print("Cd = [ " + Cd[0]);   for (int i = 1; i < Cd.length; ++i) System.out.print("," + Cd[i]); System.out.println(" ]");

      return Cd;
    }
    finally
    {
      M.dispose();
    }
  }


  public static double[] lownerjohn_outer(double[][] x)
    throws SolutionError
  {
    Model M = new Model("lownerjohn_outer");
    try
    {
      int m = x.length;
      int n = x[0].length;

      // Setup variables
      Variable t = M.variable("t", 1, Domain.greaterThan(0.0));
      Variable P = M.variable("P", new NDSet(n,n), Domain.unbounded());
      Variable c = M.variable("c", n, Domain.unbounded());

      // (1, P(*xi+c)) \in Q 
      for (int i = 0; i < m; ++i)
        M.constraint( "qc" + i, Expr.vstack(Expr.ones(1), Expr.sub(Expr.mul(P,x[i]), c)), Domain.inQCone() );

      // t <= det(P)^{1/n}
      //model_utils.det_rootn(M, P, t);
      det_rootn(M, P, t);
                         
      // Objective: Maximize t
      M.objective(ObjectiveSense.Maximize, t);
      M.solve();
      
      double[] Plvl = P.level();
      double[] clvl = c.level();

      double[] Pc = new double[Plvl.length + clvl.length];


      for(int j = 0; j < n; ++j)
      {
        for (int i = 0; i < n; ++i)
          Pc[n*i+j] = Plvl[n*j+i];
         Pc[n*n+j] = clvl[j];
      }
      return Pc;
    }
    finally
    {
      M.dispose();
    }    
  }


  public static void main(String[] argv)
    throws SolutionError
  {
    final double[][] p = { {0.,0.},{1.,3.}, {5.,4.}, {7.,1.}, {3.,-2.} };
    double[][] A = new double[p.length][];
    double[]   b = new double[p.length];
    int n = p.length;
    for (int i = 0; i < n; ++i)
    {
      A[i] = new double[] { -p[i][1]+p[(i-1+n)%n][1], p[i][0]-p[(i-1+n)%n][0] };
      b[i] = A[i][0]*p[i][0]+A[i][1]*p[i][1];
    }

    double[] Cd = lownerjohn_inner(A, b);
    double[] Pc = lownerjohn_outer(p); 
  }
}

