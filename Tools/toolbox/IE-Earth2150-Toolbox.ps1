# =====================================================================
#   InsideEARTH - Earth 2150 Tools & Utilities Launcher v1.0
# =====================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Self-elevation check
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    # Relaunches the current script with elevated privileges and keeps the window open
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

clear

$host.ui.RawUI.WindowTitle = "InsideEARTH - Earth 2150 Tools & Utilities Launcher v1.0"
$ErrorActionPreference = 'Stop'

# Main loop for top-level menu selection
while ($true) {
    Clear-Host

    Write-Host " ===================================================" -ForegroundColor Green
    Write-Host "   InsideEARTH - Earth 2150 Tools & Utilities Menu" -ForegroundColor Green
    Write-Host " ===================================================" -ForegroundColor Green
    Write-Host
    Write-Host " Select an option to download and run:" -ForegroundColor Cyan
    Write-Host "   [1] Earth 2150 Multiplayer Setup (TMP Only)"
    Write-Host "   [2] Earth 2150 Levels Downloader"
    Write-Host "   [3] Earth 2150 Media Converter"
    Write-Host "   [4] Exit"
    Write-Host

    $choice = Read-Host "Enter option (1-4)"

    $scriptName  = $null
    $apiPath     = $null
    $downloadUrl = $null

    switch ($choice) {
        "1" {
            $scriptName  = "Earth2150-MP-Setup.ps1"
            $apiPath     = "Tools/mp-setup/Earth2150-MP-Setup.ps1"
            $downloadUrl = "https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/mp-setup/Earth2150-MP-Setup.ps1"
        }
        "2" {
            $scriptName  = "IE-Earth2150-Level-Downloader.ps1"
            $apiPath     = "Tools/downloaders/IE-Earth2150-Level-Downloader.ps1"
            $downloadUrl = "https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/downloaders/IE-Earth2150-Level-Downloader.ps1"
        }
        "3" {
            $scriptName  = "tmp-ls-media-converter-Launcher.ps1"
            $apiPath     = "Tools/convertors/tmp-ls-media-converter-Launcher.ps1"
            $downloadUrl = "https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/convertors/tmp-ls-media-converter-Launcher.ps1"
        }
        "4" {
            Write-Host "`nExiting..." -ForegroundColor Yellow
            exit 0
        }
        default {
            Write-Host "Invalid selection. Press Enter to try again..." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }
    }

    # 1. Target Paths in TEMP & Hash Setup
    $targetScriptPath = Join-Path $env:TEMP $scriptName
    $hashFileName     = "$([System.IO.Path]::GetFileNameWithoutExtension($scriptName)).sha"
    $hashPath         = Join-Path $env:TEMP $hashFileName
    $apiUrl           = "https://api.github.com/repos/InsideEarth2150/Files/commits?path=$apiPath&page=1&per_page=1"

    $needsDownload = $true

    # 2. SHA Comparison & Conditional Download
    if ((Test-Path $targetScriptPath) -and (Test-Path $hashPath)) {
        try {
            $remoteHash = (Invoke-RestMethod -Uri $apiUrl -UseBasicParsing)[0].sha
            $localHash  = (Get-Content $hashPath -Raw).Trim()

            if ($remoteHash.Trim() -eq $localHash) {
                $needsDownload = $false
            }
        } catch {
            # Default to running existing file if API rate limit or network check fails
            $needsDownload = $false
        }
    }

    if ($needsDownload) {
        Write-Host
        Write-Host "Downloading latest version of $scriptName to TEMP..." -ForegroundColor Cyan
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $downloadUrl -OutFile $targetScriptPath -UseBasicParsing
            
            try {
                $latestHash = (Invoke-RestMethod -Uri $apiUrl -UseBasicParsing)[0].sha
                Set-Content -Path $hashPath -Value $latestHash -Force
            } catch {}

            Write-Host "Download complete: $targetScriptPath" -ForegroundColor Green
        } catch {
            Write-Host "Failed to download the script from GitHub: $_" -ForegroundColor Red
            Start-Sleep -Seconds 3
            continue
        }
    } else {
        Write-Host
        Write-Host "$scriptName in TEMP is up to date." -ForegroundColor Green
    }

    # 3. Execute Downloaded Tool Script from TEMP
    Write-Host "Starting $scriptName..." -ForegroundColor Cyan
    Write-Host

    Set-Location -Path $env:TEMP
    & $targetScriptPath

    # Reset location and prompt before looping back to main menu
    Set-Location -Path $PSScriptRoot
    Write-Host
    Read-Host "Process completed. Press Enter to return to main menu..."
}