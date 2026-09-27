# =====================================================================
#   InsideEARTH - Earth 2150 Levels Downloader v1.1
# =====================================================================

# Requires -Version 5.1

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Self-elevation check
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

clear

$host.ui.RawUI.WindowTitle = "InsideEARTH - Earth 2150 Levels Downloader"

$ErrorActionPreference = 'Stop'

# The PS 5.1 progress bar is the main cause of slow Invoke-WebRequest / Expand-Archive.
$ProgressPreference = 'SilentlyContinue'

# Define supported games/variants and their registry paths
$games = @(
    @{
        Name     = 'Earth 2150'
        RegPath  = 'HKCU:\Software\Topware\Earth 2150\BaseGame\FileSystem'
        RegValue = "datapath"
    },
    @{
        Name     = 'The Moon Project'
        RegPath  = 'HKCU:\Software\Topware\TheMoonProject\BaseGame\FileSystem'
        RegValue = "datapath"
    },
    @{
        Name     = 'Lost Souls'
        RegPath  = 'HKCU:\Software\Reality Pump\LostSouls\BaseGame\FileSystem'
        RegValue = "datapath"
    }
)

$downloadUrl = "https://github.com/InsideEarth2150/Levels/archive/refs/heads/main.zip"
$galleryUrl  = 'https://insideearth2150.github.io/Levels-Gallery/'

# Files to remove from the Levels directory after extraction
$filesToClean = @('.gitignore', 'index.html', 'README.MD', 'style.css')

# Main loop to return to menu after any selection except Exit
while ($true) {
    Clear-Host

    Write-Host "===================================================" -ForegroundColor Green
    Write-Host "  InsideEARTH - Earth 2150 Levels Downloader v1.1" -ForegroundColor Green
    Write-Host "===================================================" -ForegroundColor Green
    Write-Host

    $tempZipPath = Join-Path $env:TEMP "IE2150_Levels_$(Get-Random).zip"
    $tempExtractPath = Join-Path $env:TEMP "IE2150_Levels_Extract_$(Get-Random)"

    try {
        Write-Host "Detecting installed Earth 2150 install(s)..." -ForegroundColor Cyan
        $installedGames = @()

        foreach ($game in $games) {
            if (Test-Path $game.RegPath) {
                $rawPath = (Get-ItemProperty -Path $game.RegPath -Name $game.RegValue -ErrorAction SilentlyContinue).$($game.RegValue)

                if ($rawPath) {
                    $cleanPath = $rawPath -replace '[^\x20-\x7E]', ''
                    $cleanPath = $cleanPath -replace '[><|?"*]', ''
                    $cleanPath = $cleanPath.Trim().Trim('"').Trim("'").TrimEnd('\', '/')

                    if (-not [string]::IsNullOrWhiteSpace($cleanPath) -and (Test-Path -Path $cleanPath)) {
                        $installedGames += [PSCustomObject]@{
                            Name     = $game.Name
                            RootPath = $cleanPath
                        }
                    }
                }
            }
        }

        if ($installedGames.Count -eq 0) {
            Write-Warning "No installed Earth 2150 games were found in the registry."
            Write-Host "Run Registry Tools first to set the install path, then try again." -ForegroundColor Yellow
            Read-Host "`nPress Enter to exit..."
            break
        }

        Write-Host "`nFound the following installed games:" -ForegroundColor Green
        for ($i = 0; $i -lt $installedGames.Count; $i++) {
            Write-Host " [$($i + 1)] $($installedGames[$i].Name)"
        }
        $exitOptionIndex = $installedGames.Count + 1
        Write-Host ""
        Write-Host " [$exitOptionIndex] Exit" -ForegroundColor Red

        $selection = 0
        while ($selection -lt 1 -or $selection -gt $exitOptionIndex) {
            $inputVal = Read-Host "`nSelect a game (1-$exitOptionIndex)"
            [int]::TryParse($inputVal, [ref]$selection) | Out-Null
        }

        if ($selection -eq $exitOptionIndex) {
            Write-Host "`nExiting..." -ForegroundColor Yellow
            break
        }

        $target = $installedGames[$selection - 1]
        $levelsDir = Join-Path $target.RootPath "Levels"

        Write-Host "`nDownloading levels archive from GitHub..." -ForegroundColor Cyan
        Write-Host "  (Gallery: $galleryUrl)" -ForegroundColor DarkGray
        $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
        if ($curl) {
            # curl.exe ships with Windows 10 1803+ and has its own fast progress meter
            & $curl.Source -L --fail --retry 3 --progress-bar -o $tempZipPath $downloadUrl
            if ($LASTEXITCODE -ne 0) { throw "curl.exe download failed (exit code $LASTEXITCODE)." }
        } else {
            # Fallback: WebClient is fast and has no progress-bar overhead
            (New-Object Net.WebClient).DownloadFile($downloadUrl, $tempZipPath)
        }

        Write-Host "Extracting..." -ForegroundColor Cyan
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory($tempZipPath, $tempExtractPath)

        $innerFolder = Get-ChildItem -Path $tempExtractPath -Directory | Select-Object -First 1
        if (-not $innerFolder) { throw "Unexpected archive layout." }

        if (-not (Test-Path $levelsDir)) { New-Item -ItemType Directory -Path $levelsDir -Force | Out-Null }
        Copy-Item -Path (Join-Path $innerFolder.FullName '*') -Destination $levelsDir -Recurse -Force

        foreach ($f in $filesToClean) {
            $p = Join-Path $levelsDir $f
            if (Test-Path $p) { Remove-Item -Path $p -Force -ErrorAction SilentlyContinue }
        }

        Write-Host "`nLevels installed to: $levelsDir" -ForegroundColor Green
    } catch {
        Write-Host "`n[!] Failed: $_" -ForegroundColor Red
    } finally {
        Remove-Item -Path $tempZipPath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $tempExtractPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host
    Read-Host "Process completed. Press Enter to return to menu..."
}
