--
-- Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
--
-- File:      lo1.lua
--
-- Purpose:   Demonstrates how to input and solve a small
--            optimization problem in Mosek/LUA.
-- 


local numcon = 3
local numvar = 4
local numanz = 9
    
    -- Since the value infinity is never used, we define
    -- 'infinity' symbolic purposes only
local infinity = 0.0
    
local c    = { 3.0, 1.0, 5.0, 1.0 }
local asub = { { 0,1 },
               { 0,1,2 },
               { 0,1 },
               { 1,2 } }
local aval = { { 3.0, 2.0 },
               { 1.0, 1.0, 2.0 },
               { 2.0, 3.0 },
               { 1.0, 3.0 } }
local bkc  = { boundkey.fx,
               boundkey.lo,
               boundkey.up }
local blc  = { 30.0,
               15.0,
             - infinity }
local buc  = { 30.0,
               infinity,
               25.0 }
local bkx  = { boundkey.lo,
               boundkey.ra,
               boundkey.lo,
               boundkey.lo }
local blx  = { 0.0,
               0.0,
               0.0,
               0.0 }
local bux  = { infinity,
               10.0,
               infinity,
               infinity }

-- Append (numcon) empty constraints.
-- The constraints will initially have no bounds.
append(accmode.con,numcon)
-- Append (numvar) variables.
-- The variables will initially be fixed at zero (x=0).
append(accmode.var,numvar)

-- Optionally add a constant term to the objective. 
putcfix(0.0)
for j=1,numvar do
   -- Set the linear term c_j in the objective.
   putcj(j-1,c[j])
   -- Set the bounds on variable j.
   --   blx[j] <= x_j <= bux[j] 
   putbound(accmode.var,j-1,bkx[j],blx[j],bux[j])
   -- Input column j of A
   putavec(accmode.var, -- Input columns of A.
           j-1,         -- Variable (column) index.
           asub[j],     -- Row index of non-zeros in column j.
           aval[j])     -- Non-zero Values of column j. 
end
-- Set the bounds on constraints.
--   for i=1, ...,numcon : blc[i] <= constraint i <= buc[i] */
for i=1,numcon do
   putbound(accmode.con,i-1,bkc[i],blc[i],buc[i])
end
putobjsense(objsense.maximize)
optimize()
-- Print a summary containing information
--   about the solution for debugging purposes
solutionsummary(streamtype.msg)
        
-- Get status information about the solution 
local prostatus,solstatus = getsolutionstatus(soltype.bas)
local xx = getxx(soltype.bas) -- Basic solution.     
     
print(string.format("Solution status = %s",solstatus))
if     ( solstatus == solsta.optimal or
         solstatus == solsta.near_optimal ) then
   for i=1,#xx do
      print(string.format("xx[%d] = %s",i,xx[i]))
   end
elseif ( solstatus == solsta.prim_infeas_cer or
         solstatus == solsta.dual_infeas_cer or
         solstatus == solsta.neat_prim_infeas_cer or
         solstatus == solsta.near_dual_infeas_cer ) then
   print("Primal or dual infeasibility.")
end