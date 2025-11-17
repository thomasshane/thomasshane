@echo off
REM O Drive Mapping Launcher
REM Double-click this file to map O Drive

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Map-ODrive.ps1"

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo ERROR: Could not find Map-ODrive.ps1
    echo Please ensure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

REM Run the PowerShell script with Windows PowerShell (built into Windows)
REM -ExecutionPolicy Bypass allows the script to run without changing system settings
REM -NoProfile speeds up execution by not loading user profile
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

echo.
pause
