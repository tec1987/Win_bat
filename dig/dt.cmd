@echo off&cd /d "%~dp0"&SETLOCAL&set "_fn=%~nx0"
rem ����IPʱ�����Դ�IP�Ƿ�֧��TCP���Ǳ�׼�˿ڵ�DNS��ѯ����������ʱ��ʹ��TCP+UDP��˿�����ѯ���Դ��жϸ������Ƿ���Ⱦ
rem ��cmd��������ʹ�ã��ݲ�֧�������в���
rem �������� t.cn	g.cn������Ⱦ��zh.wikipedia.org googlevideo.com www.google.com www.google.com.hk www.tumblr.com ����Ⱦ

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


rem ���˿�˳��������ѯTCP��UDP
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


:_fle	rem ����������Ч����֤���ж��Ƿ�ΪIP��������ΪIPʱ _isf=0��Ϊ����ʱ _isf=1�����򲻶��� _isf
    set _isf=&SETLOCAL ENABLEDELAYEDEXPANSION&rem echo ���룺!_inp! �Ƚ�_isf��գ�����ʹ���ϴε�_isf��Ҳ������ѭ���д���
    if defined _inp (rem �ж��Ƿ��������Լ���Ч�ַ�
	set "_in1=!_inp:"=#!"
	set "_in2=!_inp:"=@!"
	if "!_in1!" neq "!_in2!" ENDLOCAL&goto :eof	rem !_inp!�������ţ����ܼ����ж�
	for /f "tokens=*delims=0123456789.abcdefghijklmnopqrstuvwxyz-ABCDEFGHIJKLMNOPQRSTUVWXYZ eol=" %%a in ("!_inp!")do if "%%a" neq "" ENDLOCAL&goto :eof
	set _in1=!_inp:..=!
	if "!_in1!" neq "!_inp!" ENDLOCAL&goto :eof	rem �ж�����������
	set _b=!_inp:~0,1!&set _e=!_inp:~-1!
	if "!_b!"=="." ENDLOCAL&goto :eof	rem ���ж����㡣����
rem	if "!_e!"=="." set _psf=1&rem echo β�ж����㡣�����ݲ���������������
	set _in2=!_inp:.=;!
	if "!_in2!"=="!_inp!" ENDLOCAL&goto :eof	rem ��������㡣����

	set/a _ii=_it=0
	for %%c in (!_in2!) do (
	    set/a _ii+=1&set _!_ii!=%%c
	    if %%c leq 255 if %%c geq 0 set/a _it+=1
	    call set _bb=%%_!_ii!:~0,1%%&call set _ee=%%_!_ii!:~-1%%
	    if !_bb!==- ENDLOCAL&goto :eof	rem �ж���ĺ���-��
	    if !_ee!==- ENDLOCAL&goto :eof	rem �ж���ĺ���-��
	)
	for /f "tokens=*delims=0123456789. eol=" %%a in ("!_inp!") do if "%%a"=="" (if !_e! neq . if !_it! equ 4 if !_ii! equ 4 set _isf=0) else (
	rem echo ����IP���ж��Ƿ�Ϊ����
	    for %%c in (!_ii!) do set _tld=!_%%c!
	    for /f "tokens=*delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" %%a in ("!_tld!") do if "%%a"=="" set _isf=1&rem echo ��׺����ĸ��������Ϊ��������
	    rem IANA TLD�б�https://data.iana.org/TLD/tlds-alpha-by-domain.txt
	    rem for /f "delims=:" %%n in ('findstr /binc:"# https://data.iana.org/" %_fn%') do set _skp=%%n&&echo,"_skp==!_skp!"
	    rem for /f "eol=# skip=95" %%x in (%_fn%) do echo,%%x&if "!_tld!"=="%%x" echo,OK	_tld=!_tld!
	)
	if defined _isf (for %%a in (!_isf!) do ENDLOCAL&set _isf=%%a)&goto :eof	rem ����Ч��IP������
    )
ENDLOCAL&goto :eof

# https://data.iana.org/TLD/tlds-alpha-by-domain.txt
# Version 2017111900, Last Updated Sun Nov 19 07:07:01 2017 UTC
AAA
AARP
ABARTH
ABB
ABBOTT
ABBVIE
ABC
ABLE
ABOGADO
ABUDHABI
AC
ACADEMY
ACCENTURE
ACCOUNTANT
ACCOUNTANTS
ACO
ACTIVE
ACTOR
AD
ADAC
ADS
ADULT
AE
AEG
AERO
AETNA
AF
AFAMILYCOMPANY
AFL
AFRICA
......