# =====================================================================
#   InsideEARTH - Earth 2150 Audio Convertor v1.0
# =====================================================================

clear

$host.ui.RawUI.WindowTitle = "InsideEARTH - Earth 2150 Video Convertor"

# Display Banner First
Write-Host 
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   InsideEARTH - Earth 2150 Audio Convertor v1.0" -ForegroundColor Green
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

# ---------- 3) Parallel Audio Conversion -----------------
Write-Host 
Write-Host "[3/3] Running Parallel Video Conversion..." -ForegroundColor Cyan

# Clean old log
$mainLog = Join-Path $scriptDir "convert_log.txt"
if (Test-Path $mainLog) { Remove-Item $mainLog -Force }

# 3. Setup Directories
$originalDir = Join-Path $scriptDir "Original"
if (-not (Test-Path $originalDir)) {
    New-Item -ItemType Directory -Path $originalDir | Out-Null
}

# 4. Parallel Audio Conversion Logic
$MaxJobs = [Environment]::ProcessorCount
$files = Get-ChildItem -Path (Join-Path $scriptDir "*") -Include *.mp2, *.MP2 -File

if ($files.Count -eq 0) {
    Write-Host "No .mp2 files found to convert." -ForegroundColor Yellow
    exit
}

Write-Host "Found $($files.Count) .mp2 files. Starting parallel audio conversion..." -ForegroundColor Cyan

foreach ($file in $files) {
    while ((Get-Job -State Running).Count -ge $MaxJobs) {
        Start-Sleep -Milliseconds 200
    }

    Start-Job -ScriptBlock {
        param($filePath, $ffmpegExe, $backupFolder)
        $file = Get-Item $filePath
        $baseName = $file.BaseName
        $fixedFile = Join-Path $file.DirectoryName "${baseName}_fixed.mp2"
        $jobLog = Join-Path $file.DirectoryName "temp_log_$baseName.txt"

        "[$(Get-Date)] Starting processing on $($file.Name)" | Out-File -FilePath $jobLog -Encoding utf8

        # Re-encode audio to MP2 192k
        & $ffmpegExe -i $file.FullName -c:a mp2 -b:a 192k -y $fixedFile *>> $jobLog

        if ($LASTEXITCODE -eq 0 -and (Test-Path $fixedFile)) {
            # Move original file to 'Original' folder
            Move-Item -Path $file.FullName -Destination (Join-Path $backupFolder $file.Name) -Force
            # Rename output file to match original filename
            Rename-Item -Path $fixedFile -NewName $file.Name -Force
            
            "[$(Get-Date)] OK: $($file.Name)" | Out-File -FilePath $jobLog -Append -Encoding utf8
            return "SUCCESS: $($file.Name)"
        } else {
            "[$(Get-Date)] FAILED: $($file.Name)" | Out-File -FilePath $jobLog -Append -Encoding utf8
            return "FAILED: $($file.Name)"
        }
    } -ArgumentList $file.FullName, $ffmpegPath, $originalDir | Out-Null
}

# Monitor jobs and print output as they finish
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

# Combine all temp logs into final convert_log.txt safely
Get-ChildItem -Path $scriptDir -Filter "temp_log_*.txt" | ForEach-Object {
    Get-Content $_.FullName | Out-File -FilePath $mainLog -Append -Encoding utf8
    Remove-Item $_.FullName -Force
}

Write-Host "All audio conversions completed! Originals moved to 'Original'." -ForegroundColor Green

Write-Host 
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   All Audio Conversions Completed!" -ForegroundColor Green
Write-Host "   Original files moved to the subfolder 'Original'" -ForegroundColor Green
Write-Host " ===================================================" -ForegroundColor Green
Write-Host

Start-Sleep -Seconds 2