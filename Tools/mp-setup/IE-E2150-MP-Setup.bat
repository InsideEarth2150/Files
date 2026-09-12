@echo off
rem =====================================================================
rem  InsideEarth - Earth 2150 Community Server: one-click setup.
rem  Double-click this file. It fetches the latest setup script from
rem  GitHub and runs it: adds the server to your game's server list and
rem  enables DirectPlay. No manual input needed.
rem =====================================================================
title InsideEarth 2150 Community EarthNet Serever Setup
echo.
echo InsideEarth 2150 Community EarthNet Serever Setup
echo.
echo The setup is loaded from GitHub and executed...
echo.
powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "$apiUrl = 'https://api.github.com/repos/InsideEarth2150/Files/commits?path=Tools/mp-setup/Earth2150-MP-Setup.ps1&page=1&per_page=1'; $rawUrl = 'https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/mp-setup/Earth2150-MP-Setup.ps1'; $scriptPath = Join-Path $env:TEMP 'Earth2150-MP-Setup.ps1'; $hashPath = Join-Path $env:TEMP 'Earth2150-MP-Setup.sha'; $needsDownload = $true; if ((Test-Path $scriptPath) -and (Test-Path $hashPath)) { try { $remoteHash = (Invoke-RestMethod -Uri $apiUrl -UseBasicParsing)[0].sha; $localHash = Get-Content $hashPath -Raw; if ($remoteHash.Trim() -eq $localHash.Trim()) { $needsDownload = $false } } catch { $needsDownload = $false } }; if ($needsDownload) { Write-Host 'Downloading update...' -ForegroundColor Cyan; Invoke-WebRequest -Uri $rawUrl -OutFile $scriptPath -UseBasicParsing; try { $latestHash = (Invoke-RestMethod -Uri $apiUrl -UseBasicParsing)[0].sha; Set-Content -Path $hashPath -Value $latestHash } catch {} } else { Write-Host 'Script is up to date.' -ForegroundColor Green }; & $scriptPath"
echo.
echo This window can now be closed.