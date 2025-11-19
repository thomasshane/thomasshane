<#
.SYNOPSIS
    Most aggressive cleanup and remap - clears all possible caches.

.DESCRIPTION
    This script goes beyond the normal cleanup by:
    - Clearing MountPoints2 cache
    - Clearing icon cache
    - Clearing shell bags
    - Multiple Explorer restarts
    - Setting labels with verification
#>

# Define your drive mappings
$driveMappings = @(
    @{DriveLetter = "J:"; Path = "\\bcfile\columbia\data\departments\circuitclerk\Court Doc External"; Label = "Court Doc External"}
    @{DriveLetter = "W:"; Path = "\\bcfile\columbia\data\departments\e-filing\circuit"; Label = "Circuit"}
    @{DriveLetter = "X:"; Path = "\\bcfile\columbia\data\departments\e-filing\div1"; Label = "Div1"}
    @{DriveLetter = "O:"; Path = "\\Recorderreg\main"; Label = "Recorder Main"}
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUPER AGGRESSIVE Cleanup and Remap" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will perform the most thorough cleanup possible" -ForegroundColor Yellow
Write-Host ""

# Step 1: Disconnect all drives
Write-Host "STEP 1: Disconnecting drives..." -ForegroundColor Yellow
Write-Host ""

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    Write-Host "  Disconnecting $driveLetter..." -ForegroundColor Gray
    $result = net use $driveLetter /delete /yes 2>&1
}

Write-Host "  Waiting 2 seconds..." -ForegroundColor Gray
Start-Sleep -Seconds 2
Write-Host ""

# Step 2: Clear ALL drive-related registry entries
Write-Host "STEP 2: Clearing registry entries..." -ForegroundColor Yellow
Write-Host ""

foreach ($drive in $driveMappings) {
    $driveLetterOnly = $drive.DriveLetter.TrimEnd(':')

    # Clear DriveIcons
    $regPath1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly"
    if (Test-Path $regPath1) {
        Write-Host "  Removing DriveIcons entry for $driveLetterOnly..." -ForegroundColor Gray
        Remove-Item -Path $regPath1 -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Clear any cached shell bags
    $shellBagsPath = "HKCU:\Software\Microsoft\Windows\Shell\Bags"
    if (Test-Path $shellBagsPath) {
        Get-ChildItem -Path $shellBagsPath -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.PSPath -like "*$driveLetterOnly*" } |
            ForEach-Object {
                Write-Host "  Removing ShellBag cache for $driveLetterOnly..." -ForegroundColor Gray
                Remove-Item -Path $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
            }
    }
}

# Clear MountPoints2 cache
Write-Host "  Clearing MountPoints2 cache..." -ForegroundColor Gray
$mountPointsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
if (Test-Path $mountPointsPath) {
    Remove-Item -Path $mountPointsPath -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""

# Step 3: Clear icon cache
Write-Host "STEP 3: Clearing icon cache..." -ForegroundColor Yellow
Write-Host ""

$iconCachePath = "$env:LOCALAPPDATA\IconCache.db"
if (Test-Path $iconCachePath) {
    Write-Host "  Deleting icon cache..." -ForegroundColor Gray
    Remove-Item -Path $iconCachePath -Force -ErrorAction SilentlyContinue
}

# Clear additional icon cache files
$iconCacheFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
if (Test-Path $iconCacheFolder) {
    Get-ChildItem -Path $iconCacheFolder -Filter "iconcache*.db" -ErrorAction SilentlyContinue |
        ForEach-Object {
            Write-Host "  Deleting $($_.Name)..." -ForegroundColor Gray
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
        }
}

Write-Host ""

# Step 4: Kill Explorer
Write-Host "STEP 4: Restarting Windows Explorer..." -ForegroundColor Yellow
Write-Host ""

try {
    Stop-Process -Name explorer -Force -ErrorAction Stop
    Write-Host "  Explorer stopped" -ForegroundColor Green
    Start-Sleep -Seconds 3
    Write-Host "  Explorer will restart automatically" -ForegroundColor Green
    Start-Sleep -Seconds 2
}
catch {
    Write-Host "  Could not restart Explorer: $_" -ForegroundColor Yellow
}

Write-Host ""

# Step 5: Map drives with labels
Write-Host "STEP 5: Mapping drives with labels..." -ForegroundColor Yellow
Write-Host ""

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    $path = $drive.Path
    $label = $drive.Label

    Write-Host "  Mapping $driveLetter..." -ForegroundColor Gray

    # Map the drive
    $result = net use $driveLetter $path /persistent:yes 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [SUCCESS] Drive mapped" -ForegroundColor Green

        # Wait a moment for the drive to fully register
        Start-Sleep -Milliseconds 500

        # Set the label
        if ($label) {
            $driveLetterOnly = $driveLetter.TrimEnd(':')
            $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly"

            try {
                # Create the key
                if (-not (Test-Path $regPath)) {
                    New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
                }

                # Set the label
                New-ItemProperty -Path $regPath -Name "DefaultLabel" -Value $label -PropertyType String -Force -ErrorAction Stop | Out-Null

                # Verify it was set
                Start-Sleep -Milliseconds 200
                $verify = Get-ItemProperty -Path $regPath -Name "DefaultLabel" -ErrorAction SilentlyContinue

                if ($verify -and $verify.DefaultLabel -eq $label) {
                    Write-Host "    [SUCCESS] Label set and verified: '$label'" -ForegroundColor Green
                } else {
                    Write-Host "    [WARNING] Label set but verification failed" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "    [ERROR] Could not set label: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "    [FAILED] Could not map drive" -ForegroundColor Red
        Write-Host "    Error: $result" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Super Aggressive Cleanup Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Run Advanced-Diagnostic.bat to verify labels are set" -ForegroundColor Gray
Write-Host "2. If labels still don't show, restart the computer" -ForegroundColor Gray
Write-Host "3. If labels STILL don't show after restart, run Advanced-Diagnostic.bat" -ForegroundColor Gray
Write-Host "   and compare the output with the working computer" -ForegroundColor Gray
