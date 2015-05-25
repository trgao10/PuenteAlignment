--
-- Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
--
-- File:      read_write.lua
--
-- Purpose:   Read a problem from the command line, set some parameters and 
--            write the solution solve it and write the problem, including 
--            solution.
-- 
-- Usage:
--   lmosek read_write.lua [options] inputfile outputile
-- Options:
--   -d PARNAME PARVALUE   Set parameter value.
--   -x                    Don't solve.
--   -v                    Print some extra info.
-- Example (convert file from task to opf):
--   lmosek read_write.lua -x myfile.task myfile.opf
--


do_optimize = true
verbose     = false
inputfile   = nil
outputfile  = nil
params      = {}
-- Arguments are passed in the 'arg' variable. 
-- Loop over all argments and extract options, input and output file names.
do
   local i = 1
   while i <= #arg do
      if     arg[i] == '-d' then
         parname = arg[i+1]
         parval  = arg[i+2]
         params[parname] = parval
         i = i + 3
      elseif arg[i] == '-x' then
         do_optimize = false
         i = i + 1
      elseif arg[i] == '-v' then
         verbose = false
         i = i + 1
      else
         inputfile = arg[i]
         outputfile = arg[i+1]
         i = #arg+1
      end
   end
end

if inputfile == nil then
   print("Missing input and output files.")
elseif outputfile == nil then
   print("Missing output file.")
else
   readdata(inputfile)

   for parname,parval in pairs(params) do 
      -- Call setparam() in protected mode, so if we
      if not pcall(setparam,parname,parval) then
         print(string.format("Warning: Failed to set %s = %s",parname,parval))
      end
   end     
   
   if do_optimize then
      optimize()
      
      if verbose then
         solutionsummary(streamtype.msg)
      end      
   end   

   writedata(outputfile)

   print(string.format("Problem written to: %s",outputfile))
end
