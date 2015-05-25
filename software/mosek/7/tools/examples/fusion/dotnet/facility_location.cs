////
//  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
//
//  File:      facility_location.cs
//
//  Purpose: Demonstrates a small one-facility location problem.
//
//  Given 10 customers placed in a grid we wish to place a facility
//  somewhere so that the total sum of distances to customers is 
//  minimized.
// 
//  The problem is formulated as a conic optimization problem as follows.
//  Let f=(fx,fy) be the (unknown) location of the facility, and let 
//  c_i=(cx_i,cy_i) be the (known) customer locations; then we wish to 
//  minimize
//      sum_i || f - c_i ||
//  where 
//      ||.||
//  denotes the euclidian norm.
//  This is formulated as
//  
//  minimize   sum(d_i)
//  such that  d_i ^ 2 > tx_i ^ 2 + ty_i ^ 2, for all i
//             tx_i = cx_i - fx, for all i
//             ty_i = cy_i - fy, for all i
//             d_i > 0, for all i
////

using System;
using mosek.fusion;

namespace mosek
{
  namespace fusion
  {
    namespace example
    {
      public class facility_location
      {
// Customer locations
          private static Matrix  customerloc = 
              new DenseMatrix (new double[][] 
                  { new double[] { 12,  2 },
                    new double[] { 15, 13 },
                    new double[] { 10,  8 },
                    new double[] {  0, 10 },
                    new double[] {  6, 13 },
                    new double[] {  5,  8 },
                    new double[] { 10, 12 },
                    new double[] {  4,  6 },
                    new double[] {  5,  2 },
                    new double[] {  1, 10 } } );
        private static int N = customerloc.NumRows();
        public static void Main(string[] args)
        {
          using (Model M = new Model("FacilityLocation"))
          {
  // Variable holding the facility location
            Variable f = M.Variable("facility",new NDSet(1,2),Domain.Unbounded());
            // Variable defining the euclidian distances to each customer
            Variable d = M.Variable("dist", new NDSet(N,1), Domain.GreaterThan(0.0));
            // Variable defining the x and y differences to each customer;
            Variable t = M.Variable("t",new NDSet(N,2), Domain.Unbounded());
            M.Constraint("dist measure", 
                         Variable.Stack(new Variable[][] { new Variable[] { d, t }}), 
                         Domain.InQCone(N,3));

            Variable fxy = Variable.Repeat(f, N);
            M.Constraint("xy diff", Expr.Add(t, fxy), Domain.EqualsTo(customerloc));

            M.Objective("total_dist", ObjectiveSense.Minimize, Expr.Sum(d));
            
            M.Solve();
            double[] floc = f.Level();
            Console.WriteLine("Facility location = {0},{1}",floc[0],floc[1]);
          }
        }
      }
    }
  }
}

