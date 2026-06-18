@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title BitLocker Status Monitor
cls


:: Config
set "REFRESH_RATE=3"

set "filled=█"
set "empty=░"

for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"

:loop

set "screen_buffer="
set /a "total_pct=0"
set /a "volume_count=0"
set "avg_display=0"


set /a idx=0
for /f "tokens=*" %%a in ('manage-bde -status') do (
    for /f "delims=" %%b in ("%%a") do (
        set /a idx+=1
        set "bde_line[!idx!]=%%b"
    )
)
set "max_lines=!idx!"


for /l %%k in (1,1,!max_lines!) do (
    set "line=!bde_line[%%k]!"
    echo !line! | findstr /C:"Percentage Encrypted:" >nul
    if !errorlevel! equ 0 (
        for /f "tokens=3 delims=:%% " %%p in ("!line!") do set "pct_raw=%%p"
        for /f "delims=." %%i in ("!pct_raw!") do set "pct_int=%%i"
        if "!pct_int!"=="" set "pct_int=0"
        
        set /a "total_pct+=!pct_int!"
        set /a "volume_count+=1"
    )
)
if !volume_count! gtr 0 (
    set /a "avg_pct=!total_pct! / !volume_count!"
    set "avg_display=!avg_pct!"
)


(
    echo ┌──────────────────────────────────────────────────────────────────┐
    echo │                    BITLOCKER STATUS MONITOR                      │
    echo │    Time: %time:~0,8%       │       Global Encryption Avg: !avg_display!%%      │
    echo └──────────────────────────────────────────────────────────────────┘
    echo.
) > "%temp%\bl_frame.txt"

for /l %%k in (1,1,!max_lines!) do (
    set "line=!bde_line[%%k]!"

    echo !line! | findstr /C:"Size:" >nul
    if !errorlevel! equ 0 (
        for /f "tokens=2,3 delims=: " %%g in ("!line!") do (
            set "size_raw=%%g"
            set "size_unit=%%h"
        )
    )

    echo !line! | findstr /C:"Volume " >nul
    if !errorlevel! equ 0 echo  ► !line! >> "%temp%\bl_frame.txt"
    
    echo !line! | findstr /C:"Conversion Status:" >nul
    if !errorlevel! equ 0 echo      !line! >> "%temp%\bl_frame.txt"
    
    echo !line! | findstr /C:"Percentage Encrypted:" >nul
    if !errorlevel! equ 0 (
        echo      !line! >> "%temp%\bl_frame.txt"
        
        for /f "tokens=3 delims=:%% " %%p in ("!line!") do set "pct_raw=%%p"
        for /f "delims=." %%i in ("!pct_raw!") do set "pct_int=%%i"
        if "!pct_int!"=="" set "pct_int=0"
        
        set "size_whole=!size_raw!"
        set "size_dec=0"
        if not "!size_raw!"=="!size_raw:.=!" (
            for /f "tokens=1,2 delims=." %%x in ("!size_raw!") do (
                set "size_whole=%%x"
                set "size_dec=%%y"
            )
        )
        if "!size_dec:~0,1!"=="0" set "size_dec=!size_dec:~1!"
        if "!size_dec!"=="" set "size_dec=0"
        
        if /i "!size_unit!"=="GB" (
            set /a "total_mb=(!size_whole! * 1024) + ((!size_dec! * 1024) / 100)"
        ) else (
            set /a "total_mb=!size_whole!"
        )
        set /a "encrypted_mb=(!total_mb! * !pct_int!) / 100"
        
        set /a "blocks=!pct_int! / 5"
        set /a "spaces=20 - !blocks!"
        if !blocks! gtr 20 set "blocks=20"
        if !spaces! lss 0  set "spaces=0"
        
        set "bar="
        for /l %%x in (1,1,!blocks!) do set "bar=!bar!!filled!"
        for /l %%x in (1,1,!spaces!) do set "bar=!bar!!empty!"
        
        echo      Progress: [!bar!] >> "%temp%\bl_frame.txt"
        echo      Size Encrypted: !encrypted_mb! MB / !total_mb! MB >> "%temp%\bl_frame.txt"
        echo. >> "%temp%\bl_frame.txt"
    )
)

(
    echo ────────────────────────────────────────────────────────────────────
    echo  [Ctrl+C] to Exit  │
) >> "%temp%\bl_frame.txt"

cls
type "%temp%\bl_frame.txt"

timeout /t %REFRESH_RATE% > nul
goto loop
