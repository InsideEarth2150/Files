# =====================================================================
#   InsideEARTH - Earth 2150 TMP/LS Media Converter v1.3
# =====================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Self-elevation check
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

Clear-Host
$host.UI.RawUI.WindowTitle = "Earth 2150 Media Converter Launcher v1.1"

Write-Host
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   InsideEARTH - Earth 2150 Media Converter" -ForegroundColor Green
Write-Host " ===================================================" -ForegroundColor Green
Write-Host

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }
$ffmpegPath  = Join-Path $scriptDir "ffmpeg.exe"
$sevenZipExe = Join-Path $scriptDir "7za.exe"

function Exit-Script {
    param([int]$Code = 0)
    Write-Host
    Read-Host "Press Enter to exit..."
    exit $Code
}

# ---------- 0) Detect installed games via registry -----------------
Write-Host "Detecting installed Earth 2150 games via registry..." -ForegroundColor Cyan

$gameDefs = @(
    @{ Name = 'Earth 2150';       Sub = 'Topware\Earth 2150' }
)
$regRoots = @('HKCU:\Software', 'HKLM:\Software\WOW6432Node', 'HKLM:\Software')

$installed = @()
foreach ($g in $gameDefs) {
    $found = $null
    foreach ($root in $regRoots) {
        $key = "$root\$($g.Sub)\BaseGame\FileSystem"
        if (-not (Test-Path -LiteralPath $key)) { continue }
        $props = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
        foreach ($raw in @($props.OutputDir, $props.datapath)) {
            if (-not $raw) { continue }
            # datapath ends in "/>" (or "\>"), which is not a valid folder - strip it before testing
            $dir = ([string]$raw).Trim().TrimEnd('>').TrimEnd('/', '\')
            if ($dir -and (Test-Path -LiteralPath $dir -PathType Container)) { $found = $dir; break }
        }
        if ($found) { break }
    }
    if ($found) {
        $installed += [pscustomobject]@{ Name = $g.Name; Path = $found }
    }
}

# Manual fallback if nothing was detected
if ($installed.Count -eq 0) {
    Write-Host "WARNING: No installed Earth 2150 games were found in the registry." -ForegroundColor Yellow
    Write-Host "You can enter the game folder manually, or leave blank to exit." -ForegroundColor Yellow
    $manual = (Read-Host "Game folder").Trim().Trim('"').TrimEnd('/', '\')
    if ([string]::IsNullOrWhiteSpace($manual) -or -not (Test-Path -LiteralPath $manual -PathType Container)) {
        Write-Host "No valid folder given." -ForegroundColor Red
        Exit-Script 1
    }
    $installed += [pscustomobject]@{ Name = 'Manual folder'; Path = $manual }
}

# Single-game script: no menu, convert the detected install straight away
$targets = $installed

# ---------- 1) 7-Zip CLI -----------------
Write-Host
Write-Host "[1/3] 7-Zip Prerequisite..." -ForegroundColor Cyan
if (-not (Test-Path $sevenZipExe)) {
    Write-Host "7-Zip CLI not found. Downloading standalone 7za.exe..." -ForegroundColor Yellow
    $sevenZipUrl     = "https://www.7-zip.org/a/7za920.zip"
    $sevenZipZip     = Join-Path $scriptDir "7za.zip"
    $sevenZipExtract = Join-Path $scriptDir "7z_temp"
    try {
        Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipZip -UseBasicParsing
        Expand-Archive -Path $sevenZipZip -DestinationPath $sevenZipExtract -Force
        $extracted7z = Get-ChildItem -Path $sevenZipExtract -Filter "7za.exe" -Recurse | Select-Object -First 1
        if ($extracted7z) {
            Copy-Item -Path $extracted7z.FullName -Destination $scriptDir -Force
            Write-Host "7-Zip CLI successfully installed!" -ForegroundColor Green
        } else {
            Write-Host "Error: Could not extract 7-Zip CLI tool." -ForegroundColor Red
            Exit-Script 1
        }
    } finally {
        Remove-Item -Path $sevenZipZip -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $sevenZipExtract -Recurse -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "7za.exe found locally." -ForegroundColor Green
}

# ---------- 2) FFmpeg -----------------
Write-Host
Write-Host "[2/3] FFmpeg Prerequisite..." -ForegroundColor Cyan
if (-not (Test-Path $ffmpegPath)) {
    Write-Host "ffmpeg.exe not found. Downloading FFmpeg Essentials (.7z)..." -ForegroundColor Yellow
    $ffmpegUrl   = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-essentials.7z"
    $ffmpeg7z    = Join-Path $scriptDir "ffmpeg.7z"
    $extractPath = Join-Path $scriptDir "ffmpeg_temp"
    try {
        Invoke-WebRequest -Uri $ffmpegUrl -OutFile $ffmpeg7z -UseBasicParsing
        Write-Host "Extracting FFmpeg with 7-Zip..." -ForegroundColor Yellow
        & $sevenZipExe x $ffmpeg7z "-o$extractPath" -y | Out-Null
        $ffmpegBin = Get-ChildItem -Path $extractPath -Filter "ffmpeg.exe" -Recurse | Select-Object -First 1
        if ($ffmpegBin) {
            Copy-Item -Path $ffmpegBin.FullName -Destination $scriptDir -Force
            Write-Host "FFmpeg successfully installed to current folder!" -ForegroundColor Green
        } else {
            Write-Host "Error: Could not find ffmpeg.exe inside .7z archive." -ForegroundColor Red
            Exit-Script 1
        }
    } finally {
        Remove-Item -Path $ffmpeg7z -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "ffmpeg.exe found locally." -ForegroundColor Green
}

# ---------- 3) Parallel Audio Conversion -----------------
Write-Host
Write-Host "[3/3] Running Parallel Audio Conversion..." -ForegroundColor Cyan

$mainLog = Join-Path $scriptDir "convert_log.txt"
if (Test-Path $mainLog) { Remove-Item $mainLog -Force }
$tempLogDir = Join-Path $env:TEMP "e2150-convert-logs"
if (Test-Path $tempLogDir) { Remove-Item $tempLogDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $tempLogDir -Force | Out-Null

$MaxJobs = [Environment]::ProcessorCount
$ok = 0
$failed = 0

$jobScript = {
    param($filePath, $ffmpegExe, $backupFile, $jobLog)
    $file      = Get-Item -LiteralPath $filePath
    $fixedFile = Join-Path $file.DirectoryName ("{0}_fixed.mp2" -f $file.BaseName)

    "[$(Get-Date)] Starting processing on $($file.FullName)" | Out-File -FilePath $jobLog -Encoding utf8

    # Re-encode audio to MP2 192k
    & $ffmpegExe -i $file.FullName -c:a mp2 -b:a 192k -y $fixedFile *>> $jobLog

    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $fixedFile)) {
        $backupDir = Split-Path $backupFile -Parent
        if (-not (Test-Path -LiteralPath $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
        # Keep the original in the 'Original' backup folder, then put the converted file in its place
        Move-Item -LiteralPath $file.FullName -Destination $backupFile -Force
        Rename-Item -LiteralPath $fixedFile -NewName $file.Name -Force
        "[$(Get-Date)] OK: $($file.Name)" | Out-File -FilePath $jobLog -Append -Encoding utf8
        return "SUCCESS: $($file.Name)"
    } else {
        Remove-Item -LiteralPath $fixedFile -Force -ErrorAction SilentlyContinue
        "[$(Get-Date)] FAILED: $($file.Name)" | Out-File -FilePath $jobLog -Append -Encoding utf8
        return "FAILED: $($file.Name)"
    }
}

function Receive-FinishedJobs {
    foreach ($job in @(Get-Job | Where-Object { $_.State -in 'Completed', 'Failed' })) {
        $result = @(Receive-Job -Job $job -ErrorAction SilentlyContinue) | Select-Object -Last 1
        if ($result -like "SUCCESS*") {
            Write-Host $result -ForegroundColor Green
            $script:ok++
        } else {
            Write-Host $(if ($result) { $result } else { "FAILED: (job error)" }) -ForegroundColor Red
            $script:failed++
        }
        Remove-Job -Job $job -Force
    }
}

foreach ($target in $targets) {
    Write-Host
    Write-Host "--- $($target.Name): $($target.Path)" -ForegroundColor Cyan

    $originalRoot = Join-Path $target.Path "Original"

    # Recurse the game folder, skipping anything already in an 'Original' backup folder
    # NOTE: -Include is silently ignored when combined with -LiteralPath, so filter by extension explicitly
    $files = @(Get-ChildItem -LiteralPath $target.Path -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Extension -ieq '.mp2' -and
            $_.FullName -notlike "$originalRoot\*" -and
            $_.Name -notlike "*_fixed.mp2"
        })

    if ($files.Count -eq 0) {
        Write-Host "No .mp2 files found to convert." -ForegroundColor Yellow
        continue
    }

    Write-Host "Found $($files.Count) .mp2 files. Starting parallel audio conversion..." -ForegroundColor Cyan

    $idx = 0
    foreach ($file in $files) {
        while ((Get-Job -State Running).Count -ge $MaxJobs) {
            Receive-FinishedJobs
            Start-Sleep -Milliseconds 200
        }

        $idx++
        $relative   = $file.FullName.Substring($target.Path.Length).TrimStart('\')
        $backupFile = Join-Path $originalRoot $relative
        $jobLog     = Join-Path $tempLogDir ("{0}_{1}_{2}.txt" -f ($target.Name -replace '[^A-Za-z0-9]', ''), $idx, $file.BaseName)

        Start-Job -ScriptBlock $jobScript -ArgumentList $file.FullName, $ffmpegPath, $backupFile, $jobLog | Out-Null
    }

    # Wait for this game's jobs to finish, printing results as they complete
    while (Get-Job -State Running -ErrorAction SilentlyContinue) {
        Receive-FinishedJobs
        Start-Sleep -Milliseconds 500
    }
    Receive-FinishedJobs
}

# Combine all temp logs into the final convert_log.txt
Get-ChildItem -Path $tempLogDir -Filter "*.txt" -ErrorAction SilentlyContinue | ForEach-Object {
    Get-Content -LiteralPath $_.FullName | Out-File -FilePath $mainLog -Append -Encoding utf8
}
Remove-Item $tempLogDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   Audio conversion finished: $ok converted, $failed failed" -ForegroundColor Green
Write-Host "   Originals were moved to an 'Original' folder inside each game folder" -ForegroundColor Green
Write-Host "   Log: $mainLog" -ForegroundColor Green
Write-Host " ===================================================" -ForegroundColor Green

Exit-Script 0