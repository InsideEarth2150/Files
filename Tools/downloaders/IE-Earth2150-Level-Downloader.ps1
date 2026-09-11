# =====================================================================
#   InsideEARTH - Earth 2150 Levels Downloader
# =====================================================================

# Requires -Version 5.1

clear

# Display Banner First
Write-Host 
Write-Host "===================================================" -ForegroundColor Green
Write-Host "    InsideEARTH - Earth 2150 Levels Downloader" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host

$ErrorActionPreference = 'Stop'

# Define supported games and their registry paths
$games = @(
    @{
        Name     = "Earth 2150: Escape from the Blue Planet"
        RegPath  = "HKCU:\Software\Topware\Earth 2150\BaseGame\FileSystem"
        RegValue = "datapath"
    },
    @{
        Name     = "Earth 2150: The Moon Project"
        RegPath  = "HKCU:\Software\Topware\TheMoonProject\BaseGame\FileSystem"
        RegValue = "datapath"
    },
    @{
        Name     = "Earth 2150: Lost Souls"
        RegPath  = "HKCU:\Software\Reality Pump\LostSouls\BaseGame\FileSystem"
        RegValue = "datapath"
    }
)

$downloadUrl = "https://github.com/InsideEarth2150/Levels/archive/refs/heads/main.zip"
$tempZipPath = Join-Path $env:TEMP "Earth2150_Levels_$(Get-Random).zip"
$tempExtractPath = Join-Path $env:TEMP "Earth2150_Levels_Extract_$(Get-Random)"

# Files to remove from the Levels directory after extraction
$filesToClean = @('.gitignore', 'index.html', 'README.MD', 'style.css')

try {
    # 1. Detect installed games
    Write-Host "Detecting installed Earth 2150 games..." -ForegroundColor Cyan
    $installedGames = @()

    foreach ($game in $games) {
        if (Test-Path $game.RegPath) {
            $rawPath = (Get-ItemProperty -Path $game.RegPath -Name $game.RegValue -ErrorAction SilentlyContinue).$($game.RegValue)
            
            if ($rawPath) {
                # Strip null bytes, invalid characters (like '>'), quotes, and trailing slashes
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
        return
    }

    # Prompt user to select a game without displaying file paths
    Write-Host "`nFound the following installed games:" -ForegroundColor Green
    for ($i = 0; $i -lt $installedGames.Count; $i++) {
        Write-Host " [$($i + 1)] $($installedGames[$i].Name)"
    }

    $selection = 0
    if ($installedGames.Count -eq 1) {
        $selectedIndex = 0
        Write-Host "`nAuto-selected: $($installedGames[0].Name)" -ForegroundColor Yellow
    } else {
        while ($selection -lt 1 -or $selection -gt $installedGames.Count) {
            $inputVal = Read-Host "`nSelect a game to install levels into (1-$($installedGames.Count))"
            [int]::TryParse($inputVal, [ref]$selection) | Out-Null
        }
        $selectedIndex = $selection - 1
    }

    $targetGame = $installedGames[$selectedIndex]
    $targetLevelsFolder = Join-Path $targetGame.RootPath "Levels"

    # 2. Download latest level files
    Write-Host "`nDownloading latest level files from GitHub..." -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZipPath

    # Extract ZIP to temporary folder
    Write-Host "Extracting archive..." -ForegroundColor Cyan
    Expand-Archive -Path $tempZipPath -DestinationPath $tempExtractPath -Force

    # Locate extracted contents
    $extractedRoot = Get-ChildItem -Path $tempExtractPath | Select-Object -First 1
    $sourcePath = if ($extractedRoot.PSIsContainer) { $extractedRoot.FullName } else { $tempExtractPath }

    # Copy files into target "Levels" directory
    Write-Host "Installing levels into $($targetGame.Name)..." -ForegroundColor Cyan
    if (-not (Test-Path $targetLevelsFolder)) {
        New-Item -ItemType Directory -Path $targetLevelsFolder | Out-Null
    }

    Get-ChildItem -Path $sourcePath | Copy-Item -Destination $targetLevelsFolder -Recurse -Force

    # Clean up non-level repository files from target folder
    Write-Host "Cleaning up repository metadata files (.gitignore, web files, README)..." -ForegroundColor Cyan
    foreach ($file in $filesToClean) {
        $filePath = Join-Path $targetLevelsFolder $file
        if (Test-Path $filePath) {
            Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host "`nSuccessfully installed levels into $($targetGame.Name)!" -ForegroundColor Green

}
catch {
    Write-Error "An error occurred during execution: $_"
}
finally {
    # 3. Cleanup temporary files
    Write-Host "`nCleaning up temporary files..." -ForegroundColor Cyan
    if (Test-Path $tempZipPath) {
        Remove-Item -Path $tempZipPath -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path $tempExtractPath) {
        Remove-Item -Path $tempExtractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Cleanup complete." -ForegroundColor Green
}