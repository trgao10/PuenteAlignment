"""
  File : portfolio.py

  Copyright : Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  Description :
    Presents several portfolio optimization models.
 
"""

import csv
import math
import string
import sys

from   mosek.fusion import *

def ReadData(name):
    """
    Reads data from several files.
    """    

    f = open('%s-n.txt' % name,'rt') 
    n = string.atoi(f.readline())
    f.close()

    gammas = [] 
    f      = open('%s-gammas.csv' % name,'rt') 
    for row in csv.reader(f,quoting=csv.QUOTE_NONNUMERIC):
        gammas.extend(row)
    f.close()

    f = open ('%s-mu.csv' % name, 'rt')
    mu = []
    for row in csv.reader(f,quoting=csv.QUOTE_NONNUMERIC):
        mu.extend(row)
    f.close()
    
    GT = [] 
    f  = open ('%s-GT.csv' % name, 'rt' ) 
    for row in csv.reader(f,quoting=csv.QUOTE_NONNUMERIC):
        GT.append(row)
    f.close()

    GT = DenseMatrix(GT)

    f = open ('%s-x0.csv' % name, 'rt')
    x0 = []
    for row in csv.reader(f,quoting=csv.QUOTE_NONNUMERIC):
        x0.extend(row)
    f.close()

    f = open('%s-w.csv' % name,'rt') 
    w = string.atof(f.readline())
    f.close()

    return (n,mu,GT,gammas,x0,w)

def sum(x):
    # Computes the sum of all the elements in a vector 
    r = 0.0
    for i in range(len(x)):
        r = r + x[i]
    return r    

def dot(x,y):
    # Computes the inner product between two vectors.
    r = 0.0
    for i in range(len(x)):
        r = r + x[i]*y[i]

    return r    

def BasicMarkowitz(n,mu,GT,x0,w,gamma):
    """
    Purpose:
        Computes the optimal portfolio for a given risk 
     
    Input:
        n: Number of assets
        mu: An n dimensional vector of expected returns
        GT: A matrix with n columns so (GT')*GT  = covariance matrix
        x0: Initial holdings 
        w: Initial cash holding
        gamma: Maximum risk (=std. dev) accepted
     
    Output:
        Optimal expected return and the optimal portfolio     
    """ 
    
    with  Model("Basic Markowitz") as M:

        # Redirect log output from the solver to stdout for debugging. 
        # if uncommented.
        # M.setLogHandler(sys.stdout) 
        
        # Defines the variables (holdings). Shortselling is not allowed.
        x = M.variable("x", n, Domain.greaterThan(0.0))
        
        #  Maximize expected return
        M.objective('obj', ObjectiveSense.Maximize, Expr.dot(mu,x))
        
        # The amount invested  must be identical to initial wealth
        M.constraint('budget', Expr.sum(x), Domain.equalsTo(w+sum(x0)))
        
        # Imposes a bound on the risk
        M.constraint('risk', Expr.vstack(Expr.constTerm([gamma]),Expr.mul(GT,x)), Domain.inQCone())

        # Solves the model.
        M.solve()

        return  dot(mu,x.level())

def EfficientFrontier(n,mu,GT,x0,w,alphas):
    """
    Purpose:
        Computes several portfolios on the optimal portfolios by 

            for alpha in alphas: 
                maximize   expected return - alpha * standard deviation
                subject to the constraints  
        
    Input:
        n: Number of assets
        mu: An n dimensional vector of expected returns
        GT: A matrix with n columns so (GT')*GT  = covariance matrix
        x0: Initial holdings 
        w: Initial cash holding
        alphas: List of the alphas
                    
    Output:
        The efficient frontier as list of tuples (alpha,expected return,risk)
    """ 
    
    with Model("Efficient frontier") as M:
    
        # M.setLogHandler(sys.stdout) 
 
        # Defines the variables (holdings). Shortselling is not allowed.
        x = M.variable("x", n, Domain.greaterThan(0.0)) # Portfolio variables
        s = M.variable("s", 1, Domain.unbounded()) # Risk variable
        
        M.constraint('budget', Expr.sum(x), Domain.equalsTo(w+sum(x0)))
        
        # Computes the risk
        M.constraint('risk', Expr.vstack(s.asExpr(),Expr.mul(GT,x)),Domain.inQCone())
        
        frontier = []
        
        for i,alpha in enumerate(alphas):
            
            #  Define objective as a weighted combination of return and risk
            M.objective('obj', ObjectiveSense.Maximize, Expr.sub(Expr.dot(mu,x),Expr.mul(alpha,s)))
            
            M.solve()
            
            frontier.append((alpha,dot(mu,x.level()),s.level()[0]))
            
        return frontier

