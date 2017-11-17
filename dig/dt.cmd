@echo off&cd /d "%~dp0"&SETLOCAL&set "_fdp=%~dp0"
rem 输入IP时：测试此IP是否支持TCP及非标准端口的DNS查询；输入域名时：使用TCP+UDP多端口来查询，以此判断该域名是否被污染
rem 在cmd命令行下使用，暂不支持命令行参数
rem 测试域名 t.cn	g.cn（无污染）zh.wikipedia.org googlevideo.com www.google.com www.google.com.hk www.tumblr.com 有污染

set _dqn=g.cn
set _dip=208.67.222.222
set _port=53,443,5353
set _to=2
set _rt=0

set "_fl=for /f "eol=;tokens=*delims=" %%a in ('dig"

:bg
set /p _inp="Please input IP address or Domain name: "
if "%_inp%"=="cc" (cls&goto :bg) else if "%_inp%"=="q" ENDLOCAL&goto :eof

call :_fle&rem	echo,_isf==%_isf%
if defined _isf (if "%_isf%"=="0" (set _ip=%_inp%&set _qn=%_dqn%) else set _qn=%_inp%&set _ip=%_dip%) else goto :bg
set "_fr=@%_ip% -p%%p +noall +answer +time^=%_to% +retry^=%_rt% %_qn%') do echo,%%a&&if not defined _ut set _ut=1"

call :_dd UDP
call :_dd TCP

echo,&goto :bg


rem 依端口顺序轮流查询TCP和UDP
for %%p in (%_port%) do (
	tcping -n 3 -i .3 -w .5 -g 2 -c -s %_ip% %%p>nul&&%_fl% +vc %_fr%
	if defined _ut echo,	--- TCP-%%p OK ---&ping -n 1 127.1>nul&set _ut=
	%_fl% %_fr%
	if defined _ut echo,	--- UDP:%%p OK ---&ping -n 1 127.1>nul&set _ut=
)
echo,&goto :bg

rem dig +noall +answer +time=2 +retry=1 tumblr.com +stats

208.67.220.220
208.67.222.222
202.141.162.123
202.141.178.13
202.38.93.153
8.8.8.8
8.8.4.4
119.29.29.29
202.96.128.166
202.96.134.133
202.96.128.86


:_dd
    for %%p in (%_port%) do (
	if "%1"=="TCP" (tcping -n 3 -i .3 -w .5 -g 2 -c -s %_ip% %%p>nul&&%_fl% +vc %_fr%) else %_fl% %_fr%
	if defined _ut echo,	--- %1:%%p OK ---&ping -n 1 127.1>nul&set _ut=
    )
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