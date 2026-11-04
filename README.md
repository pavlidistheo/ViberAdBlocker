# ViberAdBlocker

Block Viber advertisements by using a custom hosts file.

ViberAdBlocker provides a regularly maintained list of domains associated with Viber advertisements and tracking. By redirecting these domains to `0.0.0.0` through your system's hosts file, you can block many advertisements before they reach your device.

## Features

- Blocks many Viber advertisements and tracking domains.
- Uses a centrally maintained blocklist hosted on GitHub.
- Supports Windows, Linux and Android (with root access).
- Preserves unrelated entries in your existing hosts file.
- Automatically updates the managed blocklist without creating duplicate entries.
- Includes an automated Windows installation and update script.
- Includes an automated Linux installation and update script.

## How It Works

ViberAdBlocker uses a hosts file to prevent connections to known advertising and tracking domains.

The blocklist contains entries in the following format:

```text
0.0.0.0 example-advertising-domain.com
0.0.0.0 example-tracking-domain.com
```

When your device attempts to connect to one of these domains, the hosts file redirects the connection to `0.0.0.0`, preventing the domain from being reached.

The blocklist is maintained in this repository and can be downloaded directly:

[View ViberAdBlocker Blocklist](https://github.com/pavlidistheo/ViberAdBlocker/blob/main/ViberAdBlocker)

---

## Windows

There are two ways to install ViberAdBlocker on Windows: automatically using the provided script or manually editing the hosts file.

### Automatic Installation (Recommended)

<escape>[⬇ DOWNLOAD ViberAdBlocker for Windows](https://github.com/pavlidistheo/ViberAdBlocker/releases/latest/download/ViberAdBlockerWindows.bat)</escape>

Download the Windows script and double-click the `.bat` file.

The script automatically requests administrator privileges and handles the installation process.

**What the script does:**

- Downloads the latest ViberAdBlocker blocklist directly from GitHub.
- Validates the downloaded entries.
- Removes duplicate domains.
- Checks for existing entries to avoid duplicates.
- Preserves unrelated entries in your Windows hosts file.
- Replaces the previously managed ViberAdBlocker entries with the latest list.
- Creates a backup of the hosts file before making changes.
- Flushes the Windows DNS cache after updating the hosts file.

No manual editing of the hosts file or command-line knowledge is required.

**Backup**

The script maintains one rolling backup of your original hosts file:

```text
C:\Windows\System32\drivers\etc\hosts.viberbak
```

The backup is overwritten before each actual installation, update or uninstallation.

**Additional commands**

The Windows script also supports the following options:

| Command | Description |
|---|---|
| `--help` | Displays available commands. |
| `--dry-run` | Previews changes without modifying the hosts file. |
| `--uninstall` | Removes the ViberAdBlocker managed entries. |

### Manual Installation

1. Open Notepad as Administrator.
2. Open the Windows hosts file:

   ```text
   C:\Windows\System32\drivers\etc\hosts
   ```

3. Select **All Files** in the file dialog to make the hosts file visible.
4. Download the [ViberAdBlocker blocklist](https://raw.githubusercontent.com/pavlidistheo/ViberAdBlocker/refs/heads/main/ViberAdBlocker).
5. Copy its contents into the hosts file.
6. Save the file.
7. Open Command Prompt as Administrator and execute:

   ```cmd
   ipconfig /flushdns
   ```

---

## Linux

ViberAdBlocker includes an automated Linux script that downloads and applies the latest blocklist.

### Automatic Installation

Download the `ViberAdBlockerLinux` script from this repository.

Open a terminal in the directory containing the downloaded script and execute:

```bash
chmod +x ViberAdBlockerLinux
sudo ./ViberAdBlockerLinux
```

The script automatically:

- Downloads the latest blocklist from GitHub using HTTPS.
- Validates the downloaded hosts entries.
- Removes duplicate entries.
- Preserves unrelated entries in `/etc/hosts`.
- Replaces the previously managed ViberAdBlocker entries.
- Avoids adding domains that already exist outside the managed block.
- Updates `/etc/hosts` using a temporary file and atomic replacement.

The script requires root privileges.

**Note:** The Linux script does not create a backup of `/etc/hosts`.

### Manual Installation

1. Open a terminal.
2. Download the blocklist:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/pavlidistheo/ViberAdBlocker/refs/heads/main/ViberAdBlocker
   ```

3. Open `/etc/hosts` with root privileges:

   ```bash
   sudo nano /etc/hosts
   ```

4. Add the downloaded blocklist entries.
5. Save the file.

---

## Android

Android users can also use ViberAdBlocker by adding the blocklist to the system hosts file.

**Requirements:** Root access is required to modify the system hosts file.

The hosts file is located at:

```text
/system/etc/hosts
```

1. Download the [ViberAdBlocker blocklist](https://raw.githubusercontent.com/pavlidistheo/ViberAdBlocker/refs/heads/main/ViberAdBlocker).
2. Use a root-enabled file manager or terminal to edit the hosts file.
3. Add the blocklist entries.
4. Save the changes and restart Viber if necessary.

**Non-rooted devices**

If your device is not rooted, you can use a DNS-based ad blocker that supports custom domain blocklists.

---

## Updating ViberAdBlocker

The blocklist is maintained in this GitHub repository and may be updated as new advertising and tracking domains are identified.

- **Windows:** Run `ViberAdBlockerWindows.bat` again to download and apply the latest list.
- **Linux:** Run `ViberAdBlockerLinux` again with root privileges.
- **Android:** Download the latest blocklist and update your hosts file manually.

Always use the latest version of the blocklist.

## Uninstallation

### Windows

Run the Windows script with the following option:

```cmd
ViberAdBlockerWindows.bat --uninstall
```

This removes the ViberAdBlocker managed entries while preserving unrelated hosts file entries. The script creates a backup before making the change.

### Linux

Open `/etc/hosts` with root privileges:

```bash
sudo nano /etc/hosts
```

Remove the entries between:

```text
# BEGIN ViberAdBlocker
```

and:

```text
# END ViberAdBlocker
```

Save the file.

---

## Limitations

ViberAdBlocker blocks known advertising and tracking domains through the hosts file.

It cannot guarantee that every advertisement will be blocked. Advertising domains may change, and some advertisements may be served from domains required for normal Viber functionality.

Blocking certain domains may affect some Viber features.

## Disclaimer

This project is provided for educational and ad-blocking purposes.

Use it at your own risk. The author is not responsible for any issues, data loss or application functionality problems resulting from the use of this blocklist or its scripts.

## Contributions

Contributions are welcome.

If you identify new advertising or tracking domains, you can open an issue or submit a pull request.

Please make sure that any suggested domains are genuinely related to advertising or tracking before submitting them.

## License

This project is open source. See the repository for licensing information.