def MarkowitzWithMarketImpact(n,mu,GT,x0,w,gamma,m):
    """
        Description:
            Extends the basic Markowitz model with a market cost term.

        Input:
            n: Number of assets
            mu: An n dimensional vector of expected returns
            GT: A matrix with n columns so (GT')*GT  = covariance matrix
            x0: Initial holdings 
            w: Initial cash holding
            gamma: Maximum risk (=std. dev) accepted
            m: It is assumed that  market impact cost for the j'th asset is
               m_j|x_j-x0_j|^3/2

        Output:
           Optimal expected return and the optimal portfolio     

    """
            
    with  Model("Markowitz portfolio with market impact") as M:

        #M.setLogHandler(sys.stdout) 
    
        # Defines the variables. No shortselling is allowed.
        x = M.variable("x", n, Domain.greaterThan(0.0))
        
        # Additional "helper" variables 
        t = M.variable("t", n, Domain.unbounded())
        z = M.variable("z", n, Domain.unbounded())   
        v = M.variable("v", n, Domain.unbounded())        

        #  Maximize expected return
        M.objective('obj', ObjectiveSense.Maximize, Expr.dot(mu,x))

        # Invested amount + slippage cost = initial wealth
        M.constraint('budget', Expr.add(Expr.sum(x),Expr.dot(m,t)), Domain.equalsTo(w+sum(x0)))

        # Imposes a bound on the risk
        M.constraint('risk', Expr.vstack(Expr.constTerm([gamma]),Expr.mul(GT,x)), Domain.inQCone())

        # z >= |x-x0| 
        M.constraint('buy', Expr.sub(z,Expr.sub(x,x0)),Domain.greaterThan(0.0))
        M.constraint('sell', Expr.sub(z,Expr.sub(x0,x)),Domain.greaterThan(0.0))

        # t >= z^1.5, z >= 0.0. Needs two rotated quadratic cones to model this term
        M.constraint('ta', Expr.hstack(v.asExpr(),t.asExpr(),z.asExpr()),Domain.inRotatedQCone())
        M.constraint('tb', Expr.hstack(z.asExpr(),Expr.constTerm(n,1.0/8.0),v.asExpr()),\
                         Domain.inRotatedQCone())

        M.solve()

        if True:
            print("\n-----------------------------------------------------------------------------------");
            print('Markowitz portfolio optimization with market impact cost')
            print("-----------------------------------------------------------------------------------\n");
            print('Expected return: %.4e Std. deviation: %.4e Market impact cost: %.4e' % \
                      (dot(mu,x.level()),gamma,dot(m,t.level())))

        return (dot(mu,x.level()), x.level())

