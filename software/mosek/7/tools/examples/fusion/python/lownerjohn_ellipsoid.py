##
#  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#  File:      lownerjohn_ellipsoid.py
#
#  Purpose: 
#  Computes the Lowner-John inner and outer ellipsoidal 
#  approximations of a polytope.
#
#
#  Note:
#  To plot the solution the Python package pyx is required.
#  
#
#  References:
#    [1] "Lectures on Modern Optimization", Ben-Tal and Nemirovski, 2000. 
#    [2] "MOSEK modeling manual", 2013
#
#
##########################################################################

import sys
from math import sqrt, ceil, log
import mosek
from   mosek.fusion import *


def geometric_mean(M,x,t):
  '''
  Models the convex set 

    S = { (x, t) \in R^n x R | x >= 0, t <= (x1 * x2 * ... * xn)^(1/n) }

  as  the intersection of rotated quadratic cones and affine hyperplanes.
  see [1, p. 105] or [2, p. 21].  This set can be interpreted as the hypograph of the 
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
    [2] "MOSEK modeling manual", 2013

  '''


  def rec(x):
    n = x.shape.dim(0)
    if n > 1:
      y = M.variable(n/2, Domain.unbounded())
      M.constraint(Variable.hstack(Variable.reshape(x, NDSet(n/2,2)), y), Domain.inRotatedQCone())
      return rec(y)
    else:
      return x
  
  n = x.shape.dim(0)
  l = int(ceil(log(n, 2)))
  m = int(2**l) - n

  # if size of x is not a power of 2 we pad it:
  if m > 0:
    x_padding = M.variable(m,Domain.unbounded())

    # set the last m elements equal to t
    M.constraint(Expr.sub(x_padding, Variable.repeat(t,m)), Domain.equalsTo(0.0))

    x = Variable.vstack(x,x_padding)

  M.constraint(Expr.sub(Expr.mul(2.0**(l/2.0), t),rec(x)), Domain.equalsTo(0.0))

def det_rootn(M, X, t):
    '''

     Purpose: Models the hypograph of the n-th power of the
     determinant of a positive definite matrix. See [1,2] for more details.

       The convex set (a hypograph)

       C = { (X, t) \in S^n_+ x R |  t <= det(X)^{1/n} },

       can be modeled as the intersection of a semidefinite cone
 
       [ X, Z; Z^T Diag(Z) ] >= 0  

       and a number of rotated quadratic cones and affine hyperplanes,

       t <= (Z11*Z22*...*Znn)^{1/n}  (see geometric_mean).

       References:
       [1] "Lectures on Modern Optimization", Ben-Tal and Nemirovski, 2000. 
       [2] "MOSEK modeling manual", 2013
    '''
    n = int(sqrt(X.size()))

    # Setup variables
    Y = M.variable(Domain.inPSDCone(2*n))    
    
    # Setup Y = [X, Z; Z^T , diag(Z)] 
    Y11 = Y.slice([0, 0], [n, n])
    Y21 = Y.slice([n, 0], [2*n, n])
    Y22 = Y.slice([n, n], [2*n, 2*n])

    S = Matrix.sparse(n, n, range(n), range(n), n*[1.0])
    M.constraint( Expr.sub(Expr.mulElm(S,Y21), Y22), Domain.equalsTo(0.0) )
    M.constraint( Expr.sub(X, Y11), Domain.equalsTo(0.0) )

    # t^n <= (Z11*Z22*...*Znn)
    geometric_mean(M, Y22.diag(), t)


def lownerjohn_inner(A, b):
    '''
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

    References:    
    [1] "Lectures on Modern Optimization", Ben-Tal and Nemirovski, 2000. 
   '''

    with Model("lownerjohn_inner") as M:
        M.setLogHandler(sys.stdout) 
        m, n = len(A), len(A[0])   

        # Setup variables
        t = M.variable("t", 1, Domain.greaterThan(0.0))        
        C = M.variable("C", NDSet(n,n), Domain.unbounded())
        d = M.variable("d", n, Domain.unbounded())        
    
        # (bi - ai^T*d, C*ai) \in Q, i=1..m
        A = DenseMatrix(A)
        M.constraint("qc", Expr.hstack(Expr.sub(b, Expr.mul(A,d)), Expr.mul(A,C.transpose())), Domain.inQCone())
        # t <= det(C)^{1/n}
        det_rootn(M, C, t)
                           
        # Objective: Maximize t
        M.objective(ObjectiveSense.Maximize, t)

        M.solve()
    
        C, d = C.level(), d.level()
        return ([C[i:i+n] for i in range(0,n*n,n)], d)

def lownerjohn_outer(x):
    '''
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
    '''
    
    with Model("lownerjohn_outer") as M:
        m, n = len(x), len(x[0])   
    	M.setLogHandler(sys.stdout)
	# Setup variables
	t = M.variable("t", 1, Domain.greaterThan(0.0))
        P = M.variable("P", NDSet(n,n), Domain.unbounded())
        c = M.variable("c", n, Domain.unbounded())        

	# (1, P(*xi+c)) \in Q 
	M.constraint("qc",
                 Expr.hstack(Expr.constTerm(m,1.0),
                             Expr.sub(Expr.mul(DenseMatrix(x),P.transpose()),
                                      Variable.reshape(Variable.repeat(c,m),NDSet(m,2)))),
                 Domain.inQCone())

        # t <= det(P)^{1/n}
        det_rootn(M, P, t)
                       
        # Objective: Maximize t
        M.objective(ObjectiveSense.Maximize, t)
        M.solve()
    
        P, c = P.level(), c.level()
        return ([P[i:i+n] for i in range(0,n*n,n)], c)



#############################################################################################

if __name__ == '__main__':

  #few points in 2D

  p = [ [0.,0.], [1.,3.], [5.,4.], [7.,1.], [3.,-2.] ]

  Po, co = lownerjohn_outer(p)
  

  A = [ [-p[i][1]+p[i-1][1],p[i][0]-p[i-1][0]] for i in range(len(p)) ]
  b = [ A[i][0]*p[i][0]+A[i][1]*p[i][1] for i in range(len(p)) ]

  Ci, di = lownerjohn_inner(A, b)


  try:
      import numpy

      from pyx import *

      Po  = numpy.array(Po)
      Poi = numpy.linalg.inv(Po)
      co  = numpy.array(co)
            
      c = canvas.canvas()
      c.stroke(box.polygon(p).path(), [style.linestyle.dashed])        
      c.stroke(path.circle(0, 0, 1), [trafo.trafo(Ci, di)])
      c.stroke(path.circle(0, 0, 1), [trafo.trafo(Poi, numpy.dot(Poi,co))])
      for pi in p:
          c.fill(path.circle(pi[0],pi[1],0.08))

      c.writePDFfile("lownerjohn")
  except:
      pass
