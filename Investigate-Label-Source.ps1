<#
.SYNOPSIS
    Investigates HOW the working computer is getting clean labels without registry keys.

.DESCRIPTION
    Checks all possible sources where Windows might be pulling the drive label from.
#>

$drivesToCheck = @("J", "W", "X", "O")

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Label Source Investigation" -ForegroundColor Cyan
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
        Write-Host "  Drive not mapped" -ForegroundColor Gray
        Write-Host ""
        continue
    }

    Write-Host "  Mapped to: $($driveInfo.DisplayRoot)" -ForegroundColor Gray
    Write-Host ""

    # Method 1: Check DriveIcons registry
    Write-Host "  [Registry] DriveIcons\$driveLetter\DefaultLabel:" -ForegroundColor Yellow
    $regPath1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetter"
    if (Test-Path $regPath1) {
        $label = Get-ItemProperty -Path $regPath1 -Name "DefaultLabel" -ErrorAction SilentlyContinue
        if ($label) {
            Write-Host "    EXISTS: '$($label.DefaultLabel)'" -ForegroundColor Green
        } else {
            Write-Host "    Key exists but DefaultLabel not set" -ForegroundColor Yellow
        }
    } else {
        Write-Host "    DOES NOT EXIST" -ForegroundColor Red
    }

    # Method 2: Check MountPoints2
    Write-Host "  [Registry] MountPoints2 cache:" -ForegroundColor Yellow
    $mountPointsBase = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
    if (Test-Path $mountPointsBase) {
        $uncPath = $driveInfo.DisplayRoot
        $mountPointKey = $uncPath -replace '\\', '#'
        $mountPointPath = "$mountPointsBase\$mountPointKey"

        if (Test-Path $mountPointPath) {
            Write-Host "    Cache entry exists for this path" -ForegroundColor Green
            $mpLabel = Get-ItemProperty -Path $mountPointPath -Name "_LabelFromReg" -ErrorAction SilentlyContinue
            if ($mpLabel) {
                Write-Host "    _LabelFromReg: '$($mpLabel._LabelFromReg)'" -ForegroundColor Green
            }
            $mpLabel2 = Get-ItemProperty -Path $mountPointPath -Name "_LabelFromDesktopINI" -ErrorAction SilentlyContinue
            if ($mpLabel2) {
                Write-Host "    _LabelFromDesktopINI: '$($mpLabel2._LabelFromDesktopINI)'" -ForegroundColor Green
            }
        } else {
            Write-Host "    No cache entry for this specific path" -ForegroundColor Gray
        }
    }

    # Method 3: Check for desktop.ini in the network path
    Write-Host "  [Network] desktop.ini file:" -ForegroundColor Yellow
    try {
        $desktopIni = Join-Path $driveInfo.Root "desktop.ini"
        if (Test-Path $desktopIni) {
            Write-Host "    EXISTS in root of mapped drive" -ForegroundColor Green
            $iniContent = Get-Content $desktopIni -Raw -ErrorAction SilentlyContinue
            if ($iniContent -match 'LocalizedResourceName=(.+)') {
                Write-Host "    Label in desktop.ini: '$($matches[1])'" -ForegroundColor Green
            }
        } else {
            Write-Host "    No desktop.ini in drive root" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "    Could not check for desktop.ini: $_" -ForegroundColor Yellow
    }

    # Method 4: What does Windows Shell API report?
    Write-Host "  [Shell API] What Windows displays:" -ForegroundColor Yellow
    try {
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.NameSpace("$driveLetter`:")
        if ($folder) {
            $displayName = $folder.Title
            Write-Host "    Shell reports: '$displayName'" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "    Could not query Shell API: $_" -ForegroundColor Yellow
    }

    # Method 5: Get volume label
    Write-Host "  [Volume] Volume label (if any):" -ForegroundColor Yellow
    try {
        $volume = Get-Volume -DriveLetter $driveLetter -ErrorAction SilentlyContinue
        if ($volume -and $volume.FileSystemLabel) {
            Write-Host "    Volume label: '$($volume.FileSystemLabel)'" -ForegroundColor Green
        } else {
            Write-Host "    No volume label set" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "    Could not get volume info: $_" -ForegroundColor Yellow
    }

    # Method 6: Check net use output
    Write-Host "  [Net Use] How 'net use' sees it:" -ForegroundColor Yellow
    $netUseOutput = net use | Select-String "$driveLetter`:"
    if ($netUseOutput) {
        Write-Host "    $netUseOutput" -ForegroundColor Gray
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Investigation Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Run this on the WORKING computer" -ForegroundColor Gray
Write-Host "2. Run this on the NON-WORKING computer" -ForegroundColor Gray
Write-Host "3. Compare the outputs to see where the label is coming from" -ForegroundColor Gray
