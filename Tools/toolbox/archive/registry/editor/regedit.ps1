# =====================================================================
#    InsideEARTH - Earth 2150 Registry Tools v1.4
# =====================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Self-elevation check to run as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host

$host.UI.RawUI.WindowTitle = "InsideEARTH - Earth 2150 Tools & Utilities Launcher v1.4"
$ErrorActionPreference = 'Stop'

# Suffix appended to the game folder to form the 'datapath' value
$DataPathSuffix = '/>'

# ---------------------------------------------------------------------
#  DEFAULT REGISTRY SETTINGS - one block per game
#
#  Edit the values inside a game's block to change what 'Registry Default'
#  writes for THAT game only. Each block has:
#    HKCU = settings under the current user hive
#    HKLM = settings under the machine hive (WOW6432Node)
#  Format:   'Key\Path' = [ordered]@{ ValueName = value }
#    - whole numbers (1920, 1, 0) are written as DWORD
#    - text in quotes ('like this') is written as a String
#  '(root)' means the game's top-level key.
#  Install path (datapath / OutputDir) is NOT set here; it is preserved
#  or asked for when you run Registry Default.
# ---------------------------------------------------------------------

# ===== Earth 2150 =====
$Defaults_Earth2150 = @{
        HKCU = [ordered]@{
            '(root)'                       = [ordered]@{}
            'BaseGame'                     = [ordered]@{}
            'BaseGame\Graphics'            = [ordered]@{ GammaCorrection = 1 }
            'BaseGame\Graphics\Default'   = [ordered]@{
                Renderer     = 'display Direct3D HAL'
                Width        = 1920
                Height       = 1080
                BitDepth     = 32
                RendererType = 3
                FullScreen   = 1
            }
            'BaseGame\Graphics\Direct3D'  = [ordered]@{ UseTrueColorTextures = 0 }
            'BaseGame\Graphics\Enumeration' = [ordered]@{
                Glide    = 1
                Direct3D = 1
                Software = 0
                Hardware = 1
                OpenGL   = 1
            }
            'BaseGame\Graphics\Setup'     = [ordered]@{
                ButtonTestAll       = 1
                AllowWindowedScreen = 1
            }
            'BaseGame\Graphics\Textures'  = [ordered]@{ ManualAdjust = 0 }
            'BaseGame\Interface'           = [ordered]@{
                AllFontsAtStart  = 1
                Charset          = 1
                TranslateNumKeys = 1
            }
            'BaseGame\Intro'               = [ordered]@{ ShowOnStart = 0 }
            'BaseGame\Intro\Setup'        = [ordered]@{ IntroButton = 1 }
            'BaseGame\Network'             = [ordered]@{}
            'BaseGame\Network\DPLobby'    = [ordered]@{}
            'BaseGame\Network\EarthNet'   = [ordered]@{
                AddressIP = '"EarthNet - InsideEARTH""vpnnetserver2150.insideearth.info:17171""EarthNet - TopWare""netserver.earth2150.com:17101"'
            }
            'BaseGame\Network\Enumeration' = [ordered]@{
                Serial   = 1
                Modem    = 1
                'TCP/IP' = 1
                EarthNet = 1
                DPLobby  = 1
            }
            'BaseGame\Network\Serial'     = [ordered]@{ BaudRate = '14400;19200;38400;56000;57600;115200;128000;256000' }
            'BaseGame\Processor'           = [ordered]@{ Katmai = 1 }
            'BaseGame\Sound'               = [ordered]@{
                SoundType                = 2
                Frequency                = 22050
                HardwareChannels         = 16
                SoftwareChannels         = 16
                EnumerateEmulatedDrivers = 1
                MixerType                = 0
            }
            'BaseGame\Sound\Setup'        = [ordered]@{ AllowHardware = 0 }
        }
        HKLM = [ordered]@{
            '(root)' = [ordered]@{ NotStartAutorun = '1' }
            'BaseGame' = [ordered]@{}
            'BaseGame\Graphics' = [ordered]@{}
            'BaseGame\Graphics\Default' = [ordered]@{}
            'BaseGame\Graphics\Direct3D' = [ordered]@{}
            'BaseGame\Graphics\Enumeration' = [ordered]@{}
            'BaseGame\Graphics\Setup' = [ordered]@{}
            'BaseGame\Graphics\Textures' = [ordered]@{}
            'BaseGame\Interface' = [ordered]@{}
            'BaseGame\Intro' = [ordered]@{}
            'BaseGame\Intro\Setup' = [ordered]@{}
            'BaseGame\Network' = [ordered]@{}
            'BaseGame\Network\DPLobby' = [ordered]@{}
            'BaseGame\Network\Enumeration' = [ordered]@{}
            'BaseGame\Network\Serial' = [ordered]@{}
            'BaseGame\Processor' = [ordered]@{}
            'BaseGame\Sound' = [ordered]@{}
            'BaseGame\Sound\Setup' = [ordered]@{}
        }
}

