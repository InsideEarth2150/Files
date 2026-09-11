# =====================================================================
#   InsideEARTH - Earth 2150 TMP/LS Video Convertor
# =====================================================================

# Display Banner First
Write-Host 
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   InsideEARTH - Earth 2150 TMP/LS Video Convertor" -ForegroundColor Green
Write-Host " ===================================================" -ForegroundColor Green
Write-Host

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Get-Location }
$ffmpegPath = Join-Path $scriptDir "ffmpeg.exe"
$sevenZipExe = Join-Path $scriptDir "7za.exe"

# ---------- 1) Dynamic 7-Zip CLI Downloader Setup -----------------
Write-Host 
Write-Host "[1/3] 7-Zip Prerequisite..." -ForegroundColor Cyan
if (-not (Test-Path $sevenZipExe)) {
    Write-Host "7-Zip CLI not found. Downloading standalone 7za.exe..." -ForegroundColor Yellow
    $7zUrl = "https://www.7-zip.org/a/7za920.zip"
    $7zZipPath = Join-Path $scriptDir "7za.zip"
    $7zExtractPath = Join-Path $scriptDir "7z_temp"

    Invoke-WebRequest -Uri $7zUrl -OutFile $7zZipPath
    Expand-Archive -Path $7zZipPath -DestinationPath $7zExtractPath -Force
    
    $extracted7z = Get-ChildItem -Path $7zExtractPath -Filter "7za.exe" -Recurse | Select-Object -First 1
    if ($extracted7z) {
        Copy-Item -Path $extracted7z.FullName -Destination $scriptDir -Force
        Write-Host "7-Zip CLI successfully installed!" -ForegroundColor Green
    } else {
        Write-Host "Error: Could not extract 7-Zip CLI tool." -ForegroundColor Red
        exit 1
    }

    Remove-Item -Path $7zZipPath -Force
    Remove-Item -Path $7zExtractPath -Recurse -Force
} else {
    Write-Host "7za.exe found locally." -ForegroundColor Green
}

# ---------- 2) Automatic FFmpeg Downloader & Installer -----------------
Write-Host 
Write-Host "[2/3] FFmpeg Prerequisite..." -ForegroundColor Cyan
if (-not (Test-Path $ffmpegPath)) {
    Write-Host "ffmpeg.exe not found. Downloading FFmpeg Essentials (.7z)..." -ForegroundColor Yellow
    $7zUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-essentials.7z"
    $7zPath = Join-Path $scriptDir "ffmpeg.7z"
    $extractPath = Join-Path $scriptDir "ffmpeg_temp"

    Invoke-WebRequest -Uri $7zUrl -OutFile $7zPath
    
    Write-Host "Extracting FFmpeg with 7-Zip..." -ForegroundColor Yellow
    & $sevenZipExe x $7zPath "-o$extractPath" -y | Out-Null
    
    $ffmpegBin = Get-ChildItem -Path $extractPath -Filter "ffmpeg.exe" -Recurse | Select-Object -First 1
    if ($ffmpegBin) {
        Copy-Item -Path $ffmpegBin.FullName -Destination $scriptDir -Force
        Write-Host "FFmpeg successfully installed to current folder!" -ForegroundColor Green
    } else {
        Write-Host "Error: Could not find ffmpeg.exe inside .7z archive." -ForegroundColor Red
        exit 1
    }

    Remove-Item -Path $7zPath -Force
    Remove-Item -Path $extractPath -Recurse -Force
} else {
    Write-Host "ffmpeg.exe found locally." -ForegroundColor Green
}

# ---------- 3) Parallel Video Conversion -----------------
Write-Host 
Write-Host "[3/3] Running Parallel Video Conversion..." -ForegroundColor Cyan

# Setup "Original" directory
$originalDir = Join-Path $scriptDir "Original"
if (-not (Test-Path $originalDir)) {
    New-Item -ItemType Directory -Path $originalDir | Out-Null
}

# Parallel Video Conversion Logic (.wd1 files)
$MaxJobs = [Environment]::ProcessorCount
$files = Get-ChildItem -Path (Join-Path $scriptDir "*") -Include *.wd1, *.WD1 -File

if ($files.Count -eq 0) {
    Write-Host "No .wd1 files found to convert." -ForegroundColor Yellow
    exit
}

Write-Host "Found $($files.Count) .wd1 files. Starting parallel video conversion..." -ForegroundColor Cyan

foreach ($file in $files) {
    while ((Get-Job -State Running).Count -ge $MaxJobs) {
        Start-Sleep -Milliseconds 200
    }

    Start-Job -ScriptBlock {
        param($filePath, $ffmpegExe, $backupFolder)
        $file = Get-Item $filePath
        $baseName = $file.BaseName
        $fixedFile = Join-Path $file.DirectoryName "${baseName}_fixed.avi"

        # Re-encode video using Cinepak + PCM audio format (output redirected to $null)
        & $ffmpegExe -i $file.FullName -c:v cinepak -pix_fmt rgb24 -c:a pcm_s16le -f avi -y $fixedFile *>$null

        if ($LASTEXITCODE -eq 0 -and (Test-Path $fixedFile)) {
            # Move original .wd1 file into the "Original" folder
            Move-Item -Path $file.FullName -Destination (Join-Path $backupFolder $file.Name) -Force
            # Rename output .avi file back to original filename
            Rename-Item -Path $fixedFile -NewName $file.Name -Force

            return "SUCCESS: $($file.Name)"
        } else {
            return "FAILED: $($file.Name)"
        }
    } -ArgumentList $file.FullName, $ffmpegPath, $originalDir | Out-Null
}

# Monitor jobs and print status directly to console
while (Get-Job -State Running) {
    $completedJobs = Get-Job -State Completed
    foreach ($job in $completedJobs) {
        $result = Receive-Job -Job $job
        if ($result -like "SUCCESS*") {
            Write-Host $result -ForegroundColor Green
        } else {
            Write-Host $result -ForegroundColor Red
        }
        Remove-Job -Job $job
    }
    Start-Sleep -Milliseconds 500
}

Get-Job | Receive-Job | Out-Null
Get-Job | Remove-Job

Write-Host 
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   All Video Conversions Completed!" -ForegroundColor Green
Write-Host "   Original files moved to the subfolder 'Original'" -ForegroundColor Green
Write-Host " ===================================================" -ForegroundColor Green
Write-Host

Start-Sleep -Seconds 2