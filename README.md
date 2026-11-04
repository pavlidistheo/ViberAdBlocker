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

### Windows – Automatic installation using the script

Alternatively, Windows users can use the `ViberAdBlockerWindows.bat` script to automatically install and update the blocklist.

**First installation:**

1. Download `ViberAdBlockerWindows.bat` from this repository.
2. Double-click the downloaded file.
3. Windows will display a User Account Control (UAC) prompt requesting Administrator privileges.
4. Click **Yes** to allow the script to run.
5. The script will automatically download the latest blocklist from GitHub and update your Windows hosts file.

The script automatically:
- Downloads the latest blocklist.
- Validates the downloaded entries.
- Removes duplicate domains.
- Preserves unrelated entries in your hosts file.
- Replaces its previously managed entries when updating.
- Refreshes the Windows DNS cache.

**Updating the blocklist:**

Whenever you want to update the blocklist, simply double-click `ViberAdBlockerWindows.bat` again and approve the Administrator permission prompt.

You do not need to download the script again for ordinary blocklist updates.

**Important:** The script modifies the Windows hosts file and requires Administrator privileges. It does not create a backup of your hosts file.

### Linux

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

**Important:** Do not delete or overwrite your existing hosts-file entries. Preserve your localhost and hostname configurations.

### Linux – Automatic installation using the script

Alternatively, Linux users can use the `ViberAdBlockerLinux` script to automatically install and update the blocklist.

**Requirements:**
- `curl` installed on your system.
- Administrator privileges (`sudo`).

**First installation:**

1. Download the `ViberAdBlockerLinux` script from this repository.
2. Open a terminal in the directory where you downloaded the script.
3. Make the script executable:

```bash
chmod +x ViberAdBlockerLinux
```

4. Run the script with administrator privileges:

```bash
sudo ./ViberAdBlockerLinux
```

5. Enter your administrator password when prompted.

The script automatically downloads the latest blocklist from this repository and updates your `/etc/hosts` file.

It also:
- Validates the downloaded entries.
- Removes duplicate domains.
- Preserves unrelated entries in your hosts file.
- Replaces its previously managed entries when updating.

**Updating the blocklist:**

Whenever you want to update the blocklist, open a terminal in the directory containing the script and run:

```bash
sudo ./ViberAdBlockerLinux
```

The script downloads the latest version directly from GitHub. You do not need to download the script again for ordinary blocklist updates.

**Important:** The script modifies `/etc/hosts` and requires administrator privileges. It does not create a backup of your hosts file.

## Android

Android also uses a hosts file, normally located at:

`/system/etc/hosts`

However, modifying this file normally requires root access.

Users without root access can alternatively use a DNS-based ad-blocking service that supports custom domain blocklists.

The domains in this repository may be suitable for use with compatible DNS filtering services, subject to their supported import formats.

## Updating the blocklist

When a new version becomes available:

1. Open the latest `ViberAdBlocker` file in this repository.
2. Copy the updated entries.
3. Remove the previous ViberAdBlocker entries from your hosts file.
4. Paste the new entries.
5. Save the hosts file.
6. Restart Viber.

Avoid appending the updated list without removing the previous version, as this can create unnecessary duplicates.

## Uninstallation

To remove ViberAdBlocker:

1. Open your system's hosts file.
2. Locate the entries added by ViberAdBlocker.
3. Remove those entries.
4. Save the file.
5. Restart Viber.

Do not remove unrelated entries from your hosts file.

## Important information and limitations

- Hosts files do not support wildcard entries such as `ads.*.viber.com`.
- Only explicitly listed domains are blocked.
- Viber may change its advertising domains over time.
- Some listed domains belong to third-party advertising, analytics or content-delivery services.
- Blocking third-party domains may affect advertising, analytics or embedded content in other applications and websites.
- This blocklist cannot guarantee the removal of every advertisement.
- Blocking domains may affect some Viber functionality or content.

Use this blocklist at your own discretion.

## Disclaimer

ViberAdBlocker is an independent community project.

It is not affiliated with, endorsed by, or officially supported by Viber or Rakuten.

All trademarks and product names belong to their respective owners.

## Contributions

Suggestions, corrections and additional domain submissions are welcome.

Please ensure that proposed domains are relevant and properly verified before including them in the blocklist.

## License

See the repository's LICENSE file for the applicable licensing terms.

---

**Author:** Theodoros Pavlidis
