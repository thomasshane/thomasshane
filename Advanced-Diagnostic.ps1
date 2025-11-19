<#
.SYNOPSIS
    Advanced diagnostic to identify why labels aren't working.

.DESCRIPTION
    Checks for Group Policy settings, Windows version, and other factors
    that might prevent custom drive labels from working.
#>

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Advanced Drive Label Diagnostic" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check Windows version
Write-Host "SYSTEM INFORMATION:" -ForegroundColor Yellow
Write-Host ""
$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Host "  Windows Version: $($osInfo.Caption)" -ForegroundColor Gray
Write-Host "  Build: $($osInfo.BuildNumber)" -ForegroundColor Gray
Write-Host "  Architecture: $($osInfo.OSArchitecture)" -ForegroundColor Gray
Write-Host ""

# Check if Group Policy might be blocking registry changes
Write-Host "GROUP POLICY CHECK:" -ForegroundColor Yellow
Write-Host ""

$gpResult = gpresult /R 2>&1 | Select-String -Pattern "Domain"
if ($gpResult) {
    Write-Host "  Domain joined: YES" -ForegroundColor Yellow
    Write-Host "  Note: Group Policy might override drive label settings" -ForegroundColor Yellow
} else {
    Write-Host "  Domain joined: NO" -ForegroundColor Green
}
Write-Host ""

# Check current user permissions
Write-Host "USER PERMISSIONS:" -ForegroundColor Yellow
Write-Host ""
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = ([Security.Principal.WindowsPrincipal]$currentUser).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "  Running as Administrator: YES" -ForegroundColor Green
} else {
    Write-Host "  Running as Administrator: NO" -ForegroundColor Yellow
}
Write-Host ""

# Check registry permissions for DriveIcons key
Write-Host "REGISTRY ACCESS CHECK:" -ForegroundColor Yellow
Write-Host ""

$testDrive = "J"
$baseKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons"

try {
    if (-not (Test-Path $baseKey)) {
        New-Item -Path $baseKey -Force -ErrorAction Stop | Out-Null
        Write-Host "  Created base DriveIcons key: SUCCESS" -ForegroundColor Green
        Remove-Item -Path $baseKey -Force
    } else {
        Write-Host "  Base DriveIcons key exists: YES" -ForegroundColor Green
    }

    # Test write permissions
    $testPath = "$baseKey\$testDrive"
    New-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -Path $testPath -Name "DefaultLabel" -Value "Test" -PropertyType String -Force -ErrorAction Stop | Out-Null
    $readBack = Get-ItemProperty -Path $testPath -Name "DefaultLabel" -ErrorAction Stop

    if ($readBack.DefaultLabel -eq "Test") {
        Write-Host "  Write/Read test: SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "  Write/Read test: FAILED (value mismatch)" -ForegroundColor Red
    }

    Remove-Item -Path $testPath -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Host "  Registry access: FAILED" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Check existing network drives and their registry status
Write-Host "CURRENT DRIVE STATUS:" -ForegroundColor Yellow
Write-Host ""

$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -like "\\*" }

if ($drives.Count -eq 0) {
    Write-Host "  No network drives currently mapped" -ForegroundColor Gray
} else {
    foreach ($drive in $drives) {
        $driveLetter = $drive.Name
        Write-Host "  Drive $driveLetter`: $($drive.DisplayRoot)" -ForegroundColor Cyan

        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetter"

        if (Test-Path $regPath) {
            $label = Get-ItemProperty -Path $regPath -Name "DefaultLabel" -ErrorAction SilentlyContinue
            if ($label) {
                Write-Host "    Registry label: '$($label.DefaultLabel)'" -ForegroundColor Green
            } else {
                Write-Host "    Registry label: NOT SET" -ForegroundColor Yellow
            }
        } else {
            Write-Host "    Registry key: DOES NOT EXIST" -ForegroundColor Red
        }
        Write-Host ""
    }
}

# Check for cached MountPoints that might interfere
Write-Host "MOUNTPOINTS CHECK:" -ForegroundColor Yellow
Write-Host ""

$mountPointsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
if (Test-Path $mountPointsPath) {
    $mountPoints = Get-ChildItem -Path $mountPointsPath -ErrorAction SilentlyContinue
    if ($mountPoints) {
        Write-Host "  Found $($mountPoints.Count) cached mount points" -ForegroundColor Yellow
        Write-Host "  These might interfere with custom labels" -ForegroundColor Yellow
    } else {
        Write-Host "  No cached mount points found" -ForegroundColor Green
    }
} else {
    Write-Host "  MountPoints2 key does not exist" -ForegroundColor Green
}
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Diagnostic Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "RECOMMENDATIONS:" -ForegroundColor Yellow
Write-Host ""

if ($gpResult) {
    Write-Host "  - Check with IT if Group Policy is preventing label changes" -ForegroundColor Gray
}

if (-not $isAdmin) {
    Write-Host "  - Try running as Administrator" -ForegroundColor Gray
}

Write-Host "  - Compare this output between working and non-working computers" -ForegroundColor Gray
