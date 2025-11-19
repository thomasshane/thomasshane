<#
.SYNOPSIS
    Maps network drives with clean labels - Complete solution for Windows 11.

.DESCRIPTION
    Maps all network drives (J, W, X, O) with persistent connections and sets
    clean labels using the MountPoints2 registry method (correct for Windows 11).
#>

# Define your drive mappings
$driveMappings = @(
    @{DriveLetter = "J:"; Path = "\\bcfile\columbia\data\departments\circuitclerk\Court Doc External"; Label = "Court Doc External"}
    @{DriveLetter = "W:"; Path = "\\bcfile\columbia\data\departments\e-filing\circuit"; Label = "Circuit"}
    @{DriveLetter = "X:"; Path = "\\bcfile\columbia\data\departments\e-filing\div1"; Label = "Div1"}
    @{DriveLetter = "O:"; Path = "\\Recorderreg\main"; Label = "Recorder Main"}
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Network Drive Mapper with Clean Labels" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$mountPointsBase = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    $path = $drive.Path
    $label = $drive.Label

    Write-Host "Setting up $driveLetter..." -ForegroundColor Yellow

    # Step 1: Map the drive
    Write-Host "  Mapping drive..." -ForegroundColor Gray
    $result = net use $driveLetter $path /persistent:yes 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [SUCCESS] Drive mapped" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] Drive may already be mapped" -ForegroundColor Gray
    }

    # Step 2: Set the label in MountPoints2 (the correct location for Windows 11)
    Write-Host "  Setting clean label..." -ForegroundColor Gray

    # Encode the UNC path for MountPoints2 (replace \ with #)
    $encodedPath = $path -replace '\\', '#'
    $mountPointPath = "$mountPointsBase\$encodedPath"

    try {
        # Create the MountPoint key if it doesn't exist
        if (-not (Test-Path $mountPointPath)) {
            New-Item -Path $mountPointPath -Force | Out-Null
        }

        # Set the _LabelFromReg value (this is what Windows 11 uses)
        New-ItemProperty -Path $mountPointPath -Name "_LabelFromReg" -Value $label -PropertyType String -Force | Out-Null

        # Verify it was set
        $verify = Get-ItemProperty -Path $mountPointPath -Name "_LabelFromReg" -ErrorAction SilentlyContinue

        if ($verify -and $verify._LabelFromReg -eq $label) {
            Write-Host "  [SUCCESS] Label set to '$label'" -ForegroundColor Green
        } else {
            Write-Host "  [WARNING] Label may not have been set correctly" -ForegroundColor Yellow
        }

        # Clear _LabelFromDesktopINI if it exists (can override our label)
        Remove-ItemProperty -Path $mountPointPath -Name "_LabelFromDesktopINI" -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "  [ERROR] Could not set label: $_" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "All drives configured!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Restarting Windows Explorer..." -ForegroundColor Yellow

try {
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 2
    Write-Host "Explorer restarted" -ForegroundColor Green
}
catch {
    Write-Host "Could not restart Explorer automatically" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "DONE! Check File Explorer to see your drives with clean labels." -ForegroundColor Green
Write-Host ""
Write-Host "If labels don't appear immediately:" -ForegroundColor Yellow
Write-Host "  1. Press F5 in File Explorer to refresh" -ForegroundColor Gray
Write-Host "  2. Or restart your computer" -ForegroundColor Gray
Write-Host ""
Write-Host "If you still have issues, run Troubleshoot.bat" -ForegroundColor Gray
