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
# Format: @{DriveLetter = "X:"; Path = "\\server\share\folder"}
$driveMappings = @(
    @{DriveLetter = "J:"; Path = "\\bcfile\columbia\data\departments\circuitclerk\Court Doc External"}
    # Add more drive mappings below as needed:
    # @{DriveLetter = "K:"; Path = "\\server\share\anotherfolder"}
    # @{DriveLetter = "L:"; Path = "\\server\share\yetanotherfolder"}
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Network Drive Mapping Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    $path = $drive.Path

    Write-Host "Mapping $driveLetter to $path..." -ForegroundColor Yellow

    try {
        # Use net use command for reliable persistent network drive mapping
        # /persistent:yes ensures the mapping survives reboots
        $result = net use $driveLetter $path /persistent:yes 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [SUCCESS] Mapped $driveLetter" -ForegroundColor Green
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