# ===== The Moon Project =====
$Defaults_MoonProject = @{
        HKCU = [ordered]@{
            '(root)'                       = [ordered]@{}
            'BaseGame'                     = [ordered]@{}
            'BaseGame\Graphics'            = [ordered]@{ GammaCorrection = 1 }
            'BaseGame\Graphics\Default'   = [ordered]@{
                Renderer     = 'display Direct3D HAL'
                Width        = 1920
                Height       = 1080
                BitDepth     = 32
                RendererType = 3
                FullScreen   = 1
            }
            'BaseGame\Graphics\Direct3D'  = [ordered]@{ UseTrueColorTextures = 0 }
            'BaseGame\Graphics\Enumeration' = [ordered]@{
                Glide    = 1
                Direct3D = 1
                Software = 0
                Hardware = 1
                OpenGL   = 1
            }
            'BaseGame\Graphics\Setup'     = [ordered]@{
                ButtonTestAll       = 1
                AllowWindowedScreen = 1
            }
            'BaseGame\Graphics\Textures'  = [ordered]@{ ManualAdjust = 0 }
            'BaseGame\Interface'           = [ordered]@{
                AllFontsAtStart  = 1
                Charset          = 1
                TranslateNumKeys = 1
            }
            'BaseGame\Intro'               = [ordered]@{ ShowOnStart = 0 }
            'BaseGame\Intro\Setup'        = [ordered]@{ IntroButton = 1 }
            'BaseGame\Network'             = [ordered]@{}
            'BaseGame\Network\DPLobby'    = [ordered]@{}
            'BaseGame\Network\EarthNet'   = [ordered]@{
                AddressIP = '"EarthNet - InsideEARTH""vpnnetserver2150.insideearth.info:17171""EarthNet - TopWare""netserver.earth2150.com:17101"'
            }
            'BaseGame\Network\Enumeration' = [ordered]@{
                Serial   = 1
                Modem    = 1
                'TCP/IP' = 1
                EarthNet = 1
                DPLobby  = 1
            }
            'BaseGame\Network\Serial'     = [ordered]@{ BaudRate = '14400;19200;38400;56000;57600;115200;128000;256000' }
            'BaseGame\Processor'           = [ordered]@{ Katmai = 1 }
            'BaseGame\Sound'               = [ordered]@{
                SoundType                = 2
                Frequency                = 22050
                HardwareChannels         = 16
                SoftwareChannels         = 16
                EnumerateEmulatedDrivers = 1
                MixerType                = 0
            }
            'BaseGame\Sound\Setup'        = [ordered]@{ AllowHardware = 0 }
        }
        HKLM = [ordered]@{
            '(root)' = [ordered]@{ NotStartAutorun = '1' }
            'BaseGame' = [ordered]@{}
            'BaseGame\Graphics' = [ordered]@{}
            'BaseGame\Graphics\Default' = [ordered]@{}
            'BaseGame\Graphics\Direct3D' = [ordered]@{}
            'BaseGame\Graphics\Enumeration' = [ordered]@{}
            'BaseGame\Graphics\Setup' = [ordered]@{}
            'BaseGame\Graphics\Textures' = [ordered]@{}
            'BaseGame\Interface' = [ordered]@{}
            'BaseGame\Intro' = [ordered]@{}
            'BaseGame\Intro\Setup' = [ordered]@{}
            'BaseGame\Network' = [ordered]@{}
            'BaseGame\Network\DPLobby' = [ordered]@{}
            'BaseGame\Network\Enumeration' = [ordered]@{}
            'BaseGame\Network\Serial' = [ordered]@{}
            'BaseGame\Processor' = [ordered]@{}
            'BaseGame\Sound' = [ordered]@{}
            'BaseGame\Sound\Setup' = [ordered]@{}
        }
}

