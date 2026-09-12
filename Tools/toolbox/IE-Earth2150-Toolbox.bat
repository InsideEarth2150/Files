@echo off

rem =====================================================================
rem  InsideEarth - Earth 2150 Toolbox Launcher.
rem  Double-click this file. It fetches the latest setup script from
rem  GitHub and runs it.
rem =====================================================================

title IE - Earth 2150 Support App

:: Fixed ESC capture (removed space before the pipe)
for /F "delims=" %%a in ('echo prompt $E^|cmd') do set "ESC=%%a"

echo %ESC%[92m ===================================================%ESC%[0m
echo %ESC%[92m   InsideEarth - Earth 2150 Toolbox Launcher%ESC%[0m
echo %ESC%[92m ===================================================%ESC%[0m
echo.

echo The script is loaded from GitHub and executed...
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "$apiUrl = 'https://api.github.com/repos/InsideEarth2150/Files/commits?path=Tools/toolbox/IE-Earth2150-Toolbox.ps1&page=1&per_page=1'; $rawUrl = 'https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/downloaders/IE-Earth2150-Toolbox.ps1'; $scriptPath = Join-Path $env:TEMP 'IE-Earth2150-Toolbox.ps1'; $hashPath = Join-Path $env:TEMP 'IE-Earth2150-Toolbox.sha'; $needsDownload = $true; if ((Test-Path $scriptPath) -and (Test-Path $hashPath)) { try { $remoteHash = (Invoke-RestMethod -Uri $apiUrl -UseBasicParsing)[0].sha; $localHash = Get-Content $hashPath -Raw; if ($remoteHash.Trim() -eq $localHash.Trim()) { $needsDownload = $false } } catch { $needsDownload = $false } }; if ($needsDownload) { Write-Host 'Downloading update...' -ForegroundColor Cyan; Invoke-WebRequest -Uri $rawUrl -OutFile $scriptPath -UseBasicParsing; try { $latestHash = (Invoke-RestMethod -Uri $apiUrl -UseBasicParsing)[0].sha; Set-Content -Path $hashPath -Value $latestHash } catch {} } else { Write-Host 'Script is up to date.' -ForegroundColor Green }; & $scriptPath"

echo.

echo This window can now be closed.