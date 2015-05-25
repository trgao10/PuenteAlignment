echo off
setlocal
set EXAMPDIR=%~d0%~p0

if exist %EXAMPDIR%\..\..\..\platform\win64x86. (
    set PLATFORM=%EXAMPDIR%\..\..\..\platform\win64x86
    ) else (
    set PLATFORM=%EXAMPDIR%\..\..\..\platform\win32x86
    )

copy /y %PLATFORM%\bin\mosekdotnet.dll .
echo csc /r:mosekdotnet.dll /target:exe /out:%1.exe %1.cs
csc /r:%PLATFORM%\bin\mosekdotnet.dll /target:exe /out:%1.exe %1.cs


