%%
%  File : portfolio.m
%
%  Copyright : Copyright (c) MOSEK ApS, Denmark. All rights reserved.
%
%  Description :
%    Presents several portfolio optimization models.
% 
%%

function portfolio(name)
%
%    The example
%    
%       portfolio(name)
%
%    reads in data and solves the portfolio models.
%

[n,mu,GT,gammas,x0,w] = ReadData(name);

disp('Markowitz portfolio optimization')
for gamma = gammas'
    er = BasicMarkowitz(n,mu,GT,x0,w,gamma);
    disp(sprintf('Expected return: %.4e Std. deviation: %.4e', er, gamma));
end

% Some predefined alphs are chosen
alphas = [0.0, 0.01, 0.1, 0.25, 0.30, 0.35, 0.4, 0.45, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 10.0];
EfficientFrontier(n,mu,GT,x0,w,alphas);

% Somewhat arbirtrary choice of m
m = 1.0e-2*ones(n,1);
MarkowitzWithMarketImpact(n,mu,GT,x0,w,gammas(1),m);

f = 0.01*ones(n,1);
g = 0.001*ones(n,1);
MarkowitzWithTransactionsCost(n,mu,GT,x0,w,gamma,f,g);


function [n, mu, GT, gammas, x0, w] = ReadData(name)
% 
%  Reads data from several files.
%     
import mosek.fusion.*;

n = csvread(sprintf('%s-n.txt',name));

gammas = csvread(sprintf('%s-gammas.csv',name));

mu = csvread(sprintf('%s-mu.csv',name));

GT = DenseMatrix(csvread(sprintf('%s-GT.csv',name)));

x0 = csvread(sprintf('%s-x0.csv',name));

w = csvread(sprintf('%s-w.csv',name));


