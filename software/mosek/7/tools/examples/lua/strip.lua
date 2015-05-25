--
-- Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.
--
-- File:      strip.lua
--
-- Purpose:   Read a problem from the command line, strip out all names and write it to a new file.
-- 
-- Usage:
--   lmosek strip.lua inputfile outputile
-- Example:
--   lmosek strip.lua myfile.opf mystrippedfile.task

readdata(arg[1])


-- clear all variable names
if getnumvar() > 0 then
   for i=1,getnumvar() do
      setvarname(i-1,"")
   end
end

-- clear all constraint names
if getnumcon() > 0 then
   for i=1,getnumcon() do
      setconname(i-1,"")
   end
end

-- clear all cone names
if getnumcone() > 0 then
   for i=1,getnumcone() do
      setconename(i-1,"")
   end
end

-- clear objective and task names
putobjname("")
puttaskname("")

-- clear string parameters
for k,v in pairs(sparam) do
   setparam(v,"")
end

-- write the stripped output file
writedata(arg[2])