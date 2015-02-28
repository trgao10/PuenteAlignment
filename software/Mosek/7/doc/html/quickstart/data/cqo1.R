# cqo1.R

# Specify the non-conic part of the problem.
#
cqo1 <- list(sense = "min")
cqo1$c <- c(0,0,0,1,1,1)
cqo1$A <- Matrix(c(1,1,2,0,0,0), 
                 nrow=1, sparse=TRUE)
cqo1$bc <- rbind(blc = c(1), 
                 buc = c(1))
cqo1$bx <- rbind(blx = c(0,0,0,-Inf,-Inf,-Inf),
                 bux = rep(Inf,6))

# Specify the cones.
#
cqo1$cones <- cbind(list("QUAD", c(4,1,2)),
                    list("RQUAD", c(5,6,3)))
#
# The first field specifies the cone types, i.e., quadratic cone
# or rotated quadratic cone.
#
# The second field specifies the members of the cones (subindexes),
# i.e., the above definitions imply that
#   x(4) >= sqrt(x(1)^2+x(2)^2) and 2 * x(5) * x(6) >= x(3)^2.

# Optimize the problem.
#
r <- mosek(cqo1)

# Display the primal solution.
#
print(r$sol$itr$xx)