# ===== Lost Souls =====
$Defaults_LostSouls = @{
        HKCU = [ordered]@{
            '(root)'                       = [ordered]@{}
            'BaseGame'                     = [ordered]@{}
            'BaseGame\Graphics'            = [ordered]@{ GammaCorrection = 1 }
            'BaseGame\Graphics\Default'   = [ordered]@{
                Renderer     = 'display Direct3D HAL'
                Width        = 1920
                Height       = 1080
                BitDepth     = 32
                RendererType = 3
                FullScreen   = 1
            }
            'BaseGame\Graphics\Direct3D'  = [ordered]@{ UseTrueColorTextures = 0 }
            'BaseGame\Graphics\Enumeration' = [ordered]@{
                Glide    = 1
                Direct3D = 1
                Software = 0
                Hardware = 1
                OpenGL   = 1
            }
            'BaseGame\Graphics\Setup'     = [ordered]@{
                ButtonTestAll       = 1
                AllowWindowedScreen = 1
            }
            'BaseGame\Graphics\Textures'  = [ordered]@{ ManualAdjust = 0 }
            'BaseGame\Interface'           = [ordered]@{
                AllFontsAtStart  = 1
                Charset          = 1
                TranslateNumKeys = 1
            }
            'BaseGame\Intro'               = [ordered]@{ ShowOnStart = 0 }
            'BaseGame\Intro\Setup'        = [ordered]@{ IntroButton = 1 }
            'BaseGame\Network'             = [ordered]@{}
            'BaseGame\Network\DPLobby'    = [ordered]@{}
            'BaseGame\Network\EarthNet'   = [ordered]@{
                AddressIP = '"EarthNet - InsideEARTH""vpnnetserver2150.insideearth.info:17171""EarthNet - TopWare""netserver.earth2150.com:17101"'
            }
            'BaseGame\Network\Enumeration' = [ordered]@{
                Serial   = 1
                Modem    = 1
                'TCP/IP' = 1
                EarthNet = 1
                DPLobby  = 1
            }
            'BaseGame\Network\Serial'     = [ordered]@{ BaudRate = '14400;19200;38400;56000;57600;115200;128000;256000' }
            'BaseGame\Processor'           = [ordered]@{ Katmai = 1 }
            'BaseGame\Sound'               = [ordered]@{
                SoundType                = 2
                Frequency                = 22050
                HardwareChannels         = 16
                SoftwareChannels         = 16
                EnumerateEmulatedDrivers = 1
                MixerType                = 0
            }
            'BaseGame\Sound\Setup'        = [ordered]@{ AllowHardware = 0 }
        }
        HKLM = [ordered]@{
            '(root)' = [ordered]@{ NotStartAutorun = '1' }
            'BaseGame' = [ordered]@{}
            'BaseGame\Graphics' = [ordered]@{}
            'BaseGame\Graphics\Default' = [ordered]@{}
            'BaseGame\Graphics\Direct3D' = [ordered]@{}
            'BaseGame\Graphics\Enumeration' = [ordered]@{}
            'BaseGame\Graphics\Setup' = [ordered]@{}
            'BaseGame\Graphics\Textures' = [ordered]@{}
            'BaseGame\Interface' = [ordered]@{}
            'BaseGame\Intro' = [ordered]@{}
            'BaseGame\Intro\Setup' = [ordered]@{}
            'BaseGame\Network' = [ordered]@{}
            'BaseGame\Network\DPLobby' = [ordered]@{}
            'BaseGame\Network\Enumeration' = [ordered]@{}
            'BaseGame\Network\Serial' = [ordered]@{}
            'BaseGame\Processor' = [ordered]@{}
            'BaseGame\Sound' = [ordered]@{}
            'BaseGame\Sound\Setup' = [ordered]@{}
        }
}

# Define game configurations. Each game has a HKCU root, a HKLM (WOW6432Node) root and its own defaults.
$games = @(
    @{
        Name     = "Earth 2150"
        HkcuBase = "HKCU:\Software\Topware\Earth 2150"
        HklmBase = "HKLM:\Software\WOW6432Node\Topware\Earth 2150"
        Defaults = $Defaults_Earth2150
    },
    @{
        Name     = "The Moon Project"
        HkcuBase = "HKCU:\Software\Topware\TheMoonProject"
        HklmBase = "HKLM:\Software\WOW6432Node\Topware\TheMoonProject"
        Defaults = $Defaults_MoonProject
    },
    @{
        Name     = "Lost Souls"
        HkcuBase = "HKCU:\Software\Reality Pump\LostSouls"
        HklmBase = "HKLM:\Software\WOW6432Node\Reality Pump\LostSouls"
        Defaults = $Defaults_LostSouls
    }
)

