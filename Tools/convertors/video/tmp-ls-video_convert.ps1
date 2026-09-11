# =====================================================================
#   InsideEARTH - Earth 2150 TMP/LS Video Convertor
# =====================================================================

clear

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
Write-Host "[1/4] 7-Zip Prerequisite..." -ForegroundColor Cyan
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
Write-Host "[2/4] FFmpeg Prerequisite..." -ForegroundColor Cyan
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

# ---------- 3) Detect GPU Capabilities -----------------
Write-Host 
Write-Host "[3/4] Testing Hardware Acceleration Support..." -ForegroundColor Cyan

$supportedEncoders = & $ffmpegPath -encoders 2>$null
$gpus = Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name
$selectedEncoder = $null
$selectedPixelFormat = "yuv420p"

$gpuCandidates = @()
foreach ($gpu in $gpus) {
    if ($gpu -match "NVIDIA" -and $supportedEncoders -match "h264_nvenc") { $gpuCandidates += "h264_nvenc" }
    elseif ($gpu -match "AMD|Radeon" -and $supportedEncoders -match "h264_amf") { $gpuCandidates += "h264_amf" }
    elseif ($gpu -match "Intel" -and $supportedEncoders -match "h264_qsv") { $gpuCandidates += "h264_qsv" }
}

$dummyOutput = Join-Path $scriptDir "gpu_test.avi"
$dummyLog = Join-Path $scriptDir "gpu_test.log"

foreach ($candidate in $gpuCandidates) {
    $testArgs = "-f lavfi -i testsrc=duration=1:size=256x192:rate=15 -vf `"pad=ceil(iw/16)*16:ceil(ih/16)*16`" -c:v $candidate -pix_fmt yuv420p -f avi -y `"$dummyOutput`""
    $p = Start-Process -FilePath $ffmpegPath -ArgumentList $testArgs -NoNewWindow -Wait -PassThru -RedirectStandardError $dummyLog
    
    if ($p.ExitCode -eq 0 -and (Test-Path $dummyOutput) -and ((Get-Item $dummyOutput).Length -gt 0)) {
        $selectedEncoder = $candidate
        Write-Host "GPU hardware acceleration test PASSED ($selectedEncoder)." -ForegroundColor Green
        break
    }
}

if (Test-Path $dummyOutput) { Remove-Item $dummyOutput -Force -ErrorAction SilentlyContinue }
if (Test-Path $dummyLog) { Remove-Item $dummyLog -Force -ErrorAction SilentlyContinue }

if (-not $selectedEncoder) {
    $selectedEncoder = "cinepak"
    $selectedPixelFormat = "rgb24"
    Write-Host "GPU encoding test failed or unsupported. Falling back to CPU encoding ($selectedEncoder)." -ForegroundColor Yellow
}

# ---------- 4) High-Speed Direct Video Conversion -----------------
Write-Host 
Write-Host "[4/4] Running Direct Video Conversion..." -ForegroundColor Cyan

$originalDir = Join-Path $scriptDir "Original"
if (-not (Test-Path $originalDir)) {
    New-Item -ItemType Directory -Path $originalDir | Out-Null
}

$files = Get-ChildItem -Path (Join-Path $scriptDir "*") -Include *.wd1, *.WD1 -File

if ($files.Count -eq 0) {
    Write-Host "No .wd1 files found to convert." -ForegroundColor Yellow
    exit
}

Write-Host "Found $($files.Count) .wd1 files. Processing sequentially at maximum GPU burst speed..." -ForegroundColor Cyan

foreach ($file in $files) {
    $baseName = $file.BaseName
    $fixedFile = Join-Path $file.DirectoryName "${baseName}_fixed.avi"
    $logFile = Join-Path $file.DirectoryName "${baseName}_error.log"

    if (Test-Path $fixedFile) { Remove-Item $fixedFile -Force }
    if (Test-Path $logFile) { Remove-Item $logFile -Force }

    # Attempt 1: NVENC/GPU with automatic macroblock padding (prevents silent NVENC resolution rejections)
    if ($selectedEncoder -ne "cinepak") {
        $ffmpegArgs = "-i `"$($file.FullName)`" -vf `"pad=ceil(iw/16)*16:ceil(ih/16)*16`" -c:v $selectedEncoder -pix_fmt $selectedPixelFormat -c:a pcm_s16le -f avi -y `"$fixedFile`""
    } else {
        $ffmpegArgs = "-i `"$($file.FullName)`" -c:v cinepak -pix_fmt rgb24 -c:a pcm_s16le -f avi -y `"$fixedFile`""
    }

    $process = Start-Process -FilePath $ffmpegPath -ArgumentList $ffmpegArgs -NoNewWindow -Wait -PassThru -RedirectStandardError $logFile

    # Attempt 2: Instant Cinepak CPU fallback if NVENC fails on specific file
    if ($process.ExitCode -ne 0 -or -not (Test-Path $fixedFile) -or ((Get-Item $fixedFile).Length -eq 0)) {
        if ($selectedEncoder -ne "cinepak") {
            if (Test-Path $fixedFile) { Remove-Item $fixedFile -Force }
            $cpuArgs = "-i `"$($file.FullName)`" -c:v cinepak -pix_fmt rgb24 -c:a pcm_s16le -f avi -y `"$fixedFile`""
            $process = Start-Process -FilePath $ffmpegPath -ArgumentList $cpuArgs -NoNewWindow -Wait -PassThru -RedirectStandardError $logFile
        }
    }

    # Verify and finalize
    if ($process.ExitCode -eq 0 -and (Test-Path $fixedFile) -and ((Get-Item $fixedFile).Length -gt 0)) {
        Move-Item -Path $file.FullName -Destination (Join-Path $originalDir $file.Name) -Force
        Rename-Item -Path $fixedFile -NewName $file.Name -Force
        if (Test-Path $logFile) { Remove-Item $logFile -Force }
        Write-Host "SUCCESS: $($file.Name)" -ForegroundColor Green
    } else {
        if (Test-Path $fixedFile) { Remove-Item $fixedFile -Force }
        Write-Host "FAILED: $($file.Name) -> Check $logFile" -ForegroundColor Red
    }
}

Write-Host 
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   All Video Conversions Completed!" -ForegroundColor Green
Write-Host "   Original files moved to the subfolder 'Original'" -ForegroundColor Green
Write-Host " ===================================================" -ForegroundColor Green
Write-Host

Start-Sleep -Seconds 2