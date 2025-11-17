# Network Drive Mapping Script

A PowerShell script to automatically map network drives with persistent connections on Windows computers.

## Purpose

This script is designed for initial computer setup to map multiple network drives that will persist after reboot/logout. The network paths are controlled by Active Directory group permissions.

## Usage

### Quick Start (Recommended)

**Simply double-click `Map-NetworkDrives.bat`** - that's it!

The batch file launcher will:
- Use Windows PowerShell (built into Windows - no installation needed)
- Bypass execution policy restrictions automatically
- Run the drive mapping script
- Pause so you can see the results

### Alternative: Run PowerShell Script Directly

If you prefer to run the PowerShell script directly:

1. Open PowerShell
2. Navigate to the script location
3. Run:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\Map-NetworkDrives.ps1
   ```

### Adding More Drives

Edit the `Map-NetworkDrives.ps1` file and add entries to the `$driveMappings` array:

```powershell
$driveMappings = @(
    @{DriveLetter = "J:"; Path = "\\bcfile\columbia\data\departments\circuitclerk\Court Doc External"}
    @{DriveLetter = "K:"; Path = "\\server\share\anotherfolder"}
    @{DriveLetter = "L:"; Path = "\\server\share\yetanotherfolder"}
)
```

### Format

- **DriveLetter**: Must include the colon (e.g., `"J:"`, `"K:"`)
- **Path**: Full UNC path to the network share (e.g., `"\\server\share\folder"`)

## Verifying Mappings

After running the script, verify the mappings by:
- Opening File Explorer - mapped drives should appear under "This PC"
- Running `net use` in Command Prompt to see all network connections

## Troubleshooting

- **Access Denied**: Ensure the user has proper AD group permissions for the network path
- **Network Path Not Found**: Verify the UNC path is correct and the server is accessible
- **Drive already mapped**: The script will show an error but continue with other drives

## Notes

- Works with Windows PowerShell 5.1+ (built into Windows 10/11 - no extra software needed)
- Drive mappings are persistent and will reconnect automatically after logout/reboot
- The script uses `net use` with `/persistent:yes` flag for reliability
- No credentials are needed in the script (uses current user's AD permissions)
- The batch launcher bypasses execution policy restrictions automatically
