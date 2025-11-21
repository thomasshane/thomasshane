# Chrome Bookmarks and Startup Setup

Automatically configure Chrome bookmarks and startup pages for quick workstation setup.

## Available Scripts

### Recorder Bookmarks
**Double-click `Setup-Recorder-Bookmarks.bat`**

Adds 5 URLs for Recorder staff:
- **ADP WFNPORTAL** - Payroll/HR portal
- **Circuit Clerk Login** - Internal login page
- **Benton County Government** - Main county website
- **AppointmentPlus** - Appointment management
- **U.S. Passports** - Passport application portal

---

### Criminal/Civil Bookmarks
**Double-click `Setup-CriminalCivil-Bookmarks.bat`**

Adds 6 URLs for Criminal/Civil staff:
- **Clerk ECF** - Court electronic filing
- **eFlex** - eFlex system
- **Benton County Government** - Main county website
- **Internal Court Connect** - Court system login
- **Circuit Clerk Login** - Internal login page
- **ADP** - Payroll/HR portal

---

## What These Scripts Do

All URLs are:
- Added to the **bookmarks bar** for easy access
- Set to **open automatically** when Chrome starts

The scripts will:
1. Close Chrome if it's running (required to modify settings)
2. Create backups of your current bookmarks and preferences
3. Add all URLs to the bookmarks bar (skips any that already exist)
4. Configure all URLs to open on Chrome startup
5. Show a summary of what was added vs. what already existed

## Files

**Recorder:**
- `Setup-Recorder-Bookmarks.bat` - Double-click to run
- `Setup-Recorder-Bookmarks.ps1` - PowerShell implementation

**Criminal/Civil:**
- `Setup-CriminalCivil-Bookmarks.bat` - Double-click to run
- `Setup-CriminalCivil-Bookmarks.ps1` - PowerShell implementation

## Features

- **Smart duplicate detection** - Won't add bookmarks that already exist
- **Automatic backups** - Saves your current settings before making changes
- **Auto-detect Chrome profile** - Works with Default, Profile 1, etc.
- **Creates missing files** - Works even if Chrome hasn't created bookmarks yet
- **Auto-close Chrome** - Handles Chrome being open
- **Clear feedback** - Shows exactly what was added vs. skipped

## Backup Location

Backups are automatically created with timestamps:
```
%LOCALAPPDATA%\Google\Chrome\User Data\Default\
  Bookmarks.backup_YYYYMMDD_HHMMSS
  Preferences.backup_YYYYMMDD_HHMMSS
```

## Customizing

To add or change URLs, edit the `.ps1` file and modify the `$bookmarks` array:

```powershell
$bookmarks = @(
    @{Name = "My Site"; Url = "https://example.com"}
    @{Name = "Another Site"; Url = "https://another.com"}
)
```

## Requirements

- Windows 11 (or Windows 10)
- Google Chrome must be installed
- No administrator privileges required

## Troubleshooting

**"Chrome profile not found"**
- Make sure Chrome is installed
- Run Chrome at least once to create the default profile

**"Could not close Chrome"**
- Manually close Chrome and run the script again

**Bookmarks don't appear**
- Check if Chrome is syncing (might override local changes)
- Try restarting Chrome

## Notes

- Works with multiple Chrome profiles (Default, Profile 1, etc.)
- Safe to run multiple times (won't create duplicates)
- Bookmarks are added to the end of the bookmarks bar