function er = BasicMarkowitz(n,mu,GT,x0,w,gamma)
%
%    Purpose:
%        Computes the optimal portfolio for a given risk 
%     
%    Input:
%        n: Number of assets
%        mu: An n dimmensional vector of expected returns
%        GT: A matrix with n columns so (GT')*GT  = covariance matrix
%        x0: Initial holdings 
%        w: Initial cash holding
%        gamma: Maximum risk (=std. dev) accepted
%     
%    Output:
%        Optimal expected return and the optimal portfolio     
%

import mosek.fusion.*;

M = Model('Basic Markowitz');

% Redirect log output from the solver to stdout for debugging. 
% if uncommented.
%M.setLogHandler(java.io.PrintWriter(java.lang.System.out));
    
% Defines the variables (holdings). Shortselling is not allowed.
x = M.variable('x', n, Domain.greaterThan(0.0));
    
%  Maximize expected return
M.objective('obj', ObjectiveSense.Maximize, Expr.dot(mu,x));

% The amount invested  must be identical to intial wealth
M.constraint('budget', Expr.sum(x), Domain.equalsTo(w+sum(x0)));

% Imposes a bound on the risk
M.constraint('risk', Expr.vstack(Expr.constTerm([gamma]),Expr.mul(GT,x)), Domain.inQCone());

% Solves the model.
M.solve();

er = mu'*x.level();

M.dispose();

function frontier = EfficientFrontier(n,mu,GT,x0,w,alphas)
%
%    Purpose:
%        Computes several portfolios on the optimal portfolios by 
%
%            for alpha in alphas: 
%                maximize   expected return - alpha * standard deviation
%                subject to the constraints  
%        
%    Input:
%        n: Number of assets
%        mu: An n dimmensional vector of expected returns
%        GT: A matrix with n columns so (GT')*GT  = covariance matrix
%        x0: Initial holdings 
%        w: Initial cash holding
%        alphas: List of the alphas
%                    
%    Output:
%        The efficient frontier as list of tuples (alpha,expected return,risk)
%
import mosek.fusion.*;
    
M = Model('Efficient frontier');
    
%M.setLogHandler(java.io.PrintWriter(java.lang.System.out));
 
% Defines the variables (holdings). Shortselling is not allowed.
x = M.variable('x', n, Domain.greaterThan(0.0)); % Portfolio variables
s = M.variable('s', 1, Domain.unbounded()); % Risk variable

M.constraint('budget', Expr.sum(x), Domain.equalsTo(w+sum(x0)));

% Computes the risk
M.constraint('risk', Expr.vstack(s.asExpr(),Expr.mul(GT,x)),Domain.inQCone());

frontier = [];

for alpha = alphas

    %  Define objective as a weighted combination of return and risk
    M.objective('obj', ObjectiveSense.Maximize, Expr.sub(Expr.dot(mu,x),Expr.mul(alpha,s)));

    M.solve();
       
    frontier = [frontier; [alpha,mu'*x.level(),s.level()] ];

    if true
        disp(sprintf('\nEfficient frontier'))
        disp(sprintf('%-12s  %-12s  %-12s', 'alpha', 'return', 'risk')) 
        disp(sprintf('%-12.4f  %-12.4e  %-12.4e', ...
                     frontier(end,1), frontier(end,2), frontier(end,3)));
    end
end

M.dispose();

function [er, x] = MarkowitzWithMarketImpact(n,mu,GT,x0,w,gamma,m)
%
%        Description:
%            Extends the basic Markowitz model with a market cost term.
%
%        Input:
%            n: Number of assets
%            mu: An n dimmensional vector of expected returns
%            GT: A matrix with n columns so (GT')*GT  = covariance matrix
%            x0: Initial holdings 
%            w: Initial cash holding
%            gamma: Maximum risk (=std. dev) accepted
%            m: It is assumed that  market impact cost for the j'th asset is
%               m_j|x_j-x0_j|^3/2
%
%        Output:
%           Optimal expected return and the optimal portfolio     
%
import mosek.fusion.*;
            
M = Model('Markowitz portfolio with market impact');

%M.setLogHandler(java.io.PrintWriter(java.lang.System.out));
    
% Defines the variables. No shortselling is allowed.
x = M.variable('x', n, Domain.greaterThan(0.0));

% Addtional "helper" variables 
t = M.variable('t', n, Domain.unbounded());
z = M.variable('z', n, Domain.unbounded());  
v = M.variable('v', n, Domain.unbounded());        

%  Maximize expected return
M.objective('obj', ObjectiveSense.Maximize, Expr.dot(mu,x));

% Invested amount + slippage cost = initial wealth
M.constraint('budget', Expr.add(Expr.sum(x),Expr.dot(m,t)), Domain.equalsTo(w+sum(x0)));

% Imposes a bound on the risk
M.constraint('risk', Expr.vstack(Expr.constTerm(gamma),Expr.mul(GT,x)), Domain.inQCone());

% z >= |x-x0| 
M.constraint('buy', Expr.sub(z,Expr.sub(x,x0)),Domain.greaterThan(0.0));
M.constraint('sell', Expr.sub(z,Expr.sub(x0,x)),Domain.greaterThan(0.0));

% t >= z^1.5, z >= 0.0. Needs two rotated quadratic cones to model this term
M.constraint('ta', Expr.hstack(v.asExpr(),t.asExpr(),z.asExpr()),Domain.inRotatedQCone());
M.constraint('tb', Expr.hstack(z.asExpr(),Expr.constTerm(n,1.0/8.0),v.asExpr()),...
             Domain.inRotatedQCone());

M.solve();

if true
    disp(sprintf('\nMarkowitz portfolio optimization with market impact cost'))
    disp(sprintf('Expected return: %.4e Std. deviation: %.4e Market impact cost: %.4e', ...
                 mu'*x.level(),gamma,m'*t.level()))
end

er = mu'*x.level();
x  = x.level();
M.dispose();

function [er, x] = MarkowitzWithTransactionsCost(n,mu,GT,x0,w,gamma,f,g)
%
%        Description:
%            Extends the basic Markowitz model with a market cost term.
%
%        Input:
%            n: Number of assets
%            mu: An n dimmensional vector of expected returns
%            GT: A matrix with n columns so (GT')*GT  = covariance matrix
%            x0: Initial holdings 
%            w: Initial cash holding
%            gamma: Maximum risk (=std. dev) accepted
%            f: If asset j is traded then a fixed cost f_j must be paid
%            g: If asset j is traded then a cost g_j must be paid for each unit traded
%
%        Output:
%           Optimal expected return and the optimal portfolio     
%
import mosek.fusion.*;

% Upper bound on the traded amount
u = (w+sum(x0))*ones(n,1);

M = Model('Markowitz portfolio with transaction costs');

%M.setLogHandler(java.io.PrintWriter(java.lang.System.out));

% Defines the variables. No shortselling is allowed.
x = M.variable('x', n, Domain.greaterThan(0.0));

% Addtional "helper" variables 
z = M.variable('z', n, Domain.unbounded());
% Binary varables
y = M.variable('y', n, Domain.inRange(0.0,1.0), Domain.isInteger());

%  Maximize expected return
M.objective('obj', ObjectiveSense.Maximize, Expr.dot(mu,x));

% Invest amount + transactions costs = initial wealth
M.constraint('budget', Expr.add(Expr.add(Expr.sum(x),Expr.dot(f,y)),Expr.dot(g,z)), ...
             Domain.equalsTo(w+sum(x0)));

% Imposes a bound on the risk
M.constraint('risk', Expr.vstack(Expr.constTerm([gamma]),Expr.mul(GT,x)), Domain.inQCone());

% z >= |x-x0| 
M.constraint('buy', Expr.sub(z,Expr.sub(x,x0)),Domain.greaterThan(0.0));
M.constraint('sell', Expr.sub(z,Expr.sub(x0,x)),Domain.greaterThan(0.0));
% Alternatively, formulate the two constraints as
%M.constraint('trade', Expr.hstack(z.asExpr(),Expr.sub(x,x0)), Domain.inQcone())

% Constraints for turning y off and on. z-diag(u)*y<=0 i.e. z_j <= u_j*y_j
M.constraint('y_on_off', Expr.sub(z,Expr.mul(Matrix.diag(u),y)), Domain.lessThan(0.0));

% Integer optimization problems can be very hard to solve so limiting the 
% maximum amount of time is a valuable safe guard
M.setSolverParam('mioMaxTime', 180.0); 
M.solve();

if true
    disp(sprintf('\nMarkowitz portfolio optimization with transactions cost'))
    disp(sprintf('Expected return: %.4e Std. deviation: %.4e Transactions cost: %.4e', ...
                 mu'*x.level(),gamma,f'*y.level()+g'*z.level()))
end

er = mu'*x.level();
x  = x.level();
M.dispose();
