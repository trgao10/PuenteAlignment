/*
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
 
   File:      nearestcorr.cs
 
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
using mosek.fusion;
using System;   

namespace mosek
{
  namespace fusion
  {
    namespace examples
    {
      public class nearestcorr 
      {
        /** Assuming that e is an NxN expression, return the lower triangular part as a vector.
        */
        public static Expression Vec(Expression e)
        {
          int N    = e.GetShape().Dim(0);
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
                else        mcof[k] = Math.Sqrt(2);

              }
          }

          var S = Matrix.Sparse(N * (N+1) / 2,N * N,msubi,msubj,mcof);
          
          return Expr.Mul(S,Expr.Flatten(e));
        }
        public static void Main(string[] argv)
        {
          int N = 5;
          var A = new double[][]
              { new double[] { 0.0,  0.5,  -0.1,  -0.2,   0.5},
                new double[] { 0.5,  1.25, -0.05, -0.1,   0.25},
                new double[] {-0.1, -0.05,  0.51,  0.02, -0.05},
                new double[] {-0.2, -0.1,   0.02,  0.54, -0.1},
                new double[] { 0.5,  0.25, -0.05, -0.1,   1.25} };

          // Create a model with the name 'NearestCorrelation
          using (var M = new Model("NearestCorrelation"))
          {
            // Setting up the variables
            var X = M.Variable("X", Domain.InPSDCone(N));
            var t = M.Variable("t", 1, Domain.Unbounded());

            // (t, vec (A-X)) \in Q
            M.Constraint( Expr.Vstack(t, Vec(Expr.Sub(new DenseMatrix(A),X))), Domain.InQCone() );

            // diag(X) = e
            M.Constraint(X.Diag(), Domain.EqualsTo(1.0));

            // Objective: Minimize t
            M.Objective(ObjectiveSense.Minimize, t);
                              
            // Solve the problem
            M.Solve();

            // Get the solution values
            Console.WriteLine("X = {0}",arrtostr(X.Level()));
            
            Console.WriteLine("t = {0}", arrtostr(t.Level()));
          } 
        }


        private static string arrtostr(double[] a)
        {
          var c = new System.Globalization.CultureInfo("en-US");
          var b = new System.Text.StringBuilder("[");
          if (a.Length > 0) b.Append(String.Format(c,"{0:e3}",a[0]));
          for (int i = 1; i < a.Length; ++i) b.Append(",").Append(String.Format(c,"{0:e3}",a[i]));  
          b.Append("]");
          return b.ToString();
        }
      }
    }
  }
}
