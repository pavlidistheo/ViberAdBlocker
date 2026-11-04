
@echo off
setlocal EnableExtensions
title ViberAdBlocker - Windows

rem ViberAdBlocker - Windows installer / updater
rem
rem Usage:
rem   ViberAdBlockerWindows.bat              install or update the blocklist
rem   ViberAdBlockerWindows.bat --dry-run    show what would change
rem   ViberAdBlockerWindows.bat --uninstall  remove managed entries
rem   ViberAdBlockerWindows.bat --help
rem
rem The PowerShell code is stored at the bottom of this file.

set "SELF=%~f0"
set "UNINSTALL=0"
set "DRYRUN=0"
set "ELEVATED=0"

for %%A in (%*) do (
    if /i "%%~A"=="--uninstall" set "UNINSTALL=1"
    if /i "%%~A"=="--dry-run" set "DRYRUN=1"
    if /i "%%~A"=="elevated" set "ELEVATED=1"
    if /i "%%~A"=="--help" goto :HELP
)

rem Arguments passed to the elevated copy.
set "FWD=elevated"
if "%UNINSTALL%"=="1" set "FWD=%FWD% --uninstall"
if "%DRYRUN%"=="1" set "FWD=%FWD% --dry-run"

rem fltmc checks Administrator rights without depending on Server service.
fltmc >nul 2>&1
if errorlevel 1 (
    if "%ELEVATED%"=="1" (
        echo ERROR: Administrator rights could not be obtained.
        echo.
        pause
        exit /b 1
    )
    echo Requesting Administrator privileges...
    powershell.exe -NoProfile -Command "Start-Process -FilePath '%SELF:'=''%' -ArgumentList '%FWD%' -Verb RunAs"
    if errorlevel 1 (
        echo.
        echo Administrator permission was not granted.
        echo.
        pause
        exit /b 1
    )
    exit /b 0
)

set "VIBER_UNINSTALL=%UNINSTALL%"
set "VIBER_DRYRUN=%DRYRUN%"
set "VIBER_SELF=%SELF%"

echo.
powershell.exe -NoProfile -Command "$m='#__POWER'+'SHELL__'; $s=[IO.File]::ReadAllText($env:VIBER_SELF); $i=$s.IndexOf($m); if ($i -lt 0) { throw 'PowerShell section not found.' }; & ([scriptblock]::Create($s.Substring($i+$m.Length)))"
set "RC=%errorlevel%"

echo.
echo Press any key to close.
pause >nul
exit /b %RC%

:HELP
echo.
echo ViberAdBlocker - Windows installer / updater
echo.
echo   ViberAdBlockerWindows.bat              Install or update
echo   ViberAdBlockerWindows.bat --dry-run    Preview changes without modifying hosts
echo   ViberAdBlockerWindows.bat --uninstall  Remove the managed block
echo   ViberAdBlockerWindows.bat --help       Show this help
echo.
exit /b 0

#__POWERSHELL__

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$Url        = 'https://raw.githubusercontent.com/pavlidistheo/ViberAdBlocker/refs/heads/main/ViberAdBlocker'
$HostsPath  = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$BackupPath = $HostsPath + '.viberbak'

$Begin = '# BEGIN ViberAdBlocker'
$End   = '# END ViberAdBlocker'

# Download safety limits.
$MaxBytes  = 5MB
$MaxDomains = 5000

# Protected domains. Exact domains and all their subdomains are rejected.
$Deny = @(
    'localhost.localdomain',
    'github.com',
    'githubusercontent.com',
    'github.io',
    'githubassets.com',
    'microsoft.com',
    'windows.com',
    'windowsupdate.com',
    'msftconnecttest.com',
    'msftncsi.com'
)

$Uninstall = ($env:VIBER_UNINSTALL -eq '1')
$DryRun    = ($env:VIBER_DRYRUN -eq '1')

# Latin-1 maps each original hosts-file byte to one character.
# Writing it back with the same encoding preserves existing non-ASCII bytes.
$Latin1 = [System.Text.Encoding]::GetEncoding(28591)

$stage        = 'preparing'
$tmp          = $null
$failed       = $false
$hostsChanged = $false
$dnsFlushed   = $false

# ---------------------------------------------------------------------------
# Download using HTTPS, bounded streaming and retries.
# ---------------------------------------------------------------------------

