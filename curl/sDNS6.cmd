@echo off&cd /d "%~dp0"&SETLOCAL
for /f "tokens=2-3delims=. " %%b in ('curl -V 2^>nul^|find/i "ssl"') do set _cv=%%b%%c&goto :next
:next
if defined _cv (if 1%_cv% lss 1749 echo,CURL version is too old, please update!&pause>nul&goto :EOF) else echo,curl.exe does not exist or not support SSL! please download:&echo,https://curl.haxx.se/download.html#Win32&pause>nul&goto :EOF

set _=^&echo,  sdns&set _sip=2607:f8b0:4006:805::2003

if "%1"=="" (
  echo,Usage:%_% Domain [edns_client_subnet]%_% www.google.com%_% www.google.com 42.112.8.19&&goto :eof
) else (
  if "%2"=="" (for /f %%c in ('curl -q -0sSm2 --retry 1 ip.6655.com/ip.aspx') do set _ed=%%c) else set _ed=%2
)
echo edns_client_subnet is: %_ed%&echo,

rem curl -sm2 --retry 1 --resolve dns.google.com:443:219.76.4.4 https://dns.google.com/resolve?name=%1^&edns_client_subnet=
rem for /f "delims=" %%c in ('curl -q -0sSm3 -Gdname^=%1 --retry 1 --connect-to ::%_sip% https://dns.google.com/resolve?edns_client_subnet^=%_ed%') do set #json=%%c
for /f "delims=" %%c in ('curl -q -0sSm3 -Gdname^=%1 --retry 1 -6 https://dns.google.com/resolve?edns_client_subnet^=%_ed%') do set #json=%%c
if not defined #json echo,	[%_sip%]&goto :eof

set #json=%#json:[=%
set #json=%#json:]=%
set #json=%#json:{=%
set #json=%#json:}=%
set #json=%#json:: =:%
echo,%1
for /f "tokens=1-3delims=:" %%a in ('for %%Z in (%#json%^)do @echo %%Z') do (
rem 	if defined _fd echo %%~a
rem 	if %%a=="data" (set _fd=1) else set _fd=
	if %%a=="data" echo %%~b
rem 	if #%%~c==# (echo %%a:	%%b) else echo "%%~a.%%~b":	%%c
)

goto :eof

