@echo off
REM Drive Label Troubleshooter

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Troubleshoot.ps1"

if not exist "%PS_SCRIPT%" (
    echo ERROR: Could not find Troubleshoot.ps1
    echo Please ensure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

echo.
pause