function Get-BoundedDownloadText {

    $lastError = $null

    for ($attempt = 1; $attempt -le 3; $attempt++) {

        $handler  = $null
        $client   = $null
        $response = $null
        $cts      = $null

        try {

            Add-Type -AssemblyName System.Net.Http

            $handler = [System.Net.Http.HttpClientHandler]::new()
            $handler.AllowAutoRedirect = $false
            $handler.AutomaticDecompression = (
                [System.Net.DecompressionMethods]::GZip -bor
                [System.Net.DecompressionMethods]::Deflate
            )

            $client = [System.Net.Http.HttpClient]::new($handler)
            $client.Timeout = [System.Threading.Timeout]::InfiniteTimeSpan
            [void]$client.DefaultRequestHeaders.UserAgent.ParseAdd('ViberAdBlocker-Windows/1.0')

            $currentUri = [uri]$Url
            $redirects = 0

            while ($true) {

                if ($currentUri.Scheme -ne 'https') {
                    throw 'A non-HTTPS download or redirect was rejected.'
                }

                $cts = [System.Threading.CancellationTokenSource]::new()

                # Maximum time to establish the connection and receive headers.
                $cts.CancelAfter(10000)

                $request = [System.Net.Http.HttpRequestMessage]::new(
                    [System.Net.Http.HttpMethod]::Get,
                    $currentUri
                )

                try {
                    $response = $client.SendAsync(
                        $request,
                        [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead,
                        $cts.Token
                    ).GetAwaiter().GetResult()
                }
                finally {
                    $request.Dispose()
                }

                # Handle redirects manually so every destination is checked.
                $status = [int]$response.StatusCode

                if ($status -ge 300 -and $status -lt 400) {

                    if ($redirects -ge 3) {
                        throw 'The download exceeded the maximum number of redirects.'
                    }

                    $location = $response.Headers.Location

                    if ($null -eq $location) {
                        throw 'The server returned a redirect without a destination.'
                    }

                    if ($location.IsAbsoluteUri) {
                        $nextUri = $location
                    }
                    else {
                        $nextUri = [uri]::new($currentUri, $location)
                    }

                    if ($nextUri.Scheme -ne 'https') {
                        throw 'A redirect to a non-HTTPS destination was rejected.'
                    }

                    $response.Dispose()
                    $response = $null

                    $currentUri = $nextUri
                    $redirects++
                    continue
                }

                if (-not $response.IsSuccessStatusCode) {
                    throw "GitHub returned HTTP status $status."
                }

                if ($response.RequestMessage.RequestUri.Scheme -ne 'https') {
                    throw 'The final download destination was not HTTPS.'
                }

                # Reject oversized responses when Content-Length is available.
                $contentLength = $response.Content.Headers.ContentLength

                if ($null -ne $contentLength -and $contentLength -gt $MaxBytes) {
                    throw 'The downloaded list exceeds the 5 MB safety limit.'
                }

                # Allow up to 60 seconds for the response body.
                $cts.CancelAfter(60000)

                $stream = $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
                $memory = [System.IO.MemoryStream]::new()

                try {

                    $buffer = New-Object byte[] 81920
                    [long]$received = 0

                    while ($true) {

                        $read = $stream.ReadAsync(
                            $buffer,
                            0,
                            $buffer.Length,
                            $cts.Token
                        ).GetAwaiter().GetResult()

                        if ($read -eq 0) {
                            break
                        }

                        $received += $read

                        # Enforce the limit against actual downloaded bytes.
                        if ($received -gt $MaxBytes) {
                            throw 'The downloaded list exceeded the 5 MB safety limit.'
                        }

                        $memory.Write($buffer, 0, $read)
                    }

                    $bytes = $memory.ToArray()

                    return [System.Text.Encoding]::UTF8.GetString($bytes)
                }
                finally {
                    $stream.Dispose()
                    $memory.Dispose()
                }
            }
        }
        catch {
            $lastError = $_.Exception
        }
        finally {

            if ($null -ne $response) {
                $response.Dispose()
            }

            if ($null -ne $cts) {
                $cts.Dispose()
            }

            if ($null -ne $client) {
                $client.Dispose()
            }
            elseif ($null -ne $handler) {
                $handler.Dispose()
            }
        }

        if ($attempt -lt 3) {
            Start-Sleep -Seconds 2
        }
    }

    throw $lastError
}

try {

    # -----------------------------------------------------------------------
    # 1. Download and validate the blocklist.
    # -----------------------------------------------------------------------

    $domains = @()

    if (-not $Uninstall) {

        $stage = 'downloading the list'
        Write-Host 'Downloading ViberAdBlocker from GitHub...'

        $text = Get-BoundedDownloadText

        $stage = 'validating the list'

        # Remove UTF-8 BOM, if present.
        $text = $text -replace '^\uFEFF', ''

        # Normalize CRLF, LF and CR line endings.
        $rawLines = $text -split '\r\n|\n|\r'

        $rx = '^0\.0\.0\.0\s+([a-z0-9](?:[a-z0-9-]*[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)+)\s*(?:#.*)?$'

        $set = [System.Collections.Generic.HashSet[string]]::new()

        foreach ($raw in $rawLines) {

            $m = [regex]::Match(
                $raw.Trim(),
                $rx,
                [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
            )

            if (-not $m.Success) {
                continue
            }

            $h = $m.Groups[1].Value.ToLowerInvariant()

            if ($h.Length -gt 253) {
                continue
            }

            # Reject IP-like entries.
            if ($h -match '\.[0-9]+$') {
                continue
            }

            # Reject protected domains and all their subdomains.
            $rejected = $false

            foreach ($blocked in $Deny) {

                if (
                    $h -eq $blocked -or
                    $h.EndsWith(
                        '.' + $blocked,
                        [System.StringComparison]::OrdinalIgnoreCase
                    )
                ) {
                    $rejected = $true
                    break
                }
            }

            if ($rejected) {
                continue
            }

            [void]$set.Add($h)
        }

        if ($set.Count -eq 0) {
            throw 'No valid entries found in the downloaded list.'
        }

        if ($set.Count -gt $MaxDomains) {
            throw "The list has $($set.Count) entries (limit $MaxDomains). Refusing to continue."
        }

        $domains = @($set | Sort-Object)
    }

    # -----------------------------------------------------------------------
    # 2. Read the hosts file and remove the previous managed block.
    # -----------------------------------------------------------------------

    $stage = 'reading the hosts file'

    if (-not (Test-Path -LiteralPath $HostsPath -PathType Leaf)) {
        throw "The Windows hosts file was not found: $HostsPath"
    }

    $lines = [System.IO.File]::ReadAllLines($HostsPath, $Latin1)

    $base = New-Object 'System.Collections.Generic.List[string]'

    $inside   = $false
    $invalid  = $false
    $hadBlock = $false

    foreach ($line in $lines) {

        if ($line -ceq $Begin) {

            if ($inside -or $hadBlock) {
                $invalid = $true
            }

            $inside = $true
            $hadBlock = $true
            continue
        }

        if ($line -ceq $End) {

            if (-not $inside) {
                $invalid = $true
            }

            $inside = $false
            continue
        }

        if (-not $inside) {
            $base.Add($line)
        }
    }

    if ($inside -or $invalid) {
        throw 'Invalid, incomplete or duplicated ViberAdBlocker markers in the hosts file. No changes were made.'
    }

    if ($Uninstall -and -not $hadBlock) {
        Write-Host 'No ViberAdBlocker entries found in the hosts file. Nothing to remove.'
        exit 0
    }

    # Remove trailing blank lines to prevent accumulation after updates.
    while (
        $base.Count -gt 0 -and
        [string]::IsNullOrWhiteSpace($base[$base.Count - 1])
    ) {
        $base.RemoveAt($base.Count - 1)
    }

    # -----------------------------------------------------------------------
    # 3. Identify domains already present outside the managed block.
    # -----------------------------------------------------------------------

    $existing = [System.Collections.Generic.HashSet[string]]::new()

    foreach ($line in $base) {

        $content = ($line -split '#', 2)[0].Trim()
        $parts = $content -split '\s+'

        for ($i = 1; $i -lt $parts.Count; $i++) {
            [void]$existing.Add($parts[$i].ToLowerInvariant())
        }
    }

    $entries = @(
        $domains |
        Where-Object { -not $existing.Contains($_) } |
        ForEach-Object { '0.0.0.0 ' + $_ }
    )

    $total   = $domains.Count
    $added   = $entries.Count
    $skipped = $total - $added

    # -----------------------------------------------------------------------
    # 4. Dry-run: show the result without changing any files.
    # -----------------------------------------------------------------------

    if ($DryRun) {

        Write-Host ''
        Write-Host 'Dry run - the hosts file was not changed.'

        if ($Uninstall) {
            Write-Host 'Would remove the ViberAdBlocker block.'
        }
        else {
            Write-Host "Valid entries in GitHub list : $total"
            Write-Host "Would be written             : $added"
            Write-Host "Already present elsewhere    : $skipped"
        }

        exit 0
    }

    # -----------------------------------------------------------------------
    # 5. Build the new hosts-file content.
    # -----------------------------------------------------------------------

    $out = New-Object 'System.Collections.Generic.List[string]'
    $out.AddRange($base)

    if (-not $Uninstall) {

        if ($out.Count -gt 0) {
            $out.Add('')
        }

        $out.Add($Begin)
        $out.AddRange([string[]]$entries)
        $out.Add($End)
    }

    # -----------------------------------------------------------------------
    # 6. Create one rolling backup and prepare the replacement file.
    # -----------------------------------------------------------------------

    $stage = 'backing up the hosts file'

    # Exactly one backup. Each successful operation replaces the previous
    # backup with the hosts file as it existed before that operation.
    Copy-Item -LiteralPath $HostsPath -Destination $BackupPath -Force

    $stage = 'preparing the replacement hosts file'

    # Create the temporary file in the hosts directory.
    # It inherits the directory's permissions and stays on the same volume.
    $tmp = Join-Path (
        Split-Path -Parent $HostsPath
    ) ('hosts.viber.' + [guid]::NewGuid().ToString('N'))

    [System.IO.File]::WriteAllLines(
        $tmp,
        $out.ToArray(),
        $Latin1
    )

    # -----------------------------------------------------------------------
    # 7. Atomically replace the hosts file.
    # -----------------------------------------------------------------------

    $stage = 'atomically replacing the hosts file'

    # Do not fall back to a potentially unsafe ordinary copy.
    # If atomic replacement fails, the original hosts file remains in place.
    [System.IO.File]::Replace(
        $tmp,
        $HostsPath,
        $null
    )

    $tmp = $null
    $hostsChanged = $true

    # -----------------------------------------------------------------------
    # 8. Refresh Windows DNS cache.
    # -----------------------------------------------------------------------

    $stage = 'flushing the DNS cache'

    & ipconfig.exe /flushdns | Out-Null

    if ($LASTEXITCODE -eq 0) {
        $dnsFlushed = $true
    }

    # -----------------------------------------------------------------------
    # 9. Display the result.
    # -----------------------------------------------------------------------

    Write-Host ''
    Write-Host '=========================================='

    if ($Uninstall) {
        Write-Host ' ViberAdBlocker entries removed.'
    }
    else {
        Write-Host ' ViberAdBlocker updated successfully!'
    }

    Write-Host '=========================================='

    if (-not $Uninstall) {
        Write-Host "Valid entries in GitHub list : $total"
        Write-Host "Written to hosts             : $added"
        Write-Host "Already present elsewhere    : $skipped"
    }

    Write-Host "Backup of previous hosts file: $BackupPath"

    if ($dnsFlushed) {
        Write-Host 'DNS cache refreshed.'
    }
    else {
        Write-Host 'WARNING: DNS cache could not be refreshed.'
        Write-Host 'You may need to restart Viber or Windows.'
    }
}
catch {

    $failed = $true

    Write-Host ''
    Write-Host "ERROR while $stage`: $($_.Exception.Message)" -ForegroundColor Red

    if ($hostsChanged) {
        Write-Host 'The hosts file was changed, but a later operation failed.'
    }
    else {
        Write-Host 'The hosts file was not changed.'
    }

    if (Test-Path -LiteralPath $BackupPath) {
        Write-Host "Backup of previous hosts file: $BackupPath"
    }
}
finally {

    # Remove any temporary file left behind.
    if ($tmp -and (Test-Path -LiteralPath $tmp)) {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

if ($failed) {
    exit 1
}

exit 0
