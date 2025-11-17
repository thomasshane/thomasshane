# Network Drive Mapping Script

A PowerShell script to automatically map network drives with persistent connections on Windows computers.

## Purpose

This script is designed for initial computer setup to map multiple network drives that will persist after reboot/logout. The network paths are controlled by Active Directory group permissions.

## Usage

### Running the Script

1. **Open PowerShell as Administrator**
   - Right-click on PowerShell
   - Select "Run as Administrator"

2. **Navigate to the script location**
   ```powershell
   cd C:\path\to\script
   ```

3. **Allow script execution** (if this is the first time running PowerShell scripts)
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Run the script**
   ```powershell
   .\Map-NetworkDrives.ps1
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
- Running `net use` in PowerShell/Command Prompt to see all network connections

## Troubleshooting

- **Access Denied**: Ensure the user has proper AD group permissions for the network path
- **Network Path Not Found**: Verify the UNC path is correct and the server is accessible
- **Script Won't Run**: Check PowerShell execution policy with `Get-ExecutionPolicy`

## Notes

- Drive mappings are persistent and will reconnect automatically after logout/reboot
- The script uses `net use` with `/persistent:yes` flag for reliability
- No credentials are needed in the script (uses current user's AD permissions)
