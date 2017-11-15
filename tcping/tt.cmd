@echo off
:bg
SETLOCAL&set _port=443
set /p ip="Please input IP address: "
if "%ip%"=="cc" (cls&ENDLOCAL&goto :bg) else if "%ip%"=="q" ENDLOCAL&goto :eof
for /f "eol=#tokens=1-2delims=:" %%a in ("%ip%") do set _ip=%%a&if not "%%b"=="" set _port=%%b
if defined _ip tcping -i .3 -w 1 -j -f -n 6 -g 3 %_ip% %_port%
echo,&ENDLOCAL
goto :bg