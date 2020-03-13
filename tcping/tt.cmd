@echo off&SETLOCAL
if #%1==# (set _pp=443) else set _pp=%*
echo,**************** The default test Port is: %_pp%
:bg
set /p ip="Please input IP address: "
if "%ip%"=="cc" (cls&goto :bg) else if "%ip%"=="q" goto :eof
for /f "eol=#tokens=1-2delims=:" %%a in ("%ip%") do set _ip=%%a&if "%%b"=="" (set _pt=) else set _pt=%%b
if defined _pt (set _p=%_pt%) else set _p=%_pp%
if defined _ip for %%a in (%_p%) do tcping -i .3 -w 1 -j -f -n 6 -g 3 %_ip% %%a
echo,&goto :bg
ENDLOCAL