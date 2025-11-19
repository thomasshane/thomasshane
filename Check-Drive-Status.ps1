<#
.SYNOPSIS
    Diagnostic script to check drive mapping and label status.

.DESCRIPTION
    Shows current drive mappings and registry label settings.
#>

$drivesToCheck = @("J", "W", "X", "O")

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Drive Status Diagnostic" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check current network drive mappings
Write-Host "CURRENT NETWORK DRIVE MAPPINGS:" -ForegroundColor Yellow
Write-Host ""
net use | Select-String -Pattern ":" | ForEach-Object { Write-Host "  $_" }
Write-Host ""

# Check registry labels for each drive
Write-Host "REGISTRY LABEL STATUS:" -ForegroundColor Yellow
Write-Host ""

foreach ($driveLetter in $drivesToCheck) {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetter"

    Write-Host "Drive $driveLetter`:" -ForegroundColor Cyan

    if (Test-Path $regPath) {
        Write-Host "  Registry key exists: YES" -ForegroundColor Green
        $label = Get-ItemProperty -Path $regPath -Name "DefaultLabel" -ErrorAction SilentlyContinue

        if ($label) {
            Write-Host "  Label value: '$($label.DefaultLabel)'" -ForegroundColor Green
        } else {
            Write-Host "  Label value: NOT SET" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  Registry key exists: NO" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Diagnostic complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
