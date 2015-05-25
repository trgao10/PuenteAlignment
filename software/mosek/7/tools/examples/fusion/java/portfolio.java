/*
  File : portfolio.java

  Copyright : Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  Description :
    Presents several portfolio optimization models.
*/


package com.mosek.fusion.examples;
import mosek.fusion.*;
import java.io.FileReader;
import java.io.BufferedReader;
import java.util.ArrayList;

public class portfolio
{
  
  public static double sum(double[] x)
  {
    double r = 0.0;
    for (int i = 0; i < x.length; ++i) r += x[i];
    return r;
  }

  public static double dot(double[] x, double[] y)
  {
    double r = 0.0;
    for (int i = 0; i < x.length; ++i) r += x[i] * y[i];
    return r;
  }

  /*
  Purpose:
      Computes the optimal portfolio for a given risk 
   
  Input:
      n: Number of assets
      mu: An n dimmensional vector of expected returns
      GT: A matrix with n columns so (GT')*GT  = covariance matrix
      x0: Initial holdings 
      w: Initial cash holding
      gamma: Maximum risk (=std. dev) accepted
   
  Output:
      Optimal expected return and the optimal portfolio     
  */ 
  public static double BasicMarkowitz
    ( int n,
      double[] mu,
      DenseMatrix GT,
      double[] x0,
      double   w,
      double   gamma)
    throws mosek.fusion.SolutionError
  {
    
    Model M = new Model("Basic Markowitz");
    try
     {
         // Redirect log output from the solver to stdout for debugging. 
         // if uncommented.
         //M.setLogHandler(new java.io.PrintWriter(System.out));
         
         // Defines the variables (holdings). Shortselling is not allowed.
         Variable x = M.variable("x", n, Domain.greaterThan(0.0));
         
         //  Maximize expected return
         M.objective("obj", ObjectiveSense.Maximize, Expr.dot(mu,x));
         
         // The amount invested  must be identical to intial wealth
         M.constraint("budget", Expr.sum(x), Domain.equalsTo(w+sum(x0)));
         
         // Imposes a bound on the risk
         M.constraint("risk", Expr.vstack(Expr.constTerm(new double[] {gamma}),Expr.mul(GT,x)), Domain.inQCone());

         // Solves the model.
         M.solve();

         return dot(mu,x.level());
     }
    finally
    {
        M.dispose();
    }
  }

  /*
    Purpose:
        Computes several portfolios on the optimal portfolios by 

            for alpha in alphas: 
                maximize   expected return - alpha * standard deviation
                subject to the constraints  
        
    Input:
        n: Number of assets
        mu: An n dimmensional vector of expected returns
        GT: A matrix with n columns so (GT')*GT  = covariance matrix
        x0: Initial holdings 
        w: Initial cash holding
        alphas: List of the alphas
                    
    Output:
        The efficient frontier as list of tuples (alpha,expected return,risk)
   */ 
  public static void EfficientFrontier
    ( int n,
      double[] mu,
      DenseMatrix GT,
      double[]    x0,
      double      w,
      double[]    alphas,
      
      double[]    frontier_mux,
      double[]    frontier_s)
    throws mosek.fusion.SolutionError
  {
      
    Model M = new Model("Efficient frontier");
    try
    {
        //M.setLogHandler(new java.io.PrintWriter(System.out));
 
        // Defines the variables (holdings). Shortselling is not allowed.
        Variable x = M.variable("x", n, Domain.greaterThan(0.0)); // Portfolio variables
        Variable s = M.variable("s", 1, Domain.unbounded()); // Risk variable
        
        M.constraint("budget", Expr.sum(x), Domain.equalsTo(w+sum(x0)));
        
        // Computes the risk
        M.constraint("risk", Expr.vstack(s.asExpr(),Expr.mul(GT,x)),Domain.inQCone());
        
        for (int i = 0; i < alphas.length; ++i)
            {
                //  Define objective as a weighted combination of return and risk
                M.objective("obj", ObjectiveSense.Maximize, Expr.sub(Expr.dot(mu,x),Expr.mul(alphas[i],s)));
                
                M.solve();
                
                frontier_mux[i] = dot(mu,x.level());
                frontier_s[i]   = s.level()[0];
            }
    }
    finally
    {
        M.dispose();
    }
}


