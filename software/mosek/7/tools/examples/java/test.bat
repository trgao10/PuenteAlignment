@echo * Testing Java

set MOSEKJAR=%1

for %%f in (lo1 lo2 cqo1 milo1 mioinitsol qo1 qcqo1 sensitivity feasrepairex1 concurrent1 ) do (
    javac -classpath %MOSEKJAR% -d . %%f.java
)

for %%f in (lo1 lo2 cqo1 milo1 mioinitsol qo1 qcqo1 sensitivity ) do (
    @echo ** Example %%f
    java -classpath %MOSEKJAR%;. com.mosek.example.%%f
)

java -classpath %MOSEKJAR%;. com.mosek.example.concurrent1 ..\data\25fv47.mps

@echo * done testing Java