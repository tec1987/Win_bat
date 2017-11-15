@echo off&cd /d "%~dp0"&SETLOCAL&set "_fdp=%~dp0"
rem 使用多个DNS查询指定域名/列表，输出为 Unbound 的 local-data: 格式
set _dns=202.96.128.86 208.67.220.220 202.96.134.133 202.96.128.166 208.67.222.222
set _otf=DLD
if "%~d1" neq "" (
    rem echo 检测到参数，处理输入参数&echo,%cmdcmdline%
    set "str=%cmdcmdline:"=%"
    SETLOCAL ENABLEDELAYEDEXPANSION&set _slf=1
    set "_inp=%~1"&call :_fle
    if "!_isf!"=="1" (
	for %%d in (%_dns%) do call :_dgd %~1 %%d
	echo,&echo,  --OK	%~1&ENDLOCAL&goto :eof
    )
    set "str=!str:%~f0 =!"
    set "str=!str: %~d1=" "%~d1!"
    for %%n in ("!str!") do (
	if defined _slf ENDLOCAL
	if exist "%%~fn\" (cls&echo "%%~fn"是目录，不是有效的文件，跳过！&echo,) else if exist "%%~fn" (
	    title "%~f0" "%%~fn"&set _id=1&set "_otn=%%~nn"
	    for /f "eol=# usebackq" %%p in ("%%~fn") do (set "_inp=%%p"&call :_fle
		SETLOCAL ENABLEDELAYEDEXPANSION&if "!_isf!"=="1" (
		    for %%d in (%_dns%) do call :_dg %%p %%d
		    echo,!_id!		#>>%_otf%_!_otn!.conf
		    echo,!_id!	OK	%%p&ENDLOCAL&set/a_id+=1
		) else ENDLOCAL
	    )
	)
    )
)

echo,&echo 完成，按任意键退出。&pause>nul
goto :eof

:_fle	rem 输入内容有效性验证，判断是否为IP或域名，为IP时 _isf=0，为域名时 _isf=1，否则不定义 _isf
    set _isf=&SETLOCAL ENABLEDELAYEDEXPANSION&rem echo 输入：!_inp! 先将_isf清空，避免使用上次的_isf，也可在主循环中处理
    if defined _inp (rem 判断是否含有引号以及无效字符
	set "_in1=!_inp:"=#!"
	set "_in2=!_inp:"=@!"
	if "!_in1!" neq "!_in2!" ENDLOCAL&goto :eof	rem !_inp!包含引号，不能继续判断
	for /f "tokens=*delims=0123456789.abcdefghijklmnopqrstuvwxyz-ABCDEFGHIJKLMNOPQRSTUVWXYZ eol=" %%a in ("!_inp!")do if "%%a" neq "" ENDLOCAL&goto :eof
	set _in1=!_inp:..=!
	if "!_in1!" neq "!_inp!" ENDLOCAL&goto :eof	rem 有多余的连续句点
	set _b=!_inp:~0,1!&set _e=!_inp:~-1!
	if "!_b!"=="." ENDLOCAL&goto :eof	rem 首有多余句点。。。
rem	if "!_e!"=="." set _psf=1&rem echo 尾有多余句点。。。暂不处理，可能是域名
	set _in2=!_inp:.=;!
	if "!_in2!"=="!_inp!" ENDLOCAL&goto :eof	rem 不包含句点。。。

	set/a _ii=_it=0
	for %%c in (!_in2!) do (
	    set/a _ii+=1&set _!_ii!=%%c
	    if %%c leq 255 if %%c geq 0 set/a _it+=1
	    call set _bb=%%_!_ii!:~0,1%%&call set _ee=%%_!_ii!:~-1%%
	    if !_bb!==- ENDLOCAL&goto :eof	rem 有多余的横线-。
	    if !_ee!==- ENDLOCAL&goto :eof	rem 有多余的横线-。
	)
	for /f "tokens=*delims=0123456789. eol=" %%a in ("!_inp!") do if "%%a"=="" (if !_e! neq . if !_it! equ 4 if !_ii! equ 4 set _isf=0) else (
	rem echo 不是IP，判断是否为域名
	    for %%c in (!_ii!) do set _tld=!_%%c!
	    for /f "tokens=*delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" %%a in ("!_tld!") do if "%%a"=="" (
		for %%z in (com net org info biz name pro edu gov int club asia) do if !_tld!==%%z set _isf=1&rem echo 是常见的通用域名后缀
		if !_tld!==!_tld:~-2! if !_tld! neq !_tld:~-1! set _isf=1&rem echo 后缀是两个字母，可以认为是域名
	    )
	)
	if defined _isf (for %%a in (!_isf!) do ENDLOCAL&set _isf=%%a)&goto :eof	rem 是有效的IP或域名
    )
ENDLOCAL&goto :eof

:_dg
  for /f "tokens=4-5" %%d in ('dig @%2 +noall +answer %1^|findstr "\<CNAME\> \<A\>"') do (
  	if "%%d"=="A" (
  		if not defined _d set _d=_&echo,!_id!	    local-zone: "%1" static	#!_c!	#%2>>%_otf%_%_otn%.conf
  		if not defined %%e set %%e=_&echo,!_id!		 local-data: "%1 300 IN A %%e"	#%2>>%_otf%_%_otn%.conf
  	) else set _c=!_c! %%e
  )
  rem echo,!_id!		#>>%_otf%_%_otn%.conf
  goto :eof

:_dgd
for /f "tokens=1-5" %%a in ('dig @%2 +noall +answer %1^|findstr "\<CNAME\> \<A\>"') do (
	if "%%d"=="A" (
		if not defined _d set _d=_&echo,    local-zone: "!_dn!" static	#!_c!
		if not defined %%e set %%e=_&echo,	local-data: "!_dn! %%b %%c %%d %%e"
	) else set _c=!_c! %%e&if not defined _dn set _dn=%%a
)
goto :eof