  /*
      Description:
          Extends the basic Markowitz model with a market cost term.

      Input:
          n: Number of assets
          mu: An n dimmensional vector of expected returns
          GT: A matrix with n columns so (GT')*GT  = covariance matrix'
          x0: Initial holdings 
          w: Initial cash holding
          gamma: Maximum risk (=std. dev) accepted
          m: It is assumed that  market impact cost for the j'th asset is
             m_j|x_j-x0_j|^3/2

      Output:
         Optimal expected return and the optimal portfolio     

  */
  public static void MarkowitzWithMarketImpact
    ( int n,
      double[] mu,
      DenseMatrix GT,
      double[] x0,
      double   w,
      double   gamma,
      double[] m,
      
      double[] xsol,
      double[] tsol)
    throws mosek.fusion.SolutionError
  {
    Model M = new Model("Markowitz portfolio with market impact");
    try
    {
        //M.setLogHandler(new java.io.PrintWriter(System.out));
        
        // Defines the variables. No shortselling is allowed.
        Variable x = M.variable("x", n, Domain.greaterThan(0.0));
        
        // Addtional "helper" variables 
        Variable t = M.variable("t", n, Domain.unbounded());
        Variable z = M.variable("z", n, Domain.unbounded());  
        Variable v = M.variable("v", n, Domain.unbounded());      
        
        //  Maximize expected return
        M.objective("obj", ObjectiveSense.Maximize, Expr.dot(mu,x));
        
        // Invested amount + slippage cost = initial wealth
        M.constraint("budget", Expr.add(Expr.sum(x),Expr.dot(m,t)), Domain.equalsTo(w+sum(x0)));
        
        // Imposes a bound on the risk
        M.constraint("risk", Expr.vstack(Expr.constTerm(new double[] {gamma}),Expr.mul(GT,x)), 
                     Domain.inQCone());
        
        // z >= |x-x0| 
        M.constraint("buy", Expr.sub(z,Expr.sub(x,x0)),Domain.greaterThan(0.0));
        M.constraint("sell", Expr.sub(z,Expr.sub(x0,x)),Domain.greaterThan(0.0));
        
        // t >= z^1.5, z >= 0.0. Needs two rotated quadratic cones to model this term
        M.constraint("ta", Expr.hstack(v.asExpr(),t.asExpr(),z.asExpr()),Domain.inRotatedQCone());
        M.constraint("tb", Expr.hstack(z.asExpr(),Expr.constTerm(n,1.0/8.0),v.asExpr()),
                 Domain.inRotatedQCone());

        M.solve();  
        
        if (xsol != null) 
            System.arraycopy(x.level(),0,xsol,0,n);
        if (tsol != null)
            System.arraycopy(t.level(),0,tsol,0,n);
    }
    finally
    {
        M.dispose();
    }
  }

