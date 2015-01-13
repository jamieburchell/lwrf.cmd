@echo off
setlocal EnableDelayedExpansion EnableExtensions

:: /////////////////////////////////////////////////
:: DO NOT EDIT ABOVE THIS POINT                   //
:: /////////////////////////////////////////////////

:: -- Basic configuration --------------------------
set wifi_link_ip=192.168.1.7
set wifi_link_port=9760
set source_port=9761
set debug=0
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
:: see below for TRVs
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
:: -------------------------------------------------

:: -- TRV configuration ----------------------------
:: Add as many TRVs as necessary (max 8)
:: E.g:
:: TRV1=lounge
:: TRV2=hall
set TRV1=lounge
:: -------------------------------------------------

:: /////////////////////////////////////////////////
:: DO NOT EDIT BELOW THIS POINT                   //
:: /////////////////////////////////////////////////

set room=
set device=
set mood=
set function=
set display=
set rx_timeout=0.5
set lf=^


ncat --version > NUL 2>&1
if errorlevel 1 echo ncat not found 1>&2 && goto err

set display=%~1^|%~2 %~3

if "%~1"=="register" (
  set function=F*p
  set display=register
  echo Accept pairing request at WifiLink unit
  goto send
)

if "%~1"=="seq" (
  if "%~2"=="" goto usage
  if "%~2"=="--cancel-all" (
    set function=FcP"*"
    set display=cancel all^|sequences
  ) else (
    set function=FqP"%~2"
    set display=start sequence^|%~2
  )
  goto send
)

if "%~1"=="trv" (

  for /l %%r in (1,1,8) do (
    if "!TRV%%r!"=="%~2" (

      set room=%%r

      if "%~3"=="register" (
        set function=F*L
        goto send
      )

      set device=Dh

      if "%~3"=="off" (
        set function=F*tP50.0
        goto send
      )

      if "%~3"=="on" (
        set function=F*tP60.0
        goto send
      )

      if "%~3"=="temp" (
        set temp=%~4
        if !temp! lss 1 goto usage
        if !temp! gtr 40 goto usage
        set function=F*tP!temp!.0
        set display=!display! %~4%
        goto send
      )

      if "%~3"=="pos" (
        set pos=%~4
        if !pos! lss 0 goto usage
        if !pos! gtr 5 goto usage
        set /a pos=!pos!+50+!pos!*2-!pos!
        set function=F*tP!pos!.0
        set display=!display! %~4%
        goto send
      )

      goto usage
    )
  )

  goto usage
)

for /l %%r in (1,1,8) do (
  if "!R%%r!"=="%~1" (

    set room=R%%r

    if "%~2"=="mood" (
      for /l %%m in (1,1,3) do if "!R%%rM%%m!"=="%~3" set mood=%%m
      if "!mood!"=="" goto usage
      set function=FmP!mood!
      goto send
    )

    if "%~2"=="off" (
      set function=Fa
      set display=%~1^|%~2
      goto send
    )

    for /l %%d in (1,1,6) do if "!R%%rD%%d!"=="%~2" set device=D%%d
    if "!device!"=="" goto usage

    if "%~3"=="on" (
      set function=F1
      goto send
    )

    if "%~3"=="off" (
      set function=F0
      goto send
    )

    if "%~3"=="lock" (
      set function=Fl
      goto send
    )

    if "%~3"=="unlock" (
      set function=Fu
      goto send
    )

    if "%~3"=="dim" (
      set dimlevel=%~4
      if !dimlevel! lss 1 goto usage
      if !dimlevel! gtr 100 goto usage
      set /a dimlevel=!dimlevel!*31/100+1
      set function=FdP!dimlevel!
      set display=!display! %~4%%
      goto send
    )
  )
)

goto usage

:send
set tx_id=%random:~0,3%
set tx_id=00%tx_id%
set tx_id=%tx_id:~-3%
set tx_msg="%tx_id%,^!!room!!device!!function!|!display!|"
set rx_msg=
set exec=^<nul set /p =!tx_msg!^|ncat -u -n -i %rx_timeout% -p %source_port% %wifi_link_ip% %wifi_link_port% 2^>NUL

if %debug% equ 1 echo !tx_msg!

for /f "tokens=*" %%a in ('!exec!') do (
  if %debug% equ 1 echo "%%a"
  if "%%a"=="%tx_id%,OK" goto end
  set rx_msg=!rx_msg!"%%a"
)

if "!rx_msg!"=="" (
  echo No confirmation received from WifiLink 1>&2
)

goto err

:usage
set usage=LightwaveRF Windows Command Line Control v6 by Jamie Burchell!lf!^

Usage:!lf!^
lwrf register!lf!^
lwrf room-name device-name on^|off^|lock^|unlock^|dim 1-100!lf!^
lwrf room-name off!lf!^
lwrf room-name mood mood-name!lf!^
lwrf trv trv-name register^|on^|off^|temp 0-40^|pos 0-5!lf!^
lwrf seq sequence-name!lf!^
lwrf seq --cancel-all!lf!^

Examples:!lf!^
lwrf lounge lights dim 50!lf!^
lwrf lounge mood relax!lf!^
lwrf "sitting room" "wall lights" on!lf!^
lwrf seq "my sequence"!lf!^
lwrf trv lounge temp 22!lf!^

Requirements:!lf!^
1 The ncat utility to send the messages. Download the Windows binary from!lf!^
  http://nmap.org/ncat and put it in the Windows PATH (e.g. system32 folder)!lf!^
2 You must edit the configuration parameters at the top of this script!lf!^
3 Allow ports %wifi_link_port% outbound (UDP) and %source_port% inbound (UDP) on this device!lf!^
4 The MAC address of this device must be registered with your WifiLink.!lf!^
  Enter: lwrf register and select "Yes" at the WifiLink unit

echo !usage! 1>&2

:err
exit /b 1

:end
