<#
.SYNOPSIS
    Adds bookmarks to Chrome bookmarks bar and sets startup pages.

.DESCRIPTION
    This script adds specified URLs to Chrome's bookmarks bar and configures
    them to open on Chrome startup. Chrome must be closed for this to work.
#>

# Define your URLs and their names
$bookmarks = @(
    @{Name = "ADP WFNPORTAL"; Url = "https://online.adp.com/signin/v1/?APPID=WFNPortal&productId=80e309c3-7085-bae1-e053-3505430b5495&returnURL=https://workforcenow.adp.com/&callingAppId=WFN&TARGET=-SM-https://workforcenow.adp.com/theme/index.html"}
    @{Name = "Circuit Clerk Login"; Url = "https://intranet.bentoncountyar.gov/circuit-clerk/wp-login.php?redirect_to=https%3A%2F%2Fintranet.bentoncountyar.gov%2Fcircuit-clerk%2F"}
    @{Name = "Benton County Government"; Url = "https://bentoncountyar.gov/"}
    @{Name = "AppointmentPlus"; Url = "https://account.appointment-plus.com/ap/ap_admin_v2/login.php?_ga=2.48959842.573335458.1595811313-1501577317.1591824931"}
    @{Name = "U.S. Passports"; Url = "https://travel.state.gov/content/travel/en/passports.html"}
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Chrome Bookmarks and Startup Configuration" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Find Chrome profile
Write-Host "Detecting Chrome profile..." -ForegroundColor Yellow

$chromeUserDataPath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$chromePath = $null
$profileNames = @("Default", "Profile 1", "Profile 2", "Profile 3")

foreach ($profileName in $profileNames) {
    $testPath = Join-Path $chromeUserDataPath $profileName
    if (Test-Path $testPath) {
        $chromePath = $testPath
        Write-Host "  [FOUND] Using profile: $profileName" -ForegroundColor Green
        break
    }
}

if (-not $chromePath) {
    Write-Host "[ERROR] Chrome profile not found. Checked:" -ForegroundColor Red
    foreach ($profileName in $profileNames) {
        Write-Host "  - $chromeUserDataPath\$profileName" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Please ensure Chrome is installed and has been run at least once." -ForegroundColor Yellow
    pause
    exit 1
}

$bookmarksFile = Join-Path $chromePath "Bookmarks"
$preferencesFile = Join-Path $chromePath "Preferences"

Write-Host "  Profile path: $chromePath" -ForegroundColor Gray
Write-Host ""

# Step 1: Close Chrome if running
Write-Host "Step 1: Checking if Chrome is running..." -ForegroundColor Yellow
$chromeProcesses = Get-Process chrome -ErrorAction SilentlyContinue

if ($chromeProcesses) {
    Write-Host "  Chrome is running. Attempting to close..." -ForegroundColor Gray

    try {
        Stop-Process -Name chrome -Force
        Start-Sleep -Seconds 3
        Write-Host "  [SUCCESS] Chrome closed" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERROR] Could not close Chrome: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please close Chrome manually and run this script again." -ForegroundColor Yellow
        pause
        exit 1
    }
} else {
    Write-Host "  [OK] Chrome is not running" -ForegroundColor Green
}

Write-Host ""

# Step 2: Backup existing files
Write-Host "Step 2: Creating backups..." -ForegroundColor Yellow

if (Test-Path $bookmarksFile) {
    $backupBookmarks = "$bookmarksFile.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $bookmarksFile $backupBookmarks
    Write-Host "  [SUCCESS] Bookmarks backed up to:" -ForegroundColor Green
    Write-Host "    $(Split-Path $backupBookmarks -Leaf)" -ForegroundColor Gray
}

if (Test-Path $preferencesFile) {
    $backupPreferences = "$preferencesFile.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $preferencesFile $backupPreferences
    Write-Host "  [SUCCESS] Preferences backed up to:" -ForegroundColor Green
    Write-Host "    $(Split-Path $backupPreferences -Leaf)" -ForegroundColor Gray
}

Write-Host ""

# Step 3: Add bookmarks
Write-Host "Step 3: Adding bookmarks to bookmarks bar..." -ForegroundColor Yellow

try {
    # Check if bookmarks file exists, create if it doesn't
    if (-not (Test-Path $bookmarksFile)) {
        Write-Host "  [INFO] Bookmarks file not found, creating new one..." -ForegroundColor Yellow

        # Create basic bookmarks structure
        $newBookmarks = @{
            checksum = ""
            roots = @{
                bookmark_bar = @{
                    children = @()
                    date_added = [string]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() * 10000000 + 11644473600000000)
                    date_last_used = "0"
                    date_modified = "0"
                    guid = [guid]::NewGuid().ToString()
                    id = "1"
                    name = "Bookmarks bar"
                    type = "folder"
                }
                other = @{
                    children = @()
                    date_added = [string]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() * 10000000 + 11644473600000000)
                    date_last_used = "0"
                    date_modified = "0"
                    guid = [guid]::NewGuid().ToString()
                    id = "2"
                    name = "Other bookmarks"
                    type = "folder"
                }
                synced = @{
                    children = @()
                    date_added = [string]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() * 10000000 + 11644473600000000)
                    date_last_used = "0"
                    date_modified = "0"
                    guid = [guid]::NewGuid().ToString()
                    id = "3"
                    name = "Mobile bookmarks"
                    type = "folder"
                }
            }
            version = 1
        }

        $newBookmarks | ConvertTo-Json -Depth 100 | Set-Content $bookmarksFile -Encoding UTF8
        Write-Host "  [SUCCESS] Created new bookmarks file" -ForegroundColor Green
    }

    # Read and parse bookmarks JSON
    $bookmarksJson = Get-Content $bookmarksFile -Raw | ConvertFrom-Json

    # Get the bookmarks bar
    $bookmarksBar = $bookmarksJson.roots.bookmark_bar

    # Get current max ID to generate new IDs
    $maxId = 1
    function Get-MaxId($node) {
        if ($node.id -and [int]$node.id -gt $script:maxId) {
            $script:maxId = [int]$node.id
        }
        if ($node.children) {
            foreach ($child in $node.children) {
                Get-MaxId $child
            }
        }
    }
    Get-MaxId $bookmarksJson.roots

    # Add each bookmark if it doesn't already exist
    $addedCount = 0
    foreach ($bookmark in $bookmarks) {
        # Check if bookmark already exists
        $exists = $false
        if ($bookmarksBar.children) {
            foreach ($child in $bookmarksBar.children) {
                if ($child.url -eq $bookmark.Url) {
                    $exists = $true
                    break
                }
            }
        }

        if (-not $exists) {
            $maxId++
            $newBookmark = @{
                date_added = [string]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() * 10000000 + 11644473600000000)
                guid = [guid]::NewGuid().ToString()
                id = [string]$maxId
                name = $bookmark.Name
                type = "url"
                url = $bookmark.Url
            }

            if (-not $bookmarksBar.children) {
                $bookmarksBar | Add-Member -MemberType NoteProperty -Name "children" -Value @()
            }

            $bookmarksBar.children += $newBookmark
            Write-Host "  [ADDED] $($bookmark.Name)" -ForegroundColor Green
            $addedCount++
        } else {
            Write-Host "  [EXISTS] $($bookmark.Name)" -ForegroundColor Gray
        }
    }

    # Save bookmarks
    $bookmarksJson | ConvertTo-Json -Depth 100 | Set-Content $bookmarksFile -Encoding UTF8
    Write-Host ""
    Write-Host "  Summary: $addedCount new bookmarks added" -ForegroundColor Green

} catch {
    Write-Host "  [ERROR] Failed to add bookmarks: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Restore from backup if needed:" -ForegroundColor Yellow
    Write-Host "  $backupBookmarks" -ForegroundColor Gray
    pause
    exit 1
}

Write-Host ""

# Step 4: Set startup pages
Write-Host "Step 4: Configuring startup pages..." -ForegroundColor Yellow

try {
    # Check if preferences file exists, create if it doesn't
    if (-not (Test-Path $preferencesFile)) {
        Write-Host "  [INFO] Preferences file not found, creating new one..." -ForegroundColor Yellow

        # Create basic preferences structure
        $newPreferences = @{
            session = @{
                restore_on_startup = 4
                startup_urls = @()
            }
        }

        $newPreferences | ConvertTo-Json -Depth 100 | Set-Content $preferencesFile -Encoding UTF8
        Write-Host "  [SUCCESS] Created new preferences file" -ForegroundColor Green
    }

    # Read and parse preferences JSON
    $preferencesJson = Get-Content $preferencesFile -Raw | ConvertFrom-Json

    # Ensure session structure exists
    if (-not $preferencesJson.session) {
        $preferencesJson | Add-Member -MemberType NoteProperty -Name "session" -Value @{}
    }

    # Set restore_on_startup to 4 (open specific pages)
    if ($preferencesJson.session.PSObject.Properties['restore_on_startup']) {
        $preferencesJson.session.restore_on_startup = 4
    } else {
        $preferencesJson.session | Add-Member -MemberType NoteProperty -Name "restore_on_startup" -Value 4
    }

    # Set startup URLs
    $startupUrls = @($bookmarks | ForEach-Object { $_.Url })

    if ($preferencesJson.session.PSObject.Properties['startup_urls']) {
        $preferencesJson.session.startup_urls = $startupUrls
    } else {
        $preferencesJson.session | Add-Member -MemberType NoteProperty -Name "startup_urls" -Value $startupUrls
    }

    # Save preferences
    $preferencesJson | ConvertTo-Json -Depth 100 | Set-Content $preferencesFile -Encoding UTF8
    Write-Host "  [SUCCESS] $($bookmarks.Count) startup pages configured" -ForegroundColor Green

} catch {
    Write-Host "  [ERROR] Failed to set startup pages: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Restore from backup if needed:" -ForegroundColor Yellow
    Write-Host "  $backupPreferences" -ForegroundColor Gray
    pause
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Configuration Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Bookmarks added to bookmarks bar: $addedCount" -ForegroundColor Green
Write-Host "Startup pages configured: $($bookmarks.Count)" -ForegroundColor Green
Write-Host ""
Write-Host "Next time you open Chrome:" -ForegroundColor Yellow
Write-Host "  - Your bookmarks will appear in the bookmarks bar" -ForegroundColor Gray
Write-Host "  - All $($bookmarks.Count) pages will open on startup" -ForegroundColor Gray
Write-Host ""
Write-Host "Backups saved in:" -ForegroundColor Gray
Write-Host "  $chromePath" -ForegroundColor Gray