  /*
      Description:
          Extends the basic Markowitz model with a market cost term.

      Input:
          n: Number of assets
          mu: An n dimmensional vector of expected returns
          GT: A matrix with n columns so (GT')*GT  = covariance matrix
          x0: Initial holdings 
          w: Initial cash holding
          gamma: Maximum risk (=std. dev) accepted
          f: If asset j is traded then a fixed cost f_j must be paid
          g: If asset j is traded then a cost g_j must be paid for each unit traded

      Output:
         Optimal expected return and the optimal portfolio     

  */
  public static double[] MarkowitzWithTransactionsCost
    ( int n, 
      double[] mu,
      DenseMatrix GT,
      double[] x0,
      double   w,
      double   gamma,
      double[] f,
      double[] g)
    throws mosek.fusion.SolutionError
  {

    // Upper bound on the traded amount
    double[] u = new double[n];
    {
      double v = w+sum(x0);
      for (int i = 0; i < n; ++i) u[i] = v;
    }

    Model M = new Model("Markowitz portfolio with transaction costs");
    try
    {
        //M.setLogHandler(new java.io.PrintWriter(System.out));
        
        // Defines the variables. No shortselling is allowed.
        Variable x = M.variable("x", n, Domain.greaterThan(0.0));
        
        // Addtional "helper" variables 
        Variable z = M.variable("z", n, Domain.unbounded());
        // Binary varables
        Variable y = M.variable("y", n, Domain.inRange(0.0,1.0), Domain.isInteger());
        
        //  Maximize expected return
        M.objective("obj", ObjectiveSense.Maximize, Expr.dot(mu,x));
        
        // Invest amount + transactions costs = initial wealth
        M.constraint("budget", Expr.add(Expr.add(Expr.sum(x),Expr.dot(f,y)),Expr.dot(g,z)),
                     Domain.equalsTo(w+sum(x0)));
        
        // Imposes a bound on the risk
        M.constraint("risk", Expr.vstack(Expr.constTerm(new double[] {gamma}),Expr.mul(GT,x)), 
                     Domain.inQCone());
        
        // z >= |x-x0| 
        M.constraint("buy", Expr.sub(z,Expr.sub(x,x0)),Domain.greaterThan(0.0));
        M.constraint("sell", Expr.sub(z,Expr.sub(x0,x)),Domain.greaterThan(0.0));
        
        //M.constraint("trade", Expr.hstack(z.asExpr(),Expr.sub(x,x0)), Domain.inQcone())"
        
        // Consraints for turning y off and on. z-diag(u)*y<=0 i.e. z_j <= u_j*y_j
        M.constraint("y_on_off", Expr.sub(z,Expr.mul(Matrix.diag(u),y)), Domain.lessThan(0.0));
        
        // Integer optimization problems can be very hard to solve so limiting the 
        // maximum amount of time is a valuable safe guard
        M.setSolverParam("mioMaxTime", 180.0);
        M.solve();
        
        return x.level();
    }
    finally
    {
        M.dispose();
    }
  }


  /*
    The example
    
        python portfolio.py portfolio    

    reads in data and solves the portfolio models.
   */
  public static void main(String[] argv)
    throws java.io.IOException,
           java.io.FileNotFoundException,
           mosek.fusion.SolutionError
  {

    String name = argv[0];

    MarkowitzData d = new MarkowitzData(name);
    System.out.println("\n\n================================");
    System.out.println("Markowitz portfolio optimization");
    System.out.println("================================\n");
    {
      System.out.println("\n-----------------------------------------------------------------------------------");
      System.out.println("Basic Markowitz portfolio optimization");
      System.out.println("-----------------------------------------------------------------------------------\n");
        for( int i = 0; i < d.gammas.length; ++i)
            {
                double expret= BasicMarkowitz( d.n, d.mu, d.GT, d.x0, d.w, d.gammas[i]);
                System.out.format("Expected return: %.4e Std. deviation: %.4e\n",
                                  expret, 
                                  d.gammas[i]);
            }
    }    
    {
    // Some predefined alphas are chosen
      double[] alphas = { 0.0, 0.01, 0.1, 0.25, 0.30, 0.35, 0.4, 0.45, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 10.0 };
      int      niter = alphas.length;
      double[] frontier_mux = new double[niter];
      double[] frontier_s   = new double[niter];

      EfficientFrontier(d.n,d.mu,d.GT,d.x0,d.w,alphas, frontier_mux, frontier_s);
      System.out.println("\n-----------------------------------------------------------------------------------");
      System.out.println("Efficient frontier") ;
      System.out.println("-----------------------------------------------------------------------------------\n");
      System.out.format("%-12s  %-12s  %-12s\n", "alpha","return","risk") ;
      for (int i = 0; i < frontier_mux.length; ++i)
        System.out.format("\t%-12.4f  %-12.4e  %-12.4e\n", alphas[i],frontier_mux[i],frontier_s[i]);
    }

    {
      // Somewhat arbirtrary choice of m
      double[] m = new double[d.n]; for (int i = 0; i < d.n; ++i) m[i] = 1.0e-2;
      double[] x = new double[d.n];
      double[] t = new double[d.n];

      MarkowitzWithMarketImpact(d.n,d.mu,d.GT,d.x0,d.w,d.gammas[0],m, x,t);
      System.out.println("\n-----------------------------------------------------------------------------------");
      System.out.println("Markowitz portfolio optimization with market impact cost");
      System.out.println("-----------------------------------------------------------------------------------\n");
      System.out.format("Expected return: %.4e Std. deviation: %.4e Market impact cost: %.4e\n",
                        dot(d.mu,x),
                        d.gammas[0],
                        dot(m,t));
    }

    {
      double[] f = new double[d.n]; java.util.Arrays.fill(f,0.01);
      double[] g = new double[d.n]; java.util.Arrays.fill(g,0.001);
      System.out.println("\n-----------------------------------------------------------------------------------");
      System.out.println("Markowitz portfolio optimization with transactio cost");
      System.out.println("-----------------------------------------------------------------------------------\n");

      double[] x = new double[d.n]; 
      x = MarkowitzWithTransactionsCost(d.n,d.mu,d.GT,d.x0,d.w,d.gammas[0],f,g);
      System.out.println("Optimal portfolio: \n");
      for( int i = 0; i < x.length; ++i)
          System.out.format("\tx[%-2d]  %-12.4e\n", i,x[i]);
    }
  }
}


