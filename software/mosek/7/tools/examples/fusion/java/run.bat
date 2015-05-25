
setlocal
set EXAMPDIR=%~d0%~p0

if exist %EXAMPDIR%\..\..\..\platform\win64x86. (
    set PLATFORM=%EXAMPDIR%\..\..\..\platform\win64x86
    ) else (
    set PLATFORM=%EXAMPDIR%\..\..\..\platform\win32x86
    )

java -d64 -Djava.library.path="%PLATFORM%\bin;c:\windows" -classpath "%PLATFORM%\bin\mosek.jar;examples.jar" com.mosek.fusion.examples.%1


