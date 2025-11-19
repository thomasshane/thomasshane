@echo off
REM Super Aggressive Cleanup Launcher

echo ============================================
echo SUPER AGGRESSIVE CLEANUP
echo ============================================
echo.
echo This will:
echo - Disconnect all drives
echo - Clear all cached drive information
echo - Clear icon cache
echo - Restart Windows Explorer
echo - Remap drives with clean labels
echo.
echo Press Ctrl+C to cancel, or
pause

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Super-Aggressive-Cleanup.ps1"

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo ERROR: Could not find Super-Aggressive-Cleanup.ps1
    echo Please ensure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

echo.
pause
