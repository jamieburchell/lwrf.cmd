@echo off
setlocal EnableDelayedExpansion EnableExtensions

:: /////////////////////////////////////////////////
:: DO NOT EDIT ABOVE THIS POINT                   //
:: /////////////////////////////////////////////////

:: -- Network configuration ------------------------
set wifi_link_ip=192.168.1.7
set wifi_link_port=9760
set source_port=9761
:: -------------------------------------------------

:: -- Room configuration ---------------------------
:: Add as many rooms as necessary (max 8)
:: E.g:
:: R1=spare bedroom
:: R2=living-room
:: R3=office
set R1=bedroom1
set R2=landing
set R3=bathroom
set R4=bedroom2
set R5=sitting-room
set R6=lounge
set R7=office
set R8=kitchen
:: -------------------------------------------------

:: -- Room/Device configuration --------------------
:: Add as many devices as necessary (max 8 per room)
:: E.g:
:: R1D1=lights
:: R1D2=plug socket
:: R2D1=tv
set R1D1=lights
set R2D1=lights
set R3D1=lights
set R4D1=lights
set R4D2=lamp
set R5D1=lights
set R5D6=wall-lights
set R6D1=lights
set R6D2=stair-lights
set R6D3=tv
set R6D4=tv-spare
set R6D5=lamp
set R6D6=lan
set R7D1=lights
set R7D2=speakers
set R7D3=computers
set R8D1=side-lights
set R8D2=main-lights
:: -------------------------------------------------

:: -- Room/Mood configuration ----------------------
:: Add as many moods as necessary (max 3 per room)
:: E.g:
:: R1M1=relax
:: R1M2=movie
set R6M1=relax

:: /////////////////////////////////////////////////
:: DO NOT EDIT BELOW THIS POINT                   //
:: /////////////////////////////////////////////////

set room=
set device=
set mood=
set function=
set display=
set rx_timeout=0.2
set lf=^


ncat --version > NUL 2>&1
if errorlevel 1 echo ncat not found 1>&2 && exit /b 1

if "%~1"=="seq" (

	set rx_timeout=0.4

	if "%~2"=="" goto usage

	if "%~2"=="--cancel-all" (
		set function=FcP"*"
		set display=cancel all^|sequences
	) else (
		set function=FqP"%~2"
		set display=start sequence^|%~2
	)

) else (

	for /l %%r in (1,1,8) do (
		if "!R%%r!"=="%~1" (
			set room=R%%r
			if "%~2"=="mood" (
				for /l %%m in (1,1,3) do if "!R%%rM%%m!"=="%~3" set mood=%%m
				if "!mood!"=="" goto usage
			) else if not "%~2"=="off" (
				for /l %%d in (1,1,6) do if "!R%%rD%%d!"=="%~2" set device=D%%d
				if "!device!"=="" goto usage
			)
		)
	)

	if "!room!"=="" goto usage

	set display=%~1^|%~2 %~3

	if "%~2"=="off" (
		set function=Fa
		set display=%~1^|%~2
	) else if "%~2"=="mood" (
		set function=FmP!mood!
	) else if "%~3"=="on" (
		set function=F1
	) else if "%~3"=="off" (
		set function=F0
	) else if "%~3"=="lock" (
		set function=Fl
	) else if "%~3"=="unlock" (
		set function=Fu
	) else if "%~3"=="dim" (
		set dimlevel=%~4
		if !dimlevel! lss 1 goto usage
		if !dimlevel! gtr 100 goto usage
		set /a dimlevel=!dimlevel!*31/100+1
		set function=FdP!dimlevel!
		set display=!display! %~4%%
	) else (
		goto usage
	)
)

set tx_id=%random:~0,3%
set p_tx_id=00%tx_id%
set p_tx_id=%p_tx_id:~-3%
set msg="%p_tx_id%,^!!room!!device!!function!|!display!|"
set rx_reply=0
set exec=^<nul set /p =!msg!^|ncat -u -n -i %rx_timeout% -p %source_port% %wifi_link_ip% %wifi_link_port% 2^>NUL

for /f "tokens=*" %%a in ('!exec!') do (
	set rx_reply=1
	if not "%%a"=="%tx_id%,OK" echo %%a 1>&2 && exit /b 1
)

if !rx_reply! equ 0 echo No reply from WifiLink 1>&2 && exit /b 1

goto end

:usage
set usage=LightwaveRF Windows Command Line Control v4.1 by Jamie Burchell!lf!^

Usage:!lf!^
lwrf room-name device-name on^|off^|lock^|unlock^|dim 1-100!lf!^
lwrf room-name off!lf!^
lwrf room-name mood mood-name!lf!^
lwrf seq sequence-name!lf!^
lwrf seq --cancel-all!lf!^

Examples:!lf!^
lwrf lounge lights dim 50!lf!^
lwrf lounge mood relax!lf!^
lwrf "sitting room" "wall lights" on!lf!^
lwrf seq "my sequence"!lf!^

Requirements:!lf!^
1 The ncat utility to send the messages. Download the Windows binary from!lf!^
  http://nmap.org/ncat and put it in the Windows PATH (e.g. system32 folder)!lf!^
2 You must edit the configuration parameters at the top of this script!lf!^
3 Allow ports %wifi_link_port% outbound (UDP) and %source_port% inbound (UDP) on this device!lf!^
4 This device must be registered with your WifiLink.!lf!^
  The WifiLink will prompt for registration when the first command is sent.

echo !usage! 1>&2
exit /b 1

:end
