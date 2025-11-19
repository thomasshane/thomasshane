<#
.SYNOPSIS
    Sets drive labels in MountPoints2 cache (the correct location for Windows 11).

.DESCRIPTION
    After investigation, we discovered Windows 11 pulls labels from
    HKCU:\...\MountPoints2\[encoded-path]\_LabelFromReg
    NOT from DriveIcons\X\DefaultLabel
#>

# Define your drive mappings
$driveMappings = @(
    @{DriveLetter = "J:"; Path = "\\bcfile\columbia\data\departments\circuitclerk\Court Doc External"; Label = "Court Doc External"}
    @{DriveLetter = "W:"; Path = "\\bcfile\columbia\data\departments\e-filing\circuit"; Label = "Circuit"}
    @{DriveLetter = "X:"; Path = "\\bcfile\columbia\data\departments\e-filing\div1"; Label = "Div1"}
    @{DriveLetter = "O:"; Path = "\\Recorderreg\main"; Label = "Recorder Main"}
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "MountPoints2 Label Setter" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$mountPointsBase = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    $path = $drive.Path
    $label = $drive.Label

    Write-Host "Setting label for $driveLetter ($path)..." -ForegroundColor Yellow

    # Encode the UNC path for MountPoints2 (replace \ with #)
    $encodedPath = $path -replace '\\', '#'
    $mountPointPath = "$mountPointsBase\$encodedPath"

    Write-Host "  Registry path: $mountPointPath" -ForegroundColor Gray

    try {
        # Create the MountPoint key if it doesn't exist
        if (-not (Test-Path $mountPointPath)) {
            Write-Host "  Creating MountPoint registry key..." -ForegroundColor Gray
            New-Item -Path $mountPointPath -Force | Out-Null
        }

        # Set the _LabelFromReg value
        New-ItemProperty -Path $mountPointPath -Name "_LabelFromReg" -Value $label -PropertyType String -Force | Out-Null

        # Verify it was set
        $verify = Get-ItemProperty -Path $mountPointPath -Name "_LabelFromReg" -ErrorAction SilentlyContinue

        if ($verify -and $verify._LabelFromReg -eq $label) {
            Write-Host "  [SUCCESS] Label set to '$label'" -ForegroundColor Green
        } else {
            Write-Host "  [WARNING] Label set but verification failed" -ForegroundColor Yellow
        }

        # Also clear _LabelFromDesktopINI if it exists (it can override _LabelFromReg)
        $desktopLabel = Get-ItemProperty -Path $mountPointPath -Name "_LabelFromDesktopINI" -ErrorAction SilentlyContinue
        if ($desktopLabel) {
            Write-Host "  Removing conflicting _LabelFromDesktopINI..." -ForegroundColor Gray
            Remove-ItemProperty -Path $mountPointPath -Name "_LabelFromDesktopINI" -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Host "  [ERROR] Failed to set label: $_" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Labels Set in MountPoints2" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now restarting Windows Explorer..." -ForegroundColor Yellow

try {
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 2
    Write-Host "Explorer restarted" -ForegroundColor Green
}
catch {
    Write-Host "Could not restart Explorer" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Check File Explorer - the labels should now be clean!" -ForegroundColor Green
Write-Host "If not, restart the computer and check again." -ForegroundColor Gray
