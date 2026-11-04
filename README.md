# ViberAdBlocker

**Block advertisements and advertising-related tracking domains used by Viber.**

ViberAdBlocker is a community-friendly hosts-file blocklist designed to help users reduce advertisements and advertising-related connections associated with Viber.

The project provides a list of domains that can be added to the system's hosts file on Windows and Linux.

The goal is to make ad blocking accessible to everyone, including users with little or no technical experience.

## Features

- Blocks listed advertising and tracking domains.
- Supports Windows and Linux hosts files.
- Uses the standard `0.0.0.0` address mapping.
- Does not require additional software on Windows or Linux.
- Easy to install, update and remove.
- Includes automatic installation and update scripts for Windows and Linux.
- Free and publicly available.

## How does it work?

A hosts file is a local system file that maps domain names to IP addresses.

ViberAdBlocker uses entries such as:

```text
0.0.0.0 ads.viber.com
0.0.0.0 ads.aws.viber.com
0.0.0.0 ads-d.viber.com
```

When an application attempts to connect to one of the blocked domains, the hosts file redirects that domain to `0.0.0.0`, preventing the normal connection.

No browser extension is required.

## Installation

### Windows 10 / Windows 11

**Automatic installation (Recommended)**

<escape>**[⬇ DOWNLOAD ViberAdBlocker for Windows](https://github.com/pavlidistheo/ViberAdBlocker/raw/refs/heads/main/ViberAdBlockerWindows.bat)**</escape>

1. Click the download link above.
2. Once the download is complete, open your Downloads folder.
3. Double-click `ViberAdBlockerWindows.bat`.
4. Windows will display a User Account Control (UAC) prompt requesting Administrator privileges.
5. Click **Yes**.
6. The script will automatically download the latest blocklist from GitHub and update your Windows hosts file.

That's it! No need to open or edit any system files manually.

The script automatically:

- Requests Administrator privileges when necessary.
- Downloads the latest blocklist securely from GitHub using HTTPS.
- Retries the download if a temporary connection error occurs.
- Checks and validates downloaded entries before modifying the hosts file.
- Removes duplicate domains and normalizes domain names.
- Rejects invalid entries and protected domains.
- Checks the downloaded list against safety limits.
- Preserves unrelated entries in your existing hosts file.
- Replaces its previously managed entries when updating.
- Avoids adding domains that are already present elsewhere in the hosts file.
- Creates a backup of the existing hosts file before making changes.
- Replaces the hosts file using an atomic operation.
- Refreshes the Windows DNS cache automatically.

**Updating the blocklist**

Whenever you want to update the blocklist:

1. Double-click `ViberAdBlockerWindows.bat` again.
2. Approve the Administrator permission prompt.

The script automatically downloads the latest list from GitHub and replaces the previous ViberAdBlocker entries.

You do not need to download the script again for ordinary blocklist updates.

**Windows script options**

The script also supports the following optional commands:

| Command | Description |
|---|---|
| `ViberAdBlockerWindows.bat` | Installs or updates the blocklist. |
| `ViberAdBlockerWindows.bat --dry-run` | Shows what would change without modifying the hosts file. |
| `ViberAdBlockerWindows.bat --uninstall` | Removes the ViberAdBlocker-managed entries from the hosts file. |
| `ViberAdBlockerWindows.bat --help` | Displays the available commands. |

To use these options, open Command Prompt in the folder containing the script and execute the desired command.

**Backup information**

Before an actual installation, update or uninstallation, the script creates a backup of your existing hosts file at:

`C:\Windows\System32\drivers\etc\hosts.viberbak`

Only one backup is maintained. Each subsequent operation overwrites the previous backup with the hosts file as it existed immediately before that operation.

The `--dry-run` option does not modify the hosts file or create a backup.

**Important:** The script modifies the Windows hosts file and requires Administrator privileges. Do not close the script while it is running.

**Manual installation**

If you prefer to install the blocklist manually:

1. Open the Windows Start menu.
2. Search for **Notepad**.
3. Right-click Notepad and select **Run as administrator**.
4. In Notepad, select **File → Open**.
5. Navigate to:

   `C:\Windows\System32\drivers\etc\`

6. Change the file filter from **Text Documents (*.txt)** to **All files**.
7. Open the file named `hosts`.
8. Open the `ViberAdBlocker` file from this repository on GitHub.
9. Copy all its blocking entries.
10. Paste them at the bottom of your Windows hosts file.
11. Save the file.

Restart Viber to apply the changes.

Alternatively, restart Windows or open Command Prompt as administrator and execute:

```cmd
ipconfig /flushdns
```

### Linux

**Manual installation**

1. Open your terminal.
2. Execute:

```bash
sudo nano /etc/hosts
```

3. Enter your administrator password.
4. Open the `ViberAdBlocker` file from this repository on GitHub.
5. Copy all its blocking entries.
6. Paste them at the bottom of `/etc/hosts`.
7. Save the file using `Ctrl + O`, then press `Enter`.
8. Exit nano using `Ctrl + X`.

Restart Viber.

**Automatic installation using the script**

Linux
