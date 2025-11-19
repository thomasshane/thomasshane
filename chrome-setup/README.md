# Chrome Bookmarks and Startup Setup

Automatically configure Chrome bookmarks and startup pages for quick workstation setup.

## What This Does

Adds 5 work-related URLs to Chrome:
- **ADP WFNPORTAL** - Payroll/HR portal
- **Circuit Clerk Login** - Internal login page
- **Benton County Government** - Main county website
- **AppointmentPlus** - Appointment management
- **U.S. Passports** - Passport application portal

All URLs are:
- Added to the **bookmarks bar** for easy access
- Set to **open automatically** when Chrome starts

## Quick Start

**Just double-click `Setup-Chrome.bat`** - that's it!

The script will:
1. Close Chrome if it's running (required to modify settings)
2. Create backups of your current bookmarks and preferences
3. Add all 5 URLs to the bookmarks bar (skips any that already exist)
4. Configure all 5 URLs to open on Chrome startup
5. Show a summary of what was added vs. what already existed

## Files

- **Setup-Chrome.bat** - Main script (double-click to run)
- **Setup-Chrome.ps1** - PowerShell implementation

## Features

✅ **Smart duplicate detection** - Won't add bookmarks that already exist
✅ **Automatic backups** - Saves your current settings before making changes
✅ **Safe JSON handling** - Properly parses and updates Chrome's configuration files
✅ **Auto-close Chrome** - Handles Chrome being open
✅ **Clear feedback** - Shows exactly what was added vs. skipped

## Backup Location

Backups are automatically created with timestamps:
```
%LOCALAPPDATA%\Google\Chrome\User Data\Default\
  Bookmarks.backup_YYYYMMDD_HHMMSS
  Preferences.backup_YYYYMMDD_HHMMSS
```

You can manually restore from these backups if needed.

## How It Works

Chrome stores bookmarks and preferences in JSON files:
- **Bookmarks:** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Bookmarks`
- **Preferences:** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Preferences`

The script:
1. Closes Chrome (required because Chrome locks these files)
2. Creates timestamped backups
3. Parses the JSON files
4. Adds new bookmarks to the `bookmark_bar` section
5. Sets `restore_on_startup: 4` (open specific pages)
6. Populates the `startup_urls` array
7. Saves the updated JSON

## Customizing

To add or change URLs, edit `Setup-Chrome.ps1` and modify the `$bookmarks` array:

```powershell
$bookmarks = @(
    @{Name = "My Site"; Url = "https://example.com"}
    @{Name = "Another Site"; Url = "https://another.com"}
)
```

### If You Don't Want URLs to Open on Startup

Remove or comment out Step 4 in the script (lines that modify `session.restore_on_startup`).

### If You Only Want Bookmarks (No Startup Pages)

Set only specific URLs to open on startup by creating a separate array:
```powershell
$startupUrls = @("https://example.com", "https://another.com")
```

## Requirements

- Windows 11 (or Windows 10)
- Google Chrome must be installed
- Chrome must have been run at least once (to create the profile)
- No administrator privileges required

## Troubleshooting

**"Chrome profile not found"**
- Make sure Chrome is installed
- Run Chrome at least once to create the default profile

**"Could not close Chrome"**
- Manually close Chrome and run the script again
- Check if Chrome processes are stuck (Task Manager → End Process)

**Bookmarks don't appear**
- Check if Chrome is syncing (might override local changes)
- Verify the backup files were created
- Try restoring from backup if something went wrong

## Notes

- Works with the default Chrome profile
- Does not work with Chrome Enterprise policy-managed bookmarks
- Safe to run multiple times (won't create duplicates)
- Bookmarks are added to the end of the bookmarks bar