class MarkowitzData
{
  /*
    Reads data from several files.
  */    

  private double[] readline(BufferedReader f)
    throws java.io.IOException
  {
    String s = null;
    do
    {
      s = f.readLine();
      if (s != null && s.trim().length() > 0)
      {
        String[] tokens = s.split("\\s*,\\s*");
        double[] r = new double[tokens.length];
        for (int i = 0; i < tokens.length; ++i)
          r[i] = Double.parseDouble(tokens[i]);
        return r;
      }
    }
    while (s != null);
    return null;
  }

  private double[][] readlines(BufferedReader f)
    throws java.io.IOException
  {
    ArrayList<double[]> l = new ArrayList<double[]>();
    while (true)
    {
      double[] line = readline(f);
      if (line == null) break;
      l.add(line);                
    }
    double[][] r = new double[l.size()][];
    for (int i = 0; i < r.length; ++i) r[i] = l.get(i);
    return r;
  }
  
  private double[] readfile(BufferedReader f)
    throws java.io.IOException
  {
    ArrayList<Double> l = new ArrayList<Double>();
    while (true)
    {
      String line = f.readLine();
      if (line == null)
        break;
      else if (line.trim().length() > 0)
        l.add(Double.parseDouble(line));
    }
    double[] r = new double[l.size()];
    {
      int offset = 0;
      for (int i = 0; i < l.size(); ++i)
        r[i] = l.get(i);
    }

    return r; 
  }

  public MarkowitzData(String name)
    throws java.io.IOException
  {      
    n      = Integer.parseInt(new BufferedReader(new FileReader(name+"-n.txt")).readLine());
    gammas = readfile(new BufferedReader(new FileReader(name + "-gammas.csv")));
    mu     = readfile(new BufferedReader(new FileReader(name + "-mu.csv")));
    GT     = new DenseMatrix(readlines(new BufferedReader(new FileReader(name + "-GT.csv"))));
    x0     = readfile(new BufferedReader(new FileReader(name + "-x0.csv")));
    w      = Double.parseDouble(new BufferedReader(new FileReader(name+"-w.csv")).readLine());
  }

  public int         n;
  public double[]    mu;
  public DenseMatrix GT;
  public double[]    gammas; 
  public double[]    x0;
  public double      w;
}

