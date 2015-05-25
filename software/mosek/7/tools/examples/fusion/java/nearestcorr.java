package com.mosek.fusion.examples;
/*
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
 
   File:      nearestcorr.java
 
   Purpose: 
   Solves the nearest correlation matrix problem
  
     minimize   || A - X ||_F   s.t.  diag(X) = e, X is PSD
 
   as the equivalent conic program
 
     minimize     t
    
     subject to   (t, vec(A-X)) in Q
                  diag(X) = e
                  X >= 0
     where
                  vec : M(n x n) -> R^(n*(n+1)/2)
                  vec(M)_k = M_ij           for k = i * (i+1) / 2 + j, and i == j
                           | sqrt(2) * M_ij for k = i * (i+1) / 2, i < j
*/
import mosek.fusion.*;

public class nearestcorr 
{
  /** Assuming that e is an NxN expression, return the lower triangular part as a vector.
  */
  public static Expression vec(Expression e)
  {
    int N    = e.getShape().dim(0);
    int[] msubi = new int[N*(N+1)/2],
          msubj = new int[N*(N+1)/2];
    double[] mcof = new double[N*(N+1)/2];

    {
      for (int i = 0, k = 0; i < N; ++i)
        for (int j = 0; j < i+1; ++j, ++k)
        {
          msubi[k] = k;
          msubj[k] = i*N+j;
          if (i == j) mcof[k] = 1.0;
          else        mcof[k] = Math.sqrt(2);

        }
    }

    Matrix S = Matrix.sparse(N * (N+1) / 2,N * N,msubi,msubj,mcof);
    
    return Expr.mul(S,Expr.reshape( e, N * N ));
  }
  private static String arrtostr(double[] a)
  {
    StringBuilder b = new StringBuilder("[");
    java.util.Formatter f = new java.util.Formatter(b, java.util.Locale.US);
    if (a.length > 0) f.format(", %.3e", a[0]);
    for (int i = 1; i < a.length; ++i) f.format(", %.3e", a[i]);  
    b.append("]");
    return b.toString();
  }
  public static void main(String[] argv)
    throws SolutionError
  {
    int N = 5;
    double[][] A = new double[][]
        { { 0.0,  0.5,  -0.1,  -0.2,   0.5},
          { 0.5,  1.25, -0.05, -0.1,   0.25},
          {-0.1, -0.05,  0.51,  0.02, -0.05},
          {-0.2, -0.1,   0.02,  0.54, -0.1},
          { 0.5,  0.25, -0.05, -0.1,   1.25} };

    // Create a model with the name 'NearestCorrelation
    Model M = new Model("NearestCorrelation");    
    try
    {
      // Setting up the variables
      Variable X = M.variable("X", Domain.inPSDCone(N));
      Variable t = M.variable("t", 1, Domain.unbounded());

      // (t, vec (A-X)) \in Q
      M.constraint( Expr.vstack(t, vec(Expr.sub(new DenseMatrix(A),X))), Domain.inQCone() );

      // diag(X) = e
      M.constraint(X.diag(), Domain.equalsTo(1.0));

      // Objective: Minimize t
      M.objective(ObjectiveSense.Minimize, t);
                        
      // Solve the problem
      M.solve();

      // Get the solution values
      System.out.println("X = " + arrtostr(X.level()));
      
      System.out.println("t = " + arrtostr(t.level()));
    } 
    finally
    {
      M.dispose();
    }
  }
}
