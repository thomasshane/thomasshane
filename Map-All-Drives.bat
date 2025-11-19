@echo off
REM Network Drive Mapper with Clean Labels
REM Double-click this file to map all drives (J, W, X, O) with clean labels

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Map-All-Drives.ps1"

if not exist "%PS_SCRIPT%" (
    echo ERROR: Could not find Map-All-Drives.ps1
    echo Please ensure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

echo.
pause
