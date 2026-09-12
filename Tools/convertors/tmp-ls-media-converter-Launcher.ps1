# =====================================================================
#    InsideEARTH - Earth 2150 TMP/LS Converter Launcher
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

$ErrorActionPreference = 'Stop'

# Define supported games and their registry paths
$games = @(
    @{
        Name     = "Earth 2150: Escape from the Blue Planet (DO NOT USE)"
        RegPath  = "HKCU:\Software\Topware\Earth 2150\BaseGame\FileSystem"
        RegValue = "datapath"
        ExeName  = "Earth2150.exe"
    },
    @{
        Name     = "Earth 2150: The Moon Project"
        RegPath  = "HKCU:\Software\Topware\TheMoonProject\BaseGame\FileSystem"
        RegValue = "datapath"
        ExeName  = "TheMoonProject.exe"
    },
    @{
        Name     = "Earth 2150: Lost Souls"
        RegPath  = "HKCU:\Software\Reality Pump\LostSouls\BaseGame\FileSystem"
        RegValue = "datapath"
        ExeName  = "LostSouls.exe"
    }
)

# Main loop for game selection and execution
while ($true) {
    Clear-Host

    Write-Host " ===================================================" -ForegroundColor Green
    Write-Host "   InsideEARTH - Earth 2150 TMP/LS Media Converter" -ForegroundColor Green
    Write-Host " ===================================================" -ForegroundColor Green
    Write-Host

    # 1. Detect installed games via registry
    Write-Host "Detecting installed Earth 2150 games via registry..." -ForegroundColor Cyan
    $installedGames = @()

    foreach ($game in $games) {
        if (Test-Path $game.RegPath) {
            $rawPath = (Get-ItemProperty -Path $game.RegPath -Name $game.RegValue -ErrorAction SilentlyContinue).$($game.RegValue)
            
            if ($rawPath) {
                # Strip null bytes, invalid characters, quotes, and trailing slashes
                $cleanPath = $rawPath -replace '[^\x20-\x7E]', ''
                $cleanPath = $cleanPath -replace '[><|?"*]', ''
                $cleanPath = $cleanPath.Trim().Trim('"').Trim("'").TrimEnd('\', '/')

                if (-not [string]::IsNullOrWhiteSpace($cleanPath) -and (Test-Path -Path $cleanPath)) {
                    $installedGames += [PSCustomObject]@{
                        Name     = $game.Name
                        RootPath = $cleanPath
                        ExeName  = $game.ExeName
                    }
                }
            }
        }
    }

    if ($installedGames.Count -eq 0) {
        Write-Warning "No installed Earth 2150 games were found in the registry."
        Write-Host "Please ensure the game is installed and has been launched at least once." -ForegroundColor Yellow
        Read-Host "`nPress Enter to exit..."
        break
    }

    # Prompt user to select a detected game
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

    # Handle Exit
    if ($selection -eq $exitOptionIndex) {
        Write-Host "`nExiting..." -ForegroundColor Yellow
        break
    }

    # Set active game directory based on selection
    $selectedIndex = $selection - 1
    $targetGame = $installedGames[$selectedIndex]
    $scriptDir = $targetGame.RootPath

    # 2. Converter Menu Loop for Selected Game
    $backToGameMenu = $false
    do {
        Set-Location -Path $scriptDir
        Clear-Host

        Write-Host " ===================================================" -ForegroundColor Green
        Write-Host "   InsideEARTH - Earth 2150 Media Converter" -ForegroundColor Green
        Write-Host " ===================================================" -ForegroundColor Green
        Write-Host " Target Game: $($targetGame.Name)" -ForegroundColor Yellow
        Write-Host " Directory:   $scriptDir" -ForegroundColor DarkGray
        Write-Host
        Write-Host " Select conversion mode:" -ForegroundColor Cyan
        Write-Host "    [1] Audio Conversion (.mp2)"
        Write-Host "    [2] Video Conversion (.wd1)"
        Write-Host "    [3] Back to Game Selection"
        Write-Host "    [4] Exit"
        Write-Host

        $choice = Read-Host "Enter option (1-4)"

        switch ($choice) {
            "1" {
                $subFolder = "Music"
                $scriptName = "tmp-ls-music_convert.ps1"
                $apiPath    = "Tools/convertors/audio/tmp-ls-music_convert.ps1"
                $downloadUrl = "https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/convertors/audio/tmp-ls-music_convert.ps1"
            }
            "2" {
                $subFolder = "Video"
                $scriptName = "tmp-ls-video_convert.ps1"
                $apiPath    = "Tools/convertors/video/tmp-ls-video_convert.ps1"
                $downloadUrl = "https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/convertors/video/tmp-ls-video_convert.ps1"
            }
            "3" {
                $backToGameMenu = $true
                break
            }
            "4" {
                Write-Host "Exiting." -ForegroundColor Yellow
                exit 0
            }
            default {
                Write-Host "Invalid selection. Press Enter to try again..." -ForegroundColor Red
                Start-Sleep -Seconds 2
                continue
            }
        }

        if ($backToGameMenu) {
            break
        }

        # 3. Target Folder Verification & Hash Setup
        $targetDir = Join-Path $scriptDir $subFolder
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir | Out-Null
        }

        $targetScriptPath = Join-Path $targetDir $scriptName
        $hashFileName     = "$([System.IO.Path]::GetFileNameWithoutExtension($scriptName)).sha"
        $hashPath         = Join-Path $env:TEMP $hashFileName
        $apiUrl           = "https://api.github.com/repos/InsideEarth2150/Files/commits?path=$apiPath&page=1&per_page=1"

        $needsDownload = $true

        # 4. SHA Comparison & Conditional Download
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
            Write-Host "Downloading latest $subFolder script from GitHub..." -ForegroundColor Cyan
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
            Write-Host "$subFolder script is up to date." -ForegroundColor Green
        }

        # 5. Execute Downloaded Converter Script inside Subfolder
        Write-Host "Starting $subFolder conversion process..." -ForegroundColor Cyan
        Write-Host

        Set-Location -Path $targetDir
        & $targetScriptPath

        # 6. Cleanup unused files, binaries, and logs after execution
        Write-Host
        Write-Host "Cleaning up temporary files, binaries, and logs..." -ForegroundColor Cyan

        # Remove the downloaded converter script
        if (Test-Path $targetScriptPath) {
            Remove-Item -Path $targetScriptPath -Force -ErrorAction SilentlyContinue
        }

        # Remove helper tools and logs (7za.exe, ffmpeg.exe, convert_log.txt) if left in the target directory
        $filesToClean = @("7za.exe", "ffmpeg.exe", "convert_log.txt")
        foreach ($file in $filesToClean) {
            $filePath = Join-Path $targetDir $file
            if (Test-Path $filePath) {
                Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
            }
        }

        # Remove any other log files left in the target directory
        Get-ChildItem -Path $targetDir -Filter "*.log" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

        # Reset location and prompt before looping back
        Set-Location -Path $scriptDir
        Write-Host
        Read-Host "Process completed. Press Enter to return to converter menu..."

    } while (-not $backToGameMenu)
}