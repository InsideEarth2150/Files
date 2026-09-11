# =====================================================================
#    InsideEARTH - Earth 2150 TMP/LS Converter Launcher
# =====================================================================

$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
if (-not $scriptDir) { 
    $scriptDir = Get-Location 
}

# 1. Validate Game Root Directory
$validExe1 = Join-Path $scriptDir "TheMoonProject.exe"
$validExe2 = Join-Path $scriptDir "LostSouls.exe"

if (-not (Test-Path $validExe1) -and -not (Test-Path $validExe2)) {
    Write-Host "Error: Neither 'TheMoonProject.exe' nor 'LostSouls.exe' was found in this folder." -ForegroundColor Red
    Write-Host "Current checked path: $scriptDir" -ForegroundColor Yellow
    Write-Host "Please place and run this script from the game root directory." -ForegroundColor Red
    Write-Host
    Read-Host "Press Enter to exit..."
    exit 1
}

# 2. Main Menu Interface
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
        $downloadUrl = "https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/convertors/audio/tmp-ls-music_convert.ps1"
    }
    "2" {
        $subFolder = "Video"
        $scriptName = "tmp-ls-video_convert.ps1"
        $downloadUrl = "https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/Tools/convertors/video/tmp-ls-video_convert.ps1"
    }
    "3" {
        Write-Host "Exiting." -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host "Invalid selection. Exiting." -ForegroundColor Red
        exit 1
    }
}

# 3. Target Folder Verification & Script Download
$targetDir = Join-Path $scriptDir $subFolder
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

$targetScriptPath = Join-Path $targetDir $scriptName

Write-Host
Write-Host "Downloading latest $subFolder script from GitHub..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $targetScriptPath -UseBasicParsing
    Write-Host "Download complete: $targetScriptPath" -ForegroundColor Green
} catch {
    Write-Host "Failed to download the script from GitHub: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

# 4. Execute Downloaded Converter Script and Pass Game Root Path
Write-Host "Starting $subFolder conversion process..." -ForegroundColor Cyan
Write-Host

& $targetScriptPath -GameRoot $scriptDir

Write-Host
Read-Host "Press Enter to exit..."