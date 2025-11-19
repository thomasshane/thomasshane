<#
.SYNOPSIS
    Multi-method drive label setter for maximum compatibility.

.DESCRIPTION
    Tries multiple methods to set drive labels, including compatibility
    modes for older Windows builds that don't automatically use folder names.
#>

# Define your drive mappings
$driveMappings = @(
    @{DriveLetter = "J:"; Path = "\\bcfile\columbia\data\departments\circuitclerk\Court Doc External"; Label = "Court Doc External"}
    @{DriveLetter = "W:"; Path = "\\bcfile\columbia\data\departments\e-filing\circuit"; Label = "Circuit"}
    @{DriveLetter = "X:"; Path = "\\bcfile\columbia\data\departments\e-filing\div1"; Label = "Div1"}
    @{DriveLetter = "O:"; Path = "\\Recorderreg\main"; Label = "Recorder Main"}
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Multi-Method Drive Label Setter" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Host "Windows Build: $($osInfo.BuildNumber)" -ForegroundColor Gray
Write-Host ""

foreach ($drive in $driveMappings) {
    $driveLetter = $drive.DriveLetter
    $driveLetterOnly = $driveLetter.TrimEnd(':')
    $label = $drive.Label

    Write-Host "Setting label for $driveLetter to '$label'..." -ForegroundColor Yellow

    $successCount = 0

    # Method 1: Standard DriveIcons\X\DefaultLabel
    try {
        $regPath1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly"
        if (-not (Test-Path $regPath1)) {
            New-Item -Path $regPath1 -Force | Out-Null
        }
        New-ItemProperty -Path $regPath1 -Name "DefaultLabel" -Value $label -PropertyType String -Force | Out-Null

        $verify = Get-ItemProperty -Path $regPath1 -Name "DefaultLabel" -ErrorAction SilentlyContinue
        if ($verify.DefaultLabel -eq $label) {
            Write-Host "  [Method 1] DefaultLabel registry: SUCCESS" -ForegroundColor Green
            $successCount++
        }
    }
    catch {
        Write-Host "  [Method 1] DefaultLabel registry: FAILED" -ForegroundColor Red
    }

    # Method 2: Try setting at base level (some builds check here)
    try {
        $regPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons"
        Set-ItemProperty -Path $regPath2 -Name "$driveLetterOnly" -Value $label -ErrorAction Stop
        Write-Host "  [Method 2] Base-level registry: SUCCESS" -ForegroundColor Green
        $successCount++
    }
    catch {
        # This might not work on all systems, that's okay
        Write-Host "  [Method 2] Base-level registry: FAILED (expected on some builds)" -ForegroundColor Gray
    }

    # Method 3: Try DefaultIcon path as well (forces Explorer refresh)
    try {
        $regPath3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$driveLetterOnly\DefaultIcon"
        if (-not (Test-Path $regPath3)) {
            New-Item -Path $regPath3 -Force | Out-Null
        }
        # Set a generic icon path (this sometimes forces Explorer to re-read labels)
        Set-ItemProperty -Path $regPath3 -Name "(Default)" -Value "%SystemRoot%\System32\imageres.dll,54" -ErrorAction Stop
        Write-Host "  [Method 3] DefaultIcon trigger: SUCCESS" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "  [Method 3] DefaultIcon trigger: FAILED" -ForegroundColor Yellow
    }

    # Method 4: Force Shell to refresh this specific drive
    try {
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.NameSpace($driveLetter)
        if ($folder) {
            # Access the folder to trigger refresh
            $null = $folder.Items()
        }
        Write-Host "  [Method 4] Shell refresh: SUCCESS" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "  [Method 4] Shell refresh: FAILED" -ForegroundColor Yellow
    }

    if ($successCount -gt 0) {
        Write-Host "  RESULT: $successCount methods succeeded" -ForegroundColor Green
    } else {
        Write-Host "  RESULT: All methods failed!" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Multi-Method Complete" -ForegroundColor Cyan
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
Write-Host "Check File Explorer to see if labels are displayed correctly." -ForegroundColor Gray
Write-Host "If not, restart the computer and check again." -ForegroundColor Gray
