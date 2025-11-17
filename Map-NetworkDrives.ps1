<#
.SYNOPSIS
    Maps network drives with persistent connections for initial computer setup.

.DESCRIPTION
    This script maps multiple network drives that persist after reboot/logout.
    Designed for initial computer setup where drives are controlled by AD group permissions.

.NOTES
    Run this script with administrator privileges for best results.
    To run: Right-click PowerShell and select "Run as Administrator", then execute:
    .\Map-NetworkDrives.ps1
#>

# Define your drive mappings here
# Format: @{DriveLetter = "X:"; Path = "\\server\share\folder"; Label = "Friendly Name"}
$driveMappings = @(
    @{DriveLetter = "J:"; Path = "\\bcfile\columbia\data\departments\circuitclerk\Court Doc External"; Label = "Court Doc External"}
    # Add more drive mappings below as needed:
    # @{DriveLetter = "K:"; Path = "\\server\share\anotherfolder"; Label = "My Documents"}
    # @{DriveLetter = "L:"; Path = "\\server\share\yetanotherfolder"; Label = "Shared Files"}
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Network Drive Mapping Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    $path = $drive.Path
    $label = $drive.Label

    Write-Host "Mapping $driveLetter to $path..." -ForegroundColor Yellow

    try {
        # Use net use command for reliable persistent network drive mapping
        # /persistent:yes ensures the mapping survives reboots
        $result = net use $driveLetter $path /persistent:yes 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [SUCCESS] Mapped $driveLetter" -ForegroundColor Green

            # Set custom drive label if provided
            if ($label) {
                try {
                    $driveLetterOnly = $driveLetter.TrimEnd(':')
                    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly\DefaultLabel"

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
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Drive mapping complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verify mappings by opening File Explorer or running: net use" -ForegroundColor Gray
