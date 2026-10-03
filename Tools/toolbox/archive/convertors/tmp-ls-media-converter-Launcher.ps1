# =====================================================================
#   InsideEARTH - Earth 2150 Media Converter Launcher v1.3
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

Clear-Host

$host.ui.RawUI.WindowTitle = "Earth 2150 Media Converter Launcher v1.1"

$ErrorActionPreference = 'Stop'

# GitHub locations for the converter scripts
$RawBase = "https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/"
$ApiRepo = "https://api.github.com/repos/InsideEarth2150/Files/commits"

# Define supported games.
#   RegSub      = registry key below \Software (or \Software\WOW6432Node) that holds the game settings
#   AudioScript = audio converter script used for THIS game
#   VideoScript = video converter script used for this game ($null = not available)
$games = @(
    @{
        Name        = "Earth 2150: Escape from the Blue Planet (DO NOT USE)"
        RegSub      = "Topware\Earth 2150"
        ExeName     = "Earth2150.exe"
        AudioScript = "eftbp-music_convert.ps1"
        VideoScript = $null
    },
    @{
        Name        = "Earth 2150: The Moon Project"
        RegSub      = "Topware\TheMoonProject"
        ExeName     = "TheMoonProject.exe"
        AudioScript = "tmp-music_convert.ps1"
        VideoScript = "tmp-ls-video_convert.ps1"
    },
    @{
        Name        = "Earth 2150: Lost Souls"
        RegSub      = "Reality Pump\LostSouls"
        ExeName     = "LostSouls.exe"
        AudioScript = "ls-music_convert.ps1"
        VideoScript = "tmp-ls-video_convert.ps1"
    }
)

$regRoots = @('HKCU:\Software', 'HKLM:\Software\WOW6432Node', 'HKLM:\Software')

# Main loop for game selection and execution
while ($true) {
    Clear-Host

    Write-Host " ===================================================" -ForegroundColor Green
    Write-Host "   InsideEARTH - Earth 2150 TMP/LS Media Converter" -ForegroundColor Green
    Write-Host " ===================================================" -ForegroundColor Green
    Write-Host

    # 1. Detect installed games via registry (HKCU + HKLM, OutputDir + datapath)
    Write-Host "Detecting installed Earth 2150 games via registry..." -ForegroundColor Cyan
    $installedGames = @()

    foreach ($game in $games) {
        $found = $null
        foreach ($root in $regRoots) {
            $key = "$root\$($game.RegSub)\BaseGame\FileSystem"
            if (-not (Test-Path -LiteralPath $key)) { continue }
            $props = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue

            foreach ($rawPath in @($props.OutputDir, $props.datapath)) {
                if (-not $rawPath) { continue }
                # Strip null bytes, invalid characters (incl. the trailing "/>"), quotes, and trailing slashes
                $cleanPath = ([string]$rawPath) -replace '[^\x20-\x7E]', ''
                $cleanPath = $cleanPath -replace '[><|?"*]', ''
                $cleanPath = $cleanPath.Trim().Trim('"').Trim("'").TrimEnd('\', '/')

                if (-not [string]::IsNullOrWhiteSpace($cleanPath) -and (Test-Path -LiteralPath $cleanPath -PathType Container)) {
                    $found = $cleanPath
                    break
                }
            }
            if ($found) { break }
        }

        if ($found) {
            $installedGames += [PSCustomObject]@{
                Name        = $game.Name
                RootPath    = $found
                ExeName     = $game.ExeName
                AudioScript = $game.AudioScript
                VideoScript = $game.VideoScript
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
        $fullName = $installedGames[$i].Name

        # Check if the game name contains the warning string
        if ($fullName -like "*(DO NOT USE)*") {
            # Split the string right before "(DO NOT USE)"
            $baseName = $fullName -replace '\s*\(DO NOT USE\)', ''

            Write-Host " [$($i + 1)] " -NoNewline
            Write-Host "$baseName " -NoNewline
            Write-Host "(DO NOT USE)" -ForegroundColor Red
        } else {
            Write-Host " [$($i + 1)] $fullName"
        }
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

        # Reset per-iteration state so nothing stale carries over
        $proceed     = $false
        $subFolder   = $null
        $scriptName  = $null
        $apiPath     = $null
        $downloadUrl = $null

        switch ($choice) {
            "1" {
                # Audio script depends on the selected game
                $subFolder   = "Music"
                $scriptName  = $targetGame.AudioScript
                $apiPath     = "Tools/convertors/audio/$scriptName"
                $downloadUrl = "$RawBase/$apiPath"
                $proceed     = $true
            }
            "2" {
                if (-not $targetGame.VideoScript) {
                    Write-Host "Video conversion is not available for this game." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                } else {
                    $subFolder   = "Video"
                    $scriptName  = $targetGame.VideoScript
                    $apiPath     = "Tools/convertors/video/$scriptName"
                    $downloadUrl = "$RawBase/$apiPath"
                    $proceed     = $true
                }
            }
            "3" {
                $backToGameMenu = $true
            }
            "4" {
                Write-Host "Exiting." -ForegroundColor Yellow
                exit 0
            }
            default {
                Write-Host "Invalid selection. Please try again..." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }

        if ($backToGameMenu) { break }
        if (-not $proceed)   { continue }

        # 3. Target Folder Verification & Hash Setup
        $targetDir = Join-Path $scriptDir $subFolder
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir | Out-Null
        }

        $targetScriptPath = Join-Path $targetDir $scriptName
        $hashFileName     = "$([System.IO.Path]::GetFileNameWithoutExtension($scriptName)).sha"
        $hashPath         = Join-Path $env:TEMP $hashFileName
        $apiUrl           = "${ApiRepo}?path=$apiPath&page=1&per_page=1"

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
            Write-Host "Downloading latest $subFolder script ($scriptName) from GitHub..." -ForegroundColor Cyan
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
            Write-Host "$subFolder script ($scriptName) is up to date." -ForegroundColor Green
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