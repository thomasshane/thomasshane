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

Write-Host "Mapping $driveLetter to $path..." -ForegroundColor Yellow
Write-Host ""

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
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Drive mapping complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verify mapping by opening File Explorer or running: net use" -ForegroundColor Gray
