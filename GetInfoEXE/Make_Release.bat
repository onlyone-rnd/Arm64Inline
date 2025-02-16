@echo off

SET FILENAME=getinfoexe
SET COMPCMD=-nologo -win64 /Zp8 -I%INCPATH64% -I%MACPATH64%
SET LINKCMD=/SUBSYSTEM:WINDOWS,5.2 /RELEASE /NODEFAULTLIB:"msvcrt.lib" /LIBPATH:%LIBPATH64%

if not exist "res\rsrc.rc" goto over1
%RS64% /v "res\rsrc.rc"
%CVTRES64% /machine:ix86 "res\rsrc.res"

:over1

if exist "%FILENAME%.exe" del "%FILENAME%.exe"

%COMPATH64% %COMPCMD% "%FILENAME%.asm"
if errorlevel 1 goto errasm

if not exist "res\rsrc.obj" goto nores

%LNKPATH64% %LINKCMD% "%FILENAME%.obj" "res\rsrc.res"
 if errorlevel 1 goto errlink

dir "%FILENAME%.*"
goto TheEnd

:nores
%LNKPATH64% %LINKCMD% "%FILENAME%.obj"
 if errorlevel 1 goto errlink
dir "%FILENAME%.*"
goto TheEnd

:errlink
 echo _
echo Link error
goto TheEnd

:errasm
 echo _
echo Assembly Error
goto TheEnd

:TheEnd

if exist "*.obj" del "*.obj"
if exist "res\*.obj" del "res\*.obj"
if exist "*.pdb" del "*.pdb"
if exist "res\*.res" del "res\*.res"

pause
