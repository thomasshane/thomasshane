# Network Drive Mapping Scripts

Automatically map network drives with clean labels on Windows 11.

## What This Does

Maps four network drives:
- **J Drive:** Court Doc External
- **W Drive:** Circuit
- **X Drive:** Div1
- **O Drive:** Recorder Main

Instead of showing ugly labels like `Court Doc External (\\bcfile\columbia\data\departments\circuitclerk)`, you get clean labels like `Court Doc External`.

## Quick Start

**Just double-click `Map-All-Drives.bat`** - that's it!

The script will:
1. Check if you have access to each network path
2. Map drives you have permission to access
3. Set clean labels using the correct Windows 11 method
4. Skip drives you don't have access to (won't hang or error)
5. Show a summary of successful/failed/skipped drives
6. Restart Windows Explorer to apply changes

## Files

- **Map-All-Drives.bat** - Main script (double-click to run)
- **Map-All-Drives.ps1** - PowerShell implementation
- **Troubleshoot.bat** - Diagnostic tool if something goes wrong
- **Troubleshoot.ps1** - PowerShell diagnostic implementation

## Features

✅ **Permission checking** - Tests access before attempting to map (5 second timeout)
✅ **Timeout protection** - Won't hang if network is slow or inaccessible (10 second timeout)
✅ **Graceful degradation** - Continues with remaining drives even if one fails
✅ **Clean labels** - Uses Windows 11's MountPoints2 registry method
✅ **Summary report** - Shows exactly what succeeded/failed/skipped

## Troubleshooting

If labels don't show correctly:
1. Run **Troubleshoot.bat** to see what's wrong
2. Try restarting your computer
3. Make sure you have proper AD permissions for the network paths

The Troubleshoot tool will show:
- Which drives are currently mapped
- Whether the registry labels are set correctly
- What Windows Explorer is displaying
- Specific issues with each drive

## How It Works

Windows 11 stores network drive labels in:
```
HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\[encoded-path]\_LabelFromReg
```

The script:
1. Tests path accessibility with a 5-second timeout
2. Maps the drive using `net use` with `/persistent:yes`
3. Sets the `_LabelFromReg` registry value
4. Clears any conflicting `_LabelFromDesktopINI` values
5. Restarts Windows Explorer to refresh the display

## Customizing

To add or change drives, edit `Map-All-Drives.ps1` and modify the `$driveMappings` array:

```powershell
$driveMappings = @(
    @{DriveLetter = "J:"; Path = "\\server\share\folder"; Label = "My Label"}
    @{DriveLetter = "K:"; Path = "\\server\other\path"; Label = "Another Label"}
)
```

## Requirements

- Windows 11 (Build 22000+)
- Network paths must be accessible via AD group permissions
- No administrator privileges required

## Notes

- Drive mappings persist after reboot/logout
- Uses `net use` with `/persistent:yes` flag
- Works with current user's AD credentials (no password needed)
- Compatible with domain-joined computers
- Safe for multi-user deployments with different permission sets
