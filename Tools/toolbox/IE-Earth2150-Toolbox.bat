@echo off

rem =====================================================================
rem  InsideEarth - Earth 2150 Toolbox Launcher.
rem  Double-click this file. It fetches the latest setup script from
rem  GitHub and runs it.
rem =====================================================================

title InsideEarth - Earth 2150 Toolbox - Support App

:: Fixed ESC capture (removed space before the pipe)
for /F "delims=" %%a in ('echo prompt $E^|cmd') do set "ESC=%%a"

rem --- Preflight: confirm PowerShell is actually available before we rely on it ---
where powershell.exe >nul 2>&1
if errorlevel 1 goto :nopowershell

echo %ESC%[92m ===================================================%ESC%[0m
echo %ESC%[92m   InsideEarth - Earth 2150 Toolbox Launcher%ESC%[0m
echo %ESC%[92m ===================================================%ESC%[0m
echo.

echo The script is loaded from GitHub and executed...
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "$apiUrl = 'https://api.github.com/repos/InsideEarth2150/Files/commits?path=Tools/toolbox/IE-Earth2150-Toolbox.ps1&page=1&per_page=1'; $rawUrl = 'https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/toolbox/IE-Earth2150-Toolbox.ps1'; $scriptPath = Join-Path $env:TEMP 'IE-Earth2150-Toolbox.ps1'; $hashPath = Join-Path $env:TEMP 'IE-Earth2150-Toolbox.sha'; $needsDownload = $true; if ((Test-Path $scriptPath) -and (Test-Path $hashPath)) { try { $remoteHash = (Invoke-RestMethod -Uri $apiUrl -UseBasicParsing)[0].sha; $localHash = Get-Content $hashPath -Raw; if ($remoteHash.Trim() -eq $localHash.Trim()) { $needsDownload = $false } } catch { $needsDownload = $false } }; if ($needsDownload) { Write-Host 'Downloading update...' -ForegroundColor Cyan; Invoke-WebRequest -Uri $rawUrl -OutFile $scriptPath -UseBasicParsing; try { $latestHash = (Invoke-RestMethod -Uri $apiUrl -UseBasicParsing)[0].sha; Set-Content -Path $hashPath -Value $latestHash } catch {} } else { Write-Host 'Script is up to date.' -ForegroundColor Green }; if (-not (Test-Path $scriptPath)) { throw 'Setup script was not found after download attempt.' }; & $scriptPath"

if errorlevel 1 goto :launchfailed

echo.
echo This window can now be closed.
goto :eof

:nopowershell
echo %ESC%[91m ===================================================%ESC%[0m
echo %ESC%[91m   ERROR: PowerShell was not found on this system.%ESC%[0m
echo %ESC%[91m ===================================================%ESC%[0m
echo.
echo This launcher needs Windows PowerShell (powershell.exe) to run, and it
echo could not be found on your PATH. This is unusual on Windows 10/11 -
echo check whether PowerShell has been removed, renamed, or blocked by a
echo system/IT policy on this machine.
echo.
pause
exit /b 1

:launchfailed
echo.
echo %ESC%[91m ===================================================%ESC%[0m
echo %ESC%[91m   Something went wrong fetching or running the script.%ESC%[0m
echo %ESC%[91m ===================================================%ESC%[0m
echo.
echo This is usually one of:
echo   - No internet connection, or github.com / api.github.com is blocked
echo   - A proxy or firewall interfering with the download
echo   - PowerShell script execution restricted by Group Policy
echo.
echo Scroll up to see the specific error PowerShell reported above.
echo.
pause
exit /b 1