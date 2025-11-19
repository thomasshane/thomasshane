@echo off
REM Full Cleanup and Remap Launcher
REM This will completely remove and remap all drives with clean labels

echo ============================================
echo WARNING: This will disconnect all drives
echo and remap them with clean labels
echo ============================================
echo.
echo Press Ctrl+C to cancel, or
pause

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Full-Cleanup-And-Remap.ps1"

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo ERROR: Could not find Full-Cleanup-And-Remap.ps1
    echo Please ensure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

echo.
pause
