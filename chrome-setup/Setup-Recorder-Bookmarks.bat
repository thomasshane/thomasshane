@echo off
REM Recorder Bookmarks - Chrome Setup

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Setup-Recorder-Bookmarks.ps1"

if not exist "%PS_SCRIPT%" (
    echo ERROR: Could not find Setup-Recorder-Bookmarks.ps1
    echo Please ensure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

echo.
pause
