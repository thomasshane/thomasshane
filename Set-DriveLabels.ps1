<#
.SYNOPSIS
    Sets custom labels for already-mapped network drives.

.DESCRIPTION
    If you already have drives mapped and just want to set the clean labels,
    run this script. This only sets the registry labels without remapping.
#>

# Define the drive labels (must match your mapped drives)
$driveLabels = @{
    "J" = "Court Doc External"
    "W" = "Circuit"
    "X" = "Div1"
    "O" = "Recorder Main"
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Set Drive Labels Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

foreach ($driveLetter in $driveLabels.Keys) {
    $label = $driveLabels[$driveLetter]

    Write-Host "Setting label for $driveLetter`: drive to '$label'..." -ForegroundColor Yellow

    try {
        # Create the registry key if it doesn't exist
        if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetter")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetter" -Force | Out-Null
        }

        # Set the default label
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetter" -Name "DefaultLabel" -Value $label -PropertyType String -Force | Out-Null
        Write-Host "  [SUCCESS] Set label for $driveLetter`: to '$label'" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERROR] Could not set label: $_" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Label setting complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: You need to restart Windows Explorer to see the changes:" -ForegroundColor Yellow
Write-Host "1. Press Ctrl+Shift+Esc to open Task Manager" -ForegroundColor Gray
Write-Host "2. Find 'Windows Explorer' in the list" -ForegroundColor Gray
Write-Host "3. Right-click it and select 'Restart'" -ForegroundColor Gray
Write-Host ""
Write-Host "Or simply restart your computer." -ForegroundColor Gray
