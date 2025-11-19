@echo off
REM Chrome Bookmarks and Startup Setup

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Setup-Chrome.ps1"

if not exist "%PS_SCRIPT%" (
    echo ERROR: Could not find Setup-Chrome.ps1
    echo Please ensure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

echo.
pause