def MarkowitzWithTransactionsCost(n,mu,GT,x0,w,gamma,f,g):
    """
        Description:
            Extends the basic Markowitz model with a market cost term.

        Input:
            n: Number of assets
            mu: An n dimensional vector of expected returns
            GT: A matrix with n columns so (GT')*GT  = covariance matrix
            x0: Initial holdings 
            w: Initial cash holding
            gamma: Maximum risk (=std. dev) accepted
            f: If asset j is traded then a fixed cost f_j must be paid
            g: If asset j is traded then a cost g_j must be paid for each unit traded

        Output:
           Optimal expected return and the optimal portfolio     

    """

    # Upper bound on the traded amount
    u = n*[w+sum(x0)]

    with Model("Markowitz portfolio with transaction costs") as M:

        #M.setLogHandler(sys.stdout) 

        # Defines the variables. No shortselling is allowed.
        x = M.variable("x", n, Domain.greaterThan(0.0))

        # Additional "helper" variables 
        z = M.variable("z", n, Domain.unbounded())   
        # Binary variables
        y = M.variable("y", n, Domain.inRange(0.0,1.0), Domain.isInteger())        

        #  Maximize expected return
        M.objective('obj', ObjectiveSense.Maximize, Expr.dot(mu,x))

        # Invest amount + transactions costs = initial wealth
        M.constraint('budget', Expr.add(Expr.add(Expr.sum(x),Expr.dot(f,y)),Expr.dot(g,z)), \
                         Domain.equalsTo(w+sum(x0)))

        # Imposes a bound on the risk
        M.constraint('risk', Expr.vstack(Expr.constTerm([gamma]),Expr.mul(GT,x)), Domain.inQCone())

        # z >= |x-x0| 
        M.constraint('buy', Expr.sub(z,Expr.sub(x,x0)),Domain.greaterThan(0.0))
        M.constraint('sell', Expr.sub(z,Expr.sub(x0,x)),Domain.greaterThan(0.0))
        # Alternatively, formulate the two constraints as
        #M.constraint('trade', Expr.hstack(z.asExpr(),Expr.sub(x,x0)), Domain.inQcone())

        # Constraints for turning y off and on. z-diag(u)*y<=0 i.e. z_j <= u_j*y_j
        M.constraint('y_on_off', Expr.sub(z,Expr.mul(Matrix.diag(u),y)), Domain.lessThan(0.0))

        # Integer optimization problems can be very hard to solve so limiting the 
        # maximum amount of time is a valuable safe guard
        M.setSolverParam('mioMaxTime', 180.0) 
        M.solve()

        if True:
            print("\n-----------------------------------------------------------------------------------");
            print('Markowitz portfolio optimization with transactions cost')
            print("-----------------------------------------------------------------------------------\n");
            print('Expected return: %.4e Std. deviation: %.4e Transactions cost: %.4e' % \
                      (dot(mu,x.level()),gamma,dot(f,y.level())+dot(g,z.level())))

        return (dot(mu,x.level()), x.level())


if __name__ == '__main__':    
    """
    The example
    
        python portfolio.py portfolio    

    reads in data and solves the portfolio models.
    """

    name          = sys.argv[1]

    (n,mu,GT,gammas,x0,w) = ReadData(name)
    print("\n-----------------------------------------------------------------------------------");
    print('Basic Markowitz portfolio optimization')
    print("-----------------------------------------------------------------------------------\n");
    for gamma in gammas:
        er = BasicMarkowitz(n,mu,GT,x0,w,gamma)
        print('Expected return: %.4e Std. deviation: %.4e' % (er,gamma))

    # Some predefined alphas are chosen
    alphas = [0.0, 0.01, 0.1, 0.25, 0.30, 0.35, 0.4, 0.45, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 10.0] 
    frontier= EfficientFrontier(n,mu,GT,x0,w,alphas)
    print("\n-----------------------------------------------------------------------------------");
    print('Efficient frontier') 
    print("-----------------------------------------------------------------------------------\n");
    print('%-12s  %-12s  %-12s' % ('alpha','return','risk')) 
    for i in frontier:
        print('%-12.4f  %-12.4e  %-12.4e' % (i[0],i[1],i[2]))   
                    

    # Somewhat arbitrary choice of m
    m = n*[1.0e-2]
    MarkowitzWithMarketImpact(n,mu,GT,x0,w,gammas[0],m)

    f = n*[0.01]
    g = n*[0.001]
    MarkowitzWithTransactionsCost(n,mu,GT,x0,w,gammas[0],f,g)


