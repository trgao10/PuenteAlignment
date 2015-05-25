echo off
setlocal
set EXAMPDIR=%~d0%~p0

if exist %EXAMPDIR%\..\..\..\platform\win64x86. (
    set PLATFORM=%EXAMPDIR%\..\..\..\platform\win64x86.
    ) else (
    set PLATFORM=%EXAMPDIR%\..\..\..\platform\win32x86.
    )

echo javac -classpath "%PLATFORM%\bin\mosek.jar" -d . %EXAMPDIR%\*.java 
javac -classpath "%PLATFORM%\bin\mosek.jar" -d . %EXAMPDIR%\*.java
echo jar cvf .\examples.jar mosek\fusion\examples
jar cvf .\examples.jar com\mosek\fusion\examples
echo "Successfully built .\/examples.jar"


