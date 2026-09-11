# =====================================================================
#    InsideEARTH - Earth 2150 TMP/LS Converter Launcher
# =====================================================================

# Always default to current working directory where the script was invoked from
$scriptDir = (Get-Location).Path

# 1. Validate Game Root Directory
$validExe1 = Join-Path $scriptDir "TheMoonProject.exe"
$validExe2 = Join-Path $scriptDir "LostSouls.exe"

if (-not (Test-Path $validExe1) -and -not (Test-Path $validExe2)) {
    Write-Host "Error: Neither 'TheMoonProject.exe' nor 'LostSouls.exe' was found in this folder." -ForegroundColor Red
    Write-Host "Current checked folder: $scriptDir" -ForegroundColor Yellow
    Write-Host "Please run this script or batch file directly from the game root directory." -ForegroundColor Red
    Write-Host
    Read-Host "Press Enter to exit..."
    exit 1
}

# 2. Main Loop
do {
    # Ensure working location is reset to root at the start of every loop
    Set-Location -Path $scriptDir
    Clear-Host

    Write-Host " ===================================================" -ForegroundColor Green
    Write-Host "    InsideEARTH - Earth 2150 TMP/LS Media Converter" -ForegroundColor Green
    Write-Host " ===================================================" -ForegroundColor Green
    Write-Host
    Write-Host " Select conversion mode:" -ForegroundColor Cyan
    Write-Host "   [1] Audio Conversion (.mp2)"
    Write-Host "   [2] Video Conversion (.wd1)"
    Write-Host "   [3] Exit"
    Write-Host

    $choice = Read-Host "Enter option (1-3)"

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
            Write-Host "Exiting." -ForegroundColor Yellow
            exit 0
        }
        default {
            Write-Host "Invalid selection. Press Enter to try again..." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }
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

    # Reset location and prompt before looping back
    Set-Location -Path $scriptDir
    Write-Host
    Read-Host "Process completed. Press Enter to return to main menu..."

} while ($true)