<#
.SYNOPSIS
    Maps O Drive to \\Recorderreg\main with persistent connection.

.DESCRIPTION
    This script maps the O Drive for initial computer setup.
    The mapping persists after reboot/logout.

.NOTES
    Designed for initial computer setup where the path is controlled by AD group permissions.
#>

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "O Drive Mapping Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$driveLetter = "O:"
$path = "\\Recorderreg\main"
$label = "Recorder Main"  # Custom label for the drive (change this to whatever you want)

Write-Host "Mapping $driveLetter to $path..." -ForegroundColor Yellow
Write-Host ""

try {
    # Use net use command for reliable persistent network drive mapping
    # /persistent:yes ensures the mapping survives reboots
    $result = net use $driveLetter $path /persistent:yes 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [SUCCESS] Mapped $driveLetter" -ForegroundColor Green

        # Set custom drive label
        if ($label) {
            try {
                $driveLetterOnly = $driveLetter.TrimEnd(':')

                # Create the registry key if it doesn't exist
                if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly")) {
                    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly" -Force | Out-Null
                }

                # Set the default label
                New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly" -Name "DefaultLabel" -Value $label -PropertyType String -Force | Out-Null
                Write-Host "  [SUCCESS] Set drive label to '$label'" -ForegroundColor Green
            }
            catch {
                Write-Host "  [WARNING] Could not set custom label: $_" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  [FAILED] Could not map $driveLetter" -ForegroundColor Red
        Write-Host "    Error: $result" -ForegroundColor Red
    }
}
catch {
    Write-Host "  [ERROR] Error mapping $driveLetter : $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Drive mapping complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verify mapping by opening File Explorer or running: net use" -ForegroundColor Gray
