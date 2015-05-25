#
# Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
# File:      TrafficNetworkModel.py
#
# Purpose:   Demonstrates a traffix network problem as a conic quadratic problem.
#
# Source:    Robert Fourer, "Convexity Checking in Large-Scale Optimization", 
#            OR 53 --- Nottingham 6-8 September 2011.
#
# The problem: 
#            Given a directed graph representing a traffic network
#            with one source and one sink, we have for each arc an
#            associated capacity, base travel time and a
#            sensitivity. Travel time along a specific arc increases
#            as the flow approaches the capacity. 
#
#            Given a fixed inflow we now wish to find the
#            configuration that minimizes the average travel time.

from mosek.fusion import *
import sys


class TrafficNetworkError(Exception): pass

class TrafficNetworkModel(Model):
    def __init__(self,
                 numberOfNodes,
                 source_idx,
                 sink_idx,
                 arc_i,
                 arc_j,
                 arcSensitivity,
                 arcCapacity,
                 arcBaseTravelTime,
                 T):
        Model.__init__(self,"Traffic Network")
        finished = False
        try:
          n = numberOfNodes
          narcs = len(arc_i)
          
          NxN = NDSet(n, n)
          sens     = Matrix.sparse(n, n, arc_i, arc_j, arcSensitivity)
          cap      = Matrix.sparse(n, n, arc_i, arc_j, arcCapacity)     
          basetime = Matrix.sparse(n, n, arc_i, arc_j, arcBaseTravelTime)
          e        = Matrix.sparse(n, n, arc_i, arc_j, [ 1.0 ] * narcs)
          e_e      = Matrix.sparse(n,n, [ sink_idx ],[ source_idx ], [ 1.0 ]);
          
          cs_inv_matrix = \
            Matrix.sparse(n, n, arc_i, arc_j, 
                          [ 1.0 / (arcSensitivity[i] * arcCapacity[i]) for i in range(narcs)])
          s_inv_matrix = \
            Matrix.sparse(n, n, arc_i, arc_j, 
                          [ 1.0 / arcSensitivity[i] for i in range(narcs)])

          self.__flow       = self.variable("traffic_flow", NxN, Domain.greaterThan(0.0))
          
          x = self.__flow;
          t = self.variable("travel_time" , NxN, Domain.greaterThan(0.0))
          d = self.variable("d",            NxN, Domain.greaterThan(0.0))
          z = self.variable("z",            NxN, Domain.greaterThan(0.0))

          # Set the objective:
          self.objective("Average travel time",
                         ObjectiveSense.Minimize,
                         Expr.mul(1.0/T, Expr.add(Expr.dot(basetime,x), Expr.dot(e,d))))

          # Set up constraints
          # Constraint (1a)
          numnz = len(arcSensitivity)

          v = Variable.stack([ [ d.index(arc_i[i],arc_j[i]), 
                                 z.index(arc_i[i],arc_j[i]), 
                                 x.index(arc_i[i],arc_j[i]) ] for i in range(narcs) ])


          self.constraint("(1a)",v, Domain.inRotatedQCone(narcs,3))

          # Constraint (1b)
          self.constraint("(1b)",
                          Expr.sub(Expr.add(Expr.mulElm(z,e),
                                            Expr.mulElm(x,cs_inv_matrix)),
                                   s_inv_matrix),
                          Domain.equalsTo(0.0))
          # Constraint (2)
          self.constraint("(2)",
                          Expr.sub(Expr.add(Expr.mulDiag(x, e.transpose()),
                                            Expr.mulDiag(x, e_e.transpose())),
                                   Expr.add(Expr.mulDiag(x.transpose(), e),
                                            Expr.mulDiag(x.transpose(), e_e))),
                          Domain.equalsTo(0.0))
          # Constraint (3)
          self.constraint("(3)",x.index(sink_idx, source_idx), Domain.equalsTo(T))
          finished = True
        finally:
          if not finished:
            self.__del__()

    # Return the solution. We do this the easy and inefficeint way:
    # We fetch the whole NxN array og values, a lot of which are
    # zeros.
    def getFlow(self):
        return self.__flow.level()



def main(args):
    n        = 4
    arc_i    = [  0,    0,    2,    1,    2 ]
    arc_j    = [  1,    2,    1,    3,    3 ]
    arc_base = [  4.0,  1.0,  2.0,  1.0,  6.0 ]
    arc_cap  = [ 10.0, 12.0, 20.0, 15.0, 10.0 ]
    arc_sens = [  0.1,  0.7,  0.9,  0.5,  0.1 ]

    T          = 20.0
    source_idx = 0
    sink_idx   = 3
    
    with TrafficNetworkModel(n, source_idx, sink_idx,
                            arc_i, arc_j,
                            arc_sens,
                            arc_cap,
                            arc_base,
                            T) as M:
      M.solve()

      
      flow = M.getFlow()
      
      print("Optimal flow:")
      for i,j in zip(arc_i,arc_j):
          print "\tflow node%d->node%d = %f" % (i,j, flow[i * n + j])

main(sys.argv[1:])
