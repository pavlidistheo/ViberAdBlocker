
@echo off
setlocal EnableExtensions

title ViberAdBlocker - Windows

:: Check for Administrator privileges and request elevation if needed.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "URL=https://raw.githubusercontent.com/pavlidistheo/ViberAdBlocker/refs/heads/main/ViberAdBlocker"
set "HOSTS=%SystemRoot%\System32\drivers\etc\hosts"
set "TEMP_DIR=%TEMP%\ViberAdBlocker"

set "BEGIN=# BEGIN ViberAdBlocker"
set "END=# END ViberAdBlocker"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

set "DOWNLOAD=%TEMP_DIR%\download.txt"
set "DOMAINS=%TEMP_DIR%\domains.txt"
set "BASE=%TEMP_DIR%\hosts_base.txt"
set "NEW=%TEMP_DIR%\hosts_new.txt"

echo.
echo Downloading ViberAdBlocker from GitHub...
echo.

curl.exe --fail --silent --show-error --location "%URL%" -o "%DOWNLOAD%"
if errorlevel 1 (
    echo ERROR: Download failed.
    goto :ERROR
)

:: Validate and deduplicate downloaded domains.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$domains = @(); Get-Content -LiteralPath '%DOWNLOAD%' | ForEach-Object { $line = $_.Trim(); if ($line -match '^0\.0\.0\.0\s+([A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+)\s*$') { $domains += $Matches[1].ToLowerInvariant() } }; $domains = @($domains | Sort-Object -Unique); if ($domains.Count -eq 0) { exit 1 }; $domains | ForEach-Object { '0.0.0.0 ' + $_ } | Set-Content -LiteralPath '%DOMAINS%' -Encoding ASCII"

if errorlevel 1 (
    echo ERROR: No valid entries found.
    goto :ERROR
)

:: Remove the previous managed block and preserve everything else.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$lines = [System.IO.File]::ReadAllLines('%HOSTS%'); $result = [System.Collections.Generic.List[string]]::new(); $inside = $false; $invalid = $false; foreach ($line in $lines) { if ($line -ceq '%BEGIN%') { if ($inside) { $invalid = $true }; $inside = $true; continue }; if ($line -ceq '%END%') { if (-not $inside) { $invalid = $true }; $inside = $false; continue }; if (-not $inside) { $result.Add($line) } }; if ($inside -or $invalid) { exit 1 }; [System.IO.File]::WriteAllLines('%BASE%', $result, [System.Text.Encoding]::ASCII)"

if errorlevel 1 (
    echo ERROR: Invalid or incomplete ViberAdBlocker markers in hosts file.
    goto :ERROR
)

:: Add only domains not already present elsewhere in hosts.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$existing = @(); foreach ($line in [System.IO.File]::ReadAllLines('%BASE%')) { $content = ($line -split '#',2)[0].Trim(); $parts = $content -split '\s+'; if ($parts.Count -gt 1) { for ($i=1; $i -lt $parts.Count; $i++) { if ($parts[$i] -match '^[A-Za-z0-9.-]+$') { $existing += $parts[$i].ToLowerInvariant() } } } }; $domains = Get-Content -LiteralPath '%DOMAINS%'; $result = @($domains | Where-Object { ($_ -split '\s+')[1].ToLowerInvariant() -notin $existing }); [System.IO.File]::WriteAllLines('%TEMP_DIR%\new_entries.txt', $result, [System.Text.Encoding]::ASCII)"

if errorlevel 1 (
    echo ERROR: Could not process hosts entries.
    goto :ERROR
)

:: Build the new hosts file.
(
    type "%BASE%"
    echo.
    echo %BEGIN%
    type "%TEMP_DIR%\new_entries.txt"
    echo %END%
) > "%NEW%"

if errorlevel 1 (
    echo ERROR: Could not build updated hosts file.
    goto :ERROR
)

:: Replace hosts file.
copy /y "%NEW%" "%HOSTS%" >nul

if errorlevel 1 (
    echo ERROR: Could not update Windows hosts file.
    goto :ERROR
)

:: Refresh DNS cache.
ipconfig /flushdns >nul

echo.
echo ==========================================
echo ViberAdBlocker updated successfully!
echo ==========================================
echo.
echo Entries in GitHub list:
find /c /v "" "%DOMAINS%"
echo.
echo DNS cache refreshed.
echo.
echo Press any key to close.
pause >nul
goto :EOF

:ERROR
echo.
echo ViberAdBlocker update failed.
echo The hosts file was not intentionally changed.
echo.
echo Press any key to close.
pause >nul
exit /b 1
