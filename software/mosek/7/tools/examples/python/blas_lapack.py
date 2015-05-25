# 
# Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
# 
# File:      blas_lapack.py
# 
# Purpose: To demonstrate how to call /LAPACK routines for whose MOSEK provides simplified interfaces.
# 

import mosek

with mosek.Env() as env:

    n=3
    m=2
    k=3

    alpha=2.0
    beta=0.5
  
    x=[1.0,1.0,1.0]
    y=[1.0,2.0,3.0]
    z=[1.0,1.0]
    v=[0.0,0.0]
    #A has m=2 rows and k=3 cols
    A=[ 1.0,1.0,2.0,2.0, 3.,3.]
    #B has k=3 rows and n=3 cols
    B=[ 1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]
    C=[ 0.0 for i in range(n*m)]
    D=[ 1.0,1.0,1.0,1.0]
    Q=[ 1.0,0.0,0.0,2.0]
    
    xy=[]

#  routines

    env.dot(n,x,y)

    env.axpy(n,alpha,x,y)

    env.gemv(mosek.transpose.no, m, n, alpha, A, x, beta,z)

    env.gemm(mosek.transpose.no,mosek.transpose.no,m,n,k,alpha,A,B,beta,C)

    env.syrk(mosek.uplo.lo, mosek.transpose.no, n,k,alpha, A, beta,D)

# LAPACK routines

    env.potrf(mosek.uplo.lo,m,Q)

    env.syeig(mosek.uplo.lo,m,Q,v)

    env.syevd(mosek.uplo.lo,m,Q,v)