# ---------------------------------------------------------------------
#  Helpers
# ---------------------------------------------------------------------
function Get-FileSystemPaths {
    param($Game)
    return @(
        "$($Game.HkcuBase)\BaseGame\FileSystem",
        "$($Game.HklmBase)\BaseGame\FileSystem"
    )
}

function Write-Header {
    param([string]$Title)
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host "   $Title" -ForegroundColor Green
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host ""
}

function Wait-AnyKey {
    param([string]$Message = "Press any key to continue...")
    Write-Host ""
    Write-Host $Message -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Write-RegistryEntries {
    param(
        [string]$Base,
        $Entries
    )
    foreach ($sub in $Entries.Keys) {
        $keyPath = if ($sub -eq '(root)') { $Base } else { "$Base\$sub" }
        if (-not (Test-Path -LiteralPath $keyPath)) {
            $null = New-Item -Path $keyPath -Force
        }
        foreach ($name in $Entries[$sub].Keys) {
            $value = $Entries[$sub][$name]
            $type  = if ($value -is [int]) { 'DWord' } else { 'String' }
            Set-ItemProperty -LiteralPath $keyPath -Name $name -Value $value -Type $type -Force
        }
    }
}

function Show-GameMenu {
    Write-Header "InsideEARTH - Earth 2150 Tools & Utilities Menu"
    Write-Host "Select a game:" -ForegroundColor White
    for ($i = 0; $i -lt $games.Count; $i++) {
        Write-Host "    [$($i + 1)] $($games[$i].Name)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "    [$($games.Count + 1)] Exit" -ForegroundColor Red
    Write-Host ""
}

function Show-ActionMenu {
    param([string]$GameName)
    Write-Header "InsideEARTH - $GameName"
    Write-Host "Select an action:" -ForegroundColor White
    Write-Host "    [1] Registry Editor   (set game install path)" -ForegroundColor White
    Write-Host "    [2] Registry Default  (install default registry settings)" -ForegroundColor White
    Write-Host "    [3] Registry Backup   (HKCU + HKLM into a single .reg file)" -ForegroundColor White
    Write-Host ""
    Write-Host "    [4] Back" -ForegroundColor Red
    Write-Host ""
}

# ---------------------------------------------------------------------
#  Option 1: Registry Editor (unchanged behaviour)
# ---------------------------------------------------------------------
function Edit-RegistryValues {
    param(
        [string]$GameName,
        [string[]]$RegPaths
    )

    Write-Header "InsideEARTH - $GameName Registry Configuration"

    Write-Host "Current Registry Information (HKCU & HKLM):" -ForegroundColor Cyan

    foreach ($path in $RegPaths) {
        Write-Host "  [$path]" -ForegroundColor DarkGray
        try {
            if (Test-Path -LiteralPath $path) {
                $currentDatapath  = (Get-ItemProperty -LiteralPath $path -Name "datapath" -ErrorAction SilentlyContinue).datapath
                $currentOutputDir = (Get-ItemProperty -LiteralPath $path -Name "OutputDir" -ErrorAction SilentlyContinue).OutputDir
            } else {
                $currentDatapath  = $null
                $currentOutputDir = $null
            }

            Write-Host "     datapath  : $(if ($currentDatapath) { $currentDatapath } else { '(not set)' })" -ForegroundColor White
            Write-Host "     OutputDir : $(if ($currentOutputDir) { $currentOutputDir } else { '(not set)' })" -ForegroundColor White
        } catch {
            Write-Host "    [!] Could not access registry path: $_" -ForegroundColor Red
        }
    }
    Write-Host ""

    $choice = Read-Host "Do you wish to edit these values for both locations? (y/n)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        Write-Host ""
        $fullPath = Read-Host "Enter the full file path (e.g., G:\Games\Steam\steamapps\common\GameName)"

        if ([string]::IsNullOrWhiteSpace($fullPath)) {
            Write-Host "Path cannot be empty." -ForegroundColor Red
            Start-Sleep -Seconds 2
            return
        }

        # Clean trailing slashes and append required Earth 2150 datapath suffix
        $cleanPath    = $fullPath.Trim().Trim('"').TrimEnd('/', '\')
        $newDatapath  = "$cleanPath$DataPathSuffix"
        $newOutputDir = $cleanPath

        foreach ($path in $RegPaths) {
            try {
                # Create registry key folder hierarchy ONLY if it does not exist yet
                if (-not (Test-Path -LiteralPath $path)) {
                    $null = New-Item -Path $path -Force
                }

                # Target ONLY datapath and OutputDir explicitly
                Set-ItemProperty -LiteralPath $path -Name "datapath" -Value $newDatapath -Type String -Force
                Set-ItemProperty -LiteralPath $path -Name "OutputDir" -Value $newOutputDir -Type String -Force

            } catch {
                Write-Host "    [!] Failed to update $path : $_" -ForegroundColor Red
            }
        }

        Write-Host ""
        Write-Host "Changes successfully applied to all targets!" -ForegroundColor Green
        Write-Host "Updated Registry Information:" -ForegroundColor Cyan
        Write-Host "  datapath  : $newDatapath" -ForegroundColor White
        Write-Host "  OutputDir : $newOutputDir" -ForegroundColor White
    }

    Wait-AnyKey "Press any key to return to the menu..."
}

# ---------------------------------------------------------------------
#  Option 2: Registry Default
#  Rewrites every default value. The install path (datapath/OutputDir)
#  is machine specific, so existing values are kept; if none exist you
#  are asked for the game folder.
# ---------------------------------------------------------------------
function Install-DefaultRegistry {
    param($Game)

    Write-Header "InsideEARTH - $($Game.Name) Default Registry Settings"
    Write-Host "This will write the default settings under:" -ForegroundColor Cyan
    Write-Host "  $($Game.HkcuBase)" -ForegroundColor DarkGray
    Write-Host "  $($Game.HklmBase)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Existing values with the same names will be overwritten." -ForegroundColor Yellow
    Write-Host "Your install path (datapath / OutputDir) is preserved if already set." -ForegroundColor Yellow
    Write-Host "Tip: run Registry Backup first if you want to be able to undo this." -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "Continue? (y/n)"
    if ($choice -ne 'y' -and $choice -ne 'Y') { return }

    try {
        # Work out the install path values to keep (prefer HKCU, then HKLM)
        $fsPaths = Get-FileSystemPaths $Game
        $keepDatapath  = $null
        $keepOutputDir = $null
        foreach ($p in $fsPaths) {
            if (Test-Path -LiteralPath $p) {
                if (-not $keepDatapath)  { $keepDatapath  = (Get-ItemProperty -LiteralPath $p -Name "datapath" -ErrorAction SilentlyContinue).datapath }
                if (-not $keepOutputDir) { $keepOutputDir = (Get-ItemProperty -LiteralPath $p -Name "OutputDir" -ErrorAction SilentlyContinue).OutputDir }
            }
        }

        if (-not $keepDatapath -or -not $keepOutputDir) {
            Write-Host ""
            $fullPath = Read-Host "No install path found. Enter the game folder (blank to leave unset)"
            if (-not [string]::IsNullOrWhiteSpace($fullPath)) {
                $cleanPath     = $fullPath.Trim().Trim('"').TrimEnd('/', '\')
                $keepDatapath  = "$cleanPath$DataPathSuffix"
                $keepOutputDir = $cleanPath
            }
        }

        # Write the defaults
        Write-RegistryEntries -Base $Game.HkcuBase -Entries $Game.Defaults.HKCU
        Write-RegistryEntries -Base $Game.HklmBase -Entries $Game.Defaults.HKLM

        # Restore/create the install path values in both hives
        if ($keepDatapath -and $keepOutputDir) {
            foreach ($p in $fsPaths) {
                if (-not (Test-Path -LiteralPath $p)) { $null = New-Item -Path $p -Force }
                Set-ItemProperty -LiteralPath $p -Name "datapath" -Value $keepDatapath -Type String -Force
                Set-ItemProperty -LiteralPath $p -Name "OutputDir" -Value $keepOutputDir -Type String -Force
            }
        }

        Write-Host ""
        Write-Host "Default registry settings installed for $($Game.Name)." -ForegroundColor Green
        if ($keepDatapath) {
            Write-Host "  datapath  : $keepDatapath" -ForegroundColor White
            Write-Host "  OutputDir : $keepOutputDir" -ForegroundColor White
        } else {
            Write-Host "  Install path left unset - use Registry Editor to set it." -ForegroundColor Yellow
        }
    } catch {
        Write-Host ""
        Write-Host "[!] Failed to install defaults: $_" -ForegroundColor Red
    }

    Wait-AnyKey "Press any key to return to the menu..."
}

# ---------------------------------------------------------------------
#  Option 3: Registry Backup (HKCU + HKLM merged into one .reg file)
# ---------------------------------------------------------------------
function Backup-GameRegistry {
    param($Game)

    Write-Header "InsideEARTH - $($Game.Name) Registry Backup"

    $desktop   = [Environment]::GetFolderPath('Desktop')
    $timestamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
    $safeName  = ($Game.Name -replace '[^A-Za-z0-9]', '')
    $backupFile = Join-Path $desktop "Earth2150-Backup-$safeName-$timestamp.reg"

    $sources = @(
        @{ Label = 'HKCU'; Path = $Game.HkcuBase; Native = ($Game.HkcuBase -replace '^HKCU:\\', 'HKEY_CURRENT_USER\') },
        @{ Label = 'HKLM'; Path = $Game.HklmBase; Native = ($Game.HklmBase -replace '^HKLM:\\', 'HKEY_LOCAL_MACHINE\') }
    )

    $merged   = New-Object System.Collections.Generic.List[string]
    $exported = 0

    try {
        foreach ($src in $sources) {
            if (-not (Test-Path -LiteralPath $src.Path)) {
                Write-Host " - $($src.Label): key not found, skipping." -ForegroundColor Yellow
                continue
            }

            $tmp = Join-Path $env:TEMP "e2150-$($src.Label)-$timestamp.reg"
            & reg.exe export $src.Native $tmp /y *> $null
            if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $tmp)) {
                Write-Host " - $($src.Label): export failed." -ForegroundColor Red
                continue
            }

            # reg.exe writes UTF-16 (Unicode) files
            $lines = @(Get-Content -LiteralPath $tmp -Encoding Unicode)
            Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue

            if ($exported -eq 0) {
                foreach ($l in $lines) { $merged.Add($l) }
            } else {
                # Skip the duplicate 'Windows Registry Editor Version 5.00' header
                $merged.Add('')
                foreach ($l in ($lines | Select-Object -Skip 1)) { $merged.Add($l) }
            }
            $exported++
            Write-Host " - $($src.Label): exported." -ForegroundColor Green
        }

        if ($exported -eq 0) {
            Write-Host ""
            Write-Host "Nothing to back up - neither key exists for $($Game.Name)." -ForegroundColor Yellow
        } else {
            Set-Content -LiteralPath $backupFile -Value $merged -Encoding Unicode
            Write-Host ""
            Write-Host "Backup saved to:" -ForegroundColor Green
            Write-Host "  $backupFile" -ForegroundColor White
        }
    } catch {
        Write-Host ""
        Write-Host "[!] Backup failed: $_" -ForegroundColor Red
    }

    Wait-AnyKey "Press any key to return to the menu..."
}

# ---------------------------------------------------------------------
#  Per-game action menu
# ---------------------------------------------------------------------
function Start-GameActions {
    param($Game)

    do {
        Show-ActionMenu -GameName $Game.Name
        $sel = Read-Host "Enter option (1-4)"

        switch ($sel) {
            '1' { Edit-RegistryValues -GameName $Game.Name -RegPaths (Get-FileSystemPaths $Game) }
            '2' { Install-DefaultRegistry -Game $Game }
            '3' { Backup-GameRegistry -Game $Game }
            '4' { return }
            default {
                Write-Host ""
                Write-Host "Invalid selection." -ForegroundColor Red
                Wait-AnyKey "Press any key to try again..."
            }
        }
    } while ($true)
}

# ---------------------------------------------------------------------
#  Main loop
# ---------------------------------------------------------------------
do {
    Show-GameMenu
    $maxOption = $games.Count + 1
    $selection = Read-Host "Enter option (1-$maxOption)"

    switch ($selection) {
        '1' { Start-GameActions -Game $games[0] }
        '2' { Start-GameActions -Game $games[1] }
        '3' { Start-GameActions -Game $games[2] }
        "$maxOption" { exit }
        default {
            Write-Host ""
            Write-Host "Invalid selection." -ForegroundColor Red
            Wait-AnyKey "Press any key to try again..."
        }
    }
} while ($true)