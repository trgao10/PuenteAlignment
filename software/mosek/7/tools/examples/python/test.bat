@echo *** Testing Python

for %%f in ( lo1 lo2 qo1 cqo1 sdo1 qcqo1 sensitivity milo1 ) do (
  @echo Example: %%f.py
  python %%f.py 
)


for %%f in ( concurrent1 concurrent2 ) do (    
  @echo Example: %%f.py"
  python %%f.py ..\data\25fv47.mps
)

@echo done python
