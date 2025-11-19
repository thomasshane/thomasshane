# Network Drive Mapping Scripts

Simple PowerShell scripts to automatically map network drives with clean labels on Windows 11.

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
1. Map all four network drives with persistent connections
2. Set clean labels using the correct Windows 11 method
3. Restart Windows Explorer to apply changes

## Files

- **Map-All-Drives.bat** - Main script (double-click to run)
- **Troubleshoot.bat** - Diagnostic tool if something goes wrong

## Troubleshooting

If labels don't show correctly:
1. Run **Troubleshoot.bat** to see what's wrong
2. Try restarting your computer
3. Make sure you have proper AD permissions for the network paths

## How It Works

Windows 11 stores network drive labels in:
```
HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\[encoded-path]\_LabelFromReg
```

The script sets this registry value for each drive, which tells Windows Explorer to display your custom label instead of the full UNC path.

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
