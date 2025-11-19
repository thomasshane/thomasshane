# Windows Workstation Setup Scripts

PowerShell scripts to automate common workstation setup tasks for Windows 11.

## 📁 Available Tools

### [Drive Mapping](drive-mapping/)
Automatically map network drives with clean labels (no ugly UNC paths shown).

**What it does:**
- Maps 4 network drives: J, W, X, O
- Sets clean labels (e.g., "Court Doc External" instead of "Court Doc External (\\bcfile\columbia\...)")
- Handles permission issues gracefully
- Skips drives the user doesn't have access to

**Usage:** Download the `drive-mapping` folder and double-click `Map-All-Drives.bat`

---

### [Chrome Setup](chrome-setup/)
Automatically configure Chrome bookmarks and startup pages.

**What it does:**
- Adds 5 work-related URLs to Chrome bookmarks bar
- Configures all URLs to open when Chrome starts
- Creates automatic backups before making changes
- Skips bookmarks that already exist

**Usage:** Download the `chrome-setup` folder and double-click `Setup-Chrome.bat`

---

## 🚀 Quick Start

1. **Download the folder** for the tool you need
2. **Double-click the .bat file**
3. Done!

All scripts work without administrator privileges and include automatic error handling.

## 📋 Requirements

- Windows 11 (Build 22000+)
- PowerShell 5.1+ (built into Windows)
- For drive mapping: Active Directory group permissions for network paths
- For Chrome setup: Chrome must be installed and run at least once

## 🔧 Features

- **Zero configuration** - just double-click and run
- **Smart error handling** - continues even if some operations fail
- **Automatic backups** - Chrome setup backs up existing settings
- **Permission-aware** - skips items the user can't access
- **Clear feedback** - shows exactly what succeeded/failed/skipped

## 📖 Detailed Documentation

See README files in each folder for detailed information:
- [Drive Mapping Documentation](drive-mapping/README.md)
- [Chrome Setup Documentation](chrome-setup/README.md)

## 💡 Customization

All scripts are easily customizable - just edit the `.ps1` files to:
- Add/remove network drives
- Change drive labels
- Add/remove Chrome bookmarks
- Modify startup pages

## 🤝 Support

For issues or questions, check the troubleshooting sections in each tool's README.
