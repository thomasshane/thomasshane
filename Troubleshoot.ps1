<#
.SYNOPSIS
    Diagnostic tool to troubleshoot drive label issues.

.DESCRIPTION
    Shows where Windows is pulling drive labels from and helps identify issues.
#>

$drivesToCheck = @("J", "W", "X", "O")

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Drive Label Troubleshooter" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Host "Windows Build: $($osInfo.BuildNumber)" -ForegroundColor Gray
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = ([Security.Principal.WindowsPrincipal]$currentUser).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "Running as Admin: $isAdmin" -ForegroundColor Gray
Write-Host ""

foreach ($driveLetter in $drivesToCheck) {
    Write-Host "=== Drive $driveLetter`: ===" -ForegroundColor Cyan

    # Check if drive is mapped
    $driveInfo = Get-PSDrive -Name $driveLetter -PSProvider FileSystem -ErrorAction SilentlyContinue

    if (-not $driveInfo) {
        Write-Host "  NOT MAPPED" -ForegroundColor Red
        Write-Host ""
        continue
    }

    Write-Host "  Mapped to: $($driveInfo.DisplayRoot)" -ForegroundColor Green
    Write-Host ""

    # Check MountPoints2 (the correct location for Windows 11)
    Write-Host "  MountPoints2 Registry (_LabelFromReg):" -ForegroundColor Yellow
    $mountPointsBase = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
    $uncPath = $driveInfo.DisplayRoot
    $encodedPath = $uncPath -replace '\\', '#'
    $mountPointPath = "$mountPointsBase\$encodedPath"

    if (Test-Path $mountPointPath) {
        $labelFromReg = Get-ItemProperty -Path $mountPointPath -Name "_LabelFromReg" -ErrorAction SilentlyContinue
        if ($labelFromReg) {
            Write-Host "    EXISTS: '$($labelFromReg._LabelFromReg)'" -ForegroundColor Green
        } else {
            Write-Host "    MISSING - This is the problem!" -ForegroundColor Red
            Write-Host "    Run Map-All-Drives.bat to fix this" -ForegroundColor Yellow
        }

        # Check for conflicting desktop.ini label
        $desktopIniLabel = Get-ItemProperty -Path $mountPointPath -Name "_LabelFromDesktopINI" -ErrorAction SilentlyContinue
        if ($desktopIniLabel -and $desktopIniLabel._LabelFromDesktopINI) {
            Write-Host "    WARNING: _LabelFromDesktopINI exists and may override" -ForegroundColor Yellow
        }
    } else {
        Write-Host "    REGISTRY KEY MISSING - This is the problem!" -ForegroundColor Red
        Write-Host "    Run Map-All-Drives.bat to fix this" -ForegroundColor Yellow
    }

    # Show what Windows Explorer displays
    Write-Host "  What File Explorer shows:" -ForegroundColor Yellow
    try {
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.NameSpace("$driveLetter`:")
        if ($folder) {
            Write-Host "    '$($folder.Title)'" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "    Could not query" -ForegroundColor Gray
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Troubleshooting Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Yellow
Write-Host "  If any drives are missing _LabelFromReg, run Map-All-Drives.bat" -ForegroundColor Gray
