<#
.SYNOPSIS
    Nuclear option - completely cleans up and remaps all network drives.

.DESCRIPTION
    This script will:
    1. Disconnect all specified network drives
    2. Remove old registry entries
    3. Restart Windows Explorer
    4. Remap drives with clean labels
#>

# Define your drive mappings
$driveMappings = @(
    @{DriveLetter = "J:"; Path = "\\bcfile\columbia\data\departments\circuitclerk\Court Doc External"; Label = "Court Doc External"}
    @{DriveLetter = "W:"; Path = "\\bcfile\columbia\data\departments\e-filing\circuit"; Label = "Circuit"}
    @{DriveLetter = "X:"; Path = "\\bcfile\columbia\data\departments\e-filing\div1"; Label = "Div1"}
    @{DriveLetter = "O:"; Path = "\\Recorderreg\main"; Label = "Recorder Main"}
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Full Cleanup and Remap Script" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Disconnect all drives
Write-Host "STEP 1: Disconnecting existing drives..." -ForegroundColor Yellow
Write-Host ""

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    Write-Host "  Disconnecting $driveLetter..." -ForegroundColor Gray

    $result = net use $driveLetter /delete /yes 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [SUCCESS] Disconnected $driveLetter" -ForegroundColor Green
    } else {
        Write-Host "    [INFO] $driveLetter was not connected or already disconnected" -ForegroundColor Gray
    }
}

Write-Host ""

# Step 2: Clean up old registry entries
Write-Host "STEP 2: Cleaning up old registry entries..." -ForegroundColor Yellow
Write-Host ""

foreach ($drive in $driveMappings) {
    $driveLetterOnly = $drive.DriveLetter.TrimEnd(':')
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly"

    if (Test-Path $regPath) {
        Write-Host "  Removing old registry entry for $driveLetterOnly..." -ForegroundColor Gray
        Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "    [SUCCESS] Cleaned up registry for $driveLetterOnly" -ForegroundColor Green
    } else {
        Write-Host "    [INFO] No registry entry found for $driveLetterOnly" -ForegroundColor Gray
    }
}

Write-Host ""

# Step 3: Restart Windows Explorer
Write-Host "STEP 3: Restarting Windows Explorer..." -ForegroundColor Yellow
Write-Host ""

try {
    Stop-Process -Name explorer -Force -ErrorAction Stop
    Write-Host "  [SUCCESS] Windows Explorer restarted" -ForegroundColor Green
    Start-Sleep -Seconds 2
}
catch {
    Write-Host "  [WARNING] Could not restart Explorer: $_" -ForegroundColor Yellow
}

Write-Host ""

# Step 4: Remap drives with labels
Write-Host "STEP 4: Mapping drives with clean labels..." -ForegroundColor Yellow
Write-Host ""

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    $path = $drive.Path
    $label = $drive.Label

    Write-Host "  Mapping $driveLetter to $path..." -ForegroundColor Gray

    try {
        $result = net use $driveLetter $path /persistent:yes 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [SUCCESS] Mapped $driveLetter" -ForegroundColor Green

            # Set custom drive label
            if ($label) {
                Start-Sleep -Milliseconds 500  # Brief pause to ensure drive is ready

                try {
                    $driveLetterOnly = $driveLetter.TrimEnd(':')

                    # Create the registry key
                    if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly")) {
                        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly" -Force | Out-Null
                    }

                    # Set the default label
                    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly" -Name "DefaultLabel" -Value $label -PropertyType String -Force | Out-Null
                    Write-Host "    [SUCCESS] Set label to '$label'" -ForegroundColor Green
                }
                catch {
                    Write-Host "    [WARNING] Could not set label: $_" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "    [FAILED] Could not map $driveLetter" -ForegroundColor Red
            Write-Host "    Error: $result" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "    [ERROR] Error mapping $driveLetter : $_" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Cleanup and remapping complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please check File Explorer to verify the clean labels are showing." -ForegroundColor Yellow
Write-Host "If not, try logging out and back in, or restart your computer." -ForegroundColor Yellow
