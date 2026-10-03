# =====================================================================
#   InsideEARTH - System Information v1.0
# =====================================================================

# Self-elevation check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host

$host.ui.RawUI.WindowTitle = "InsideEARTH - System Information"

function Write-SectionHeader {
    param([string]$title)
    $line = "=" * 78
    Write-Host "`n$line" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Cyan
    Write-Host "$line" -ForegroundColor Cyan
}

function Write-ReportItem {
    param(
        [string]$label,
        [string]$value
    )
    Write-Host "  " -NoNewline
    Write-Host ("{0,-20}" -f $label) -ForegroundColor Yellow -NoNewline
    Write-Host " : " -NoNewline
    Write-Host $value -ForegroundColor White
}

# 1. Operating System & CPU/RAM Information
Write-SectionHeader "SYSTEM & OPERATING SYSTEM INFORMATION"
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor

Write-ReportItem "OS Name" $os.Caption
Write-ReportItem "Architecture" $os.OSArchitecture
Write-ReportItem "Version / Build" $os.Version
Write-ReportItem "CPU Model" $cpu.Name.Trim()
Write-ReportItem "CPU Cores" "$($cpu.NumberOfCores) Physical / $($cpu.NumberOfLogicalProcessors) Logical"

$totalRamGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeRamGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedRamGB = [math]::Round($totalRamGB - $freeRamGB, 2)
Write-ReportItem "RAM (Used / Total)" "$usedRamGB GB / $totalRamGB GB"

# 2. GPU and Driver Information
Write-SectionHeader "GPU INFORMATION"
$gpus = Get-CimInstance Win32_VideoController
foreach ($gpu in $gpus) {
    Write-ReportItem "GPU Name" $gpu.Name
    Write-ReportItem "Driver Version" $gpu.DriverVersion
    
    $driverDate = if ($gpu.DriverDate) { $gpu.DriverDate.ToString("yyyy-MM-dd HH:mm:ss") } else { "N/A" }
    Write-ReportItem "Driver Date" $driverDate

    # Fetch true 64-bit VRAM size from Display Registry Class with WMI fallback
    $vramTotalBytes = 0
    $videoClassPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    if (Test-Path $videoClassPath) {
        $subkeys = Get-ChildItem -Path $videoClassPath -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match '^\d{4}$' }
        foreach ($subkey in $subkeys) {
            $driverDesc = $subkey.GetValue("DriverDesc")
            if ($driverDesc -eq $gpu.Name) {
                $qwMem = $subkey.GetValue("HardwareInformation.qwMemorySize")
                if ($null -ne $qwMem) {
                    $vramTotalBytes = $qwMem
                    break
                }
            }
        }
    }
    if ($vramTotalBytes -eq 0 -and $gpu.AdapterRAM) {
        $vramTotalBytes = $gpu.AdapterRAM
    }
    $vramTotalStr = if ($vramTotalBytes -gt 0) { "$([math]::Round($vramTotalBytes / 1GB, 1)) GB" } else { "N/A" }

    # VRAM Used calculation via Performance Counters
    $vramUsedStr = "N/A"
    try {
        $counter = Get-Counter -Counter "\GPU Adapter Memory(*)\Dedicated Usage" -ErrorAction Stop
        $usedBytes = ($counter.CounterSamples | Measure-Object -Property CookedValue -Sum).Sum
        if ($null -ne $usedBytes) {
            $vramUsedStr = "$([math]::Round($usedBytes / 1GB, 2)) GB"
        }
    } catch {
        $vramUsedStr = "Unavailable"
    }

    Write-ReportItem "VRAM (Used / Total)" "$vramUsedStr / $vramTotalStr"
}

# 3. Registry Configurations (Side-by-side custom colored output)
Write-SectionHeader "GAME GRAPHICS SETTINGS"

$regTargets = @(
    @{ Name = "Earth 2150"; Path = "HKCU:\Software\Topware\Earth 2150\BaseGame\Graphics\Default" },
    @{ Name = "The Moon Project"; Path = "HKCU:\Software\Topware\TheMoonProject\BaseGame\Graphics\Default" },
    @{ Name = "Lost Souls"; Path = "HKCU:\Software\Reality Pump\LostSouls\BaseGame\Graphics\Default" }
)

$keysToRead = @('Renderer', 'RendererType', 'FullScreen', 'Height', 'Width', 'BitDepth')
$regData = @{}

foreach ($target in $regTargets) {
    $vals = @{}
    if (Test-Path $target.Path) {
        $raw = Get-ItemProperty -Path $target.Path -ErrorAction SilentlyContinue
        foreach ($k in $keysToRead) {
            if ($null -ne $raw -and $raw.PSObject.Properties[$k] -and $null -ne $raw.$k) {
                $val = [string]$raw.$k
                # Strip "display" and "hal" case-insensitively
                if ($val -match '[a-zA-Z]') {
                    $val = $val -replace '(?i)display', '' -replace '(?i)hal', ''
                    while ($val -like '*  *') { $val = $val -replace '  ', ' ' }
                    $val = $val.Trim()
                }
                if ($val -eq "") { $val = "No Value" }
            } else {
                $val = "No Value"
            }
            $vals[$k] = $val
        }
    } else {
        foreach ($k in $keysToRead) { $vals[$k] = "No Value" }
    }
    $regData[$target.Name] = $vals
}

# Print Table Header
Write-Host ""
Write-Host ("  {0,-14} | {1,-18} | {2,-18} | {3,-18}" -f "Value Name", "Earth 2150", "The Moon Project", "Lost Souls") -ForegroundColor Cyan
Write-Host ("  " + "-" * 76) -ForegroundColor Cyan

# Helper function for cell color
function Write-TableCell {
    param([string]$val)
    $color = if ($val -eq "No Value") { "Red" } else { "White" }
    Write-Host ("{0,-18}" -f $val) -ForegroundColor $color -NoNewline
}

# Print Table Rows with custom coloring (Yellow for value name, White/Red for results)
foreach ($key in $keysToRead) {
    $v1 = $regData["Earth 2150"][$key]
    $v2 = $regData["The Moon Project"][$key]
    $v3 = $regData["Lost Souls"][$key]

    Write-Host "  " -NoNewline
    Write-Host ("{0,-14}" -f $key) -ForegroundColor Yellow -NoNewline
    Write-Host " | " -NoNewline
    Write-TableCell $v1
    Write-Host " | " -NoNewline
    Write-TableCell $v2
    Write-Host " | " -NoNewline
    Write-TableCell $v3
    Write-Host ""
}

# 4. Powershell Information
Write-SectionHeader "POWERSHELL INFORMATION"
$powershell = $PSVersionTable.PSVersion

Write-ReportItem "Powershell Version" $powershell
Write-Host "`n"
Write-Host ("=" * 78) -ForegroundColor Green
Write-Host " Script execution completed successfully." -ForegroundColor Green
Write-Host ("=" * 78) -ForegroundColor Green

Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host | Out-Null