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
$successCount = 0
$failCount = 0
$skippedCount = 0

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    $path = $drive.Path
    $label = $drive.Label

    Write-Host "Setting up $driveLetter..." -ForegroundColor Yellow

    # Step 1: Quick accessibility check (with timeout)
    Write-Host "  Checking access to $path..." -ForegroundColor Gray

    $accessible = $false
    $testJob = Start-Job -ScriptBlock {
        param($testPath)
        Test-Path $testPath -ErrorAction Stop
    } -ArgumentList $path

    # Wait max 5 seconds for the test
    $testJob | Wait-Job -Timeout 5 | Out-Null

    if ($testJob.State -eq 'Completed') {
        $accessible = Receive-Job $testJob
        Remove-Job $testJob -Force
    } else {
        # Job timed out or failed
        Stop-Job $testJob -ErrorAction SilentlyContinue
        Remove-Job $testJob -Force -ErrorAction SilentlyContinue
        Write-Host "  [SKIPPED] Access check timed out (likely no permissions)" -ForegroundColor Yellow
        Write-Host ""
        $skippedCount++
        continue
    }

    if (-not $accessible) {
        Write-Host "  [SKIPPED] No access to path (check AD permissions)" -ForegroundColor Yellow
        Write-Host ""
        $skippedCount++
        continue
    }

    Write-Host "  [OK] Path is accessible" -ForegroundColor Green

    # Step 2: Map the drive with timeout protection
    Write-Host "  Mapping drive..." -ForegroundColor Gray

    $mapJob = Start-Job -ScriptBlock {
        param($letter, $netPath)
        $result = net use $letter $netPath /persistent:yes 2>&1
        return @{
            ExitCode = $LASTEXITCODE
            Output = $result
        }
    } -ArgumentList $driveLetter, $path

    # Wait max 10 seconds for mapping
    $mapJob | Wait-Job -Timeout 10 | Out-Null

    $mapSuccess = $false
    if ($mapJob.State -eq 'Completed') {
        $mapResult = Receive-Job $mapJob
        Remove-Job $mapJob -Force

        if ($mapResult.ExitCode -eq 0) {
            Write-Host "  [SUCCESS] Drive mapped" -ForegroundColor Green
            $mapSuccess = $true
        } elseif ($mapResult.Output -match "multiple connections|already connected") {
            Write-Host "  [SUCCESS] Drive already mapped" -ForegroundColor Green
            $mapSuccess = $true
        } else {
            Write-Host "  [FAILED] Could not map drive: $($mapResult.Output)" -ForegroundColor Red
            $failCount++
        }
    } else {
        # Mapping timed out
        Stop-Job $mapJob -ErrorAction SilentlyContinue
        Remove-Job $mapJob -Force -ErrorAction SilentlyContinue
        Write-Host "  [FAILED] Mapping timed out" -ForegroundColor Red
        Write-Host ""
        $failCount++
        continue
    }

    # Step 3: Set the label in MountPoints2 (only if mapping succeeded)
    if ($mapSuccess) {
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
                $successCount++
            } else {
                Write-Host "  [WARNING] Label may not have been set correctly" -ForegroundColor Yellow
                $successCount++
            }

            # Clear _LabelFromDesktopINI if it exists (can override our label)
            Remove-ItemProperty -Path $mountPointPath -Name "_LabelFromDesktopINI" -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "  [ERROR] Could not set label: $_" -ForegroundColor Red
            $failCount++
        }
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Successful: $successCount" -ForegroundColor Green
Write-Host "  Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host "  Skipped (no permissions): $skippedCount" -ForegroundColor $(if ($skippedCount -gt 0) { "Yellow" } else { "Gray" })
Write-Host ""

if ($successCount -gt 0) {
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
}

if ($skippedCount -gt 0) {
    Write-Host ""
    Write-Host "NOTE: Some drives were skipped due to permission issues." -ForegroundColor Yellow
    Write-Host "This is normal if the current user doesn't need access to all drives." -ForegroundColor Gray
}

if ($failCount -gt 0) {
    Write-Host ""
    Write-Host "Some drives failed to map. Run Troubleshoot.bat for more details." -ForegroundColor Red
}
