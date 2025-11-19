@echo off
REM MountPoints2 Label Setter - THE CORRECT METHOD

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Set-MountPoints2-Labels.ps1"

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo ERROR: Could not find Set-MountPoints2-Labels.ps1
    echo Please ensure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

echo.
pause
