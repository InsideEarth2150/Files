# =====================================================================
#   InsideEARTH - Earth 2150 Multiplayer Setup v1.0
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

$host.ui.RawUI.WindowTitle = "InsideEARTH - Earth 2150 Multiplayer Setup"

# Variable Definitions
$Name            = 'InsideEARTH 2150 Community Server'
$ServerHost      = 'vpnnetserver2150.insideearth.info'
$ValueName       = 'AddressIP'
$IEPort          = 17171
$TWPort          = 17101
$InstallOpenVPN  = $true
$Repo            = 'InsideEarth2150/Files'
$Ref             = 'refs/heads/main'

# Construct the formatted registry string for IP checking
$addressIpFormatted = "`"EarthNet - InsideEARTH`"`"$ServerHost`:$IEPort`"`"EarthNet - TopWare`"`"netserver.earth2150.com:$TWPort`""

# Display Banner First
Write-Host
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   InsideEARTH - Earth 2150 Multiplayer Setup v1.0" -ForegroundColor Green
Write-Host " ===================================================" -ForegroundColor Green
Write-Host

# Registry paths to back up prior to modification
$RegistryBackupPaths = @(
    'HKCU:\SOFTWARE\Topware\Earth 2150',
    'HKCU:\SOFTWARE\Topware\TheMoonProject',
    'HKCU:\SOFTWARE\Reality Pump\LostSouls'
)

# Target game registry paths for configuration loop
$GameRegistryPaths = @(
    'HKCU:\SOFTWARE\Topware\Earth 2150\BaseGame\Network\EarthNet',
    'HKCU:\SOFTWARE\Topware\TheMoonProject\BaseGame\Network\EarthNet',
    'HKCU:\SOFTWARE\Reality Pump\LostSouls\BaseGame\Network\EarthNet'
)

# ---------- 1) OpenVPN Installation & Profile Setup -----------------
Write-Host
Write-Host " [1/4] OpenVPN Setup..." -ForegroundColor Cyan
if ($InstallOpenVPN) {
    try {
        # Check if winget is installed; if missing, silently install winget + dependencies
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host " - winget is not detected. Silently installing winget..." -ForegroundColor Yellow

            # Suppress download and installation progress bars for quiet operation
            $oldProgress = $ProgressPreference
            $ProgressPreference = 'SilentlyContinue'

            $tempDir = Join-Path $env:TEMP "WingetInstaller"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

            try {
                $vcLibsPath = Join-Path $tempDir 'VCLibs.appx'
                $uiXamlPath = Join-Path $tempDir 'UIXaml.appx'
                $wingetPath = Join-Path $tempDir 'Winget.msixbundle'

                # Download winget and its core UI/runtime dependencies
                Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile $vcLibsPath -UseBasicParsing
                Invoke-WebRequest -Uri 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx' -OutFile $uiXamlPath -UseBasicParsing
                Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' -OutFile $wingetPath -UseBasicParsing

                # Silently register AppX packages
                Add-AppxPackage -Path $vcLibsPath -ErrorAction SilentlyContinue
                Add-AppxPackage -Path $uiXamlPath -ErrorAction SilentlyContinue
                Add-AppxPackage -Path $wingetPath -ErrorAction Stop

                # Update PATH environment variable for the running process
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                Write-Host " - winget installed successfully." -ForegroundColor Green
            } finally {
                $ProgressPreference = $oldProgress
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        # Check if OpenVPN Connect is already installed
        $isInstalled = winget list --id OpenVPNTechnologies.OpenVPNConnect --exact 2>$null | Out-String

        if ($isInstalled -match 'OpenVPNConnect') {
            Write-Host " - OpenVPN Connect is already installed. Stopping running instances..." -ForegroundColor Yellow
            Stop-Process -Name "openvpnconnect", "openvpn" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
        } else {
            Write-Host " - Installing OpenVPN Connect silently via winget..." -ForegroundColor Yellow
            winget install OpenVPNTechnologies.OpenVPNConnect --accept-source-agreements --accept-package-agreements --silent | Out-Null
            Write-Host " - OpenVPN installation completed." -ForegroundColor Green
        }

        # Download the VPN profile
        $ovpnUrl  = 'https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/EarthNet/IE-2150-VPN-TCP.ovpn'
        $ovpnPath = Join-Path $env:TEMP 'IE-2150-VPN-TCP.ovpn'

        Write-Host " - Downloading OpenVPN profile configuration..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $ovpnUrl -OutFile $ovpnPath -UseBasicParsing

        # Import into OpenVPN Connect CLI
        $ovpnCli = "${env:ProgramFiles}\OpenVPN Connect\openvpnconnect.exe"
        if (Test-Path $ovpnCli) {
            Write-Host " - Checking and updating profile in OpenVPN Connect..." -ForegroundColor Yellow

            # Query existing profiles and look for matching name/ID
            $profileListJson = & "$ovpnCli" --list-profiles 2>$null | Out-String
            if ($profileListJson -match '"id":\s*"([^"]+)"') {
                $existingId = $matches[1]
                # Remove profile using OpenVPN CLI's --remove-profile flag via cmd /c redirect to capture raw C-level stdout/stderr
                cmd.exe /c "`"$ovpnCli`" --remove-profile=$existingId >nul 2>&1"
            }

            # Import new profile and suppress raw stdout/stderr output entirely
            cmd.exe /c "`"$ovpnCli`" --import-profile=`"$ovpnPath`" >nul 2>&1"

            Write-Host " - OpenVPN profile imported successfully." -ForegroundColor Green
        } else {
            Write-Host " - Profile downloaded to: $ovpnPath (Import manually in OpenVPN Connect)." -ForegroundColor Yellow
        }
    } catch {
        Write-Host " ! OpenVPN setup failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host " - Skipped OpenVPN setup per selection." -ForegroundColor DarkGray
}

# ---------- 2) Check & Update Registry Configurations -----------------
Write-Host
Write-Host " [2/4] Checking registry configurations..." -ForegroundColor Cyan

$needsRegUpdate = $false
foreach ($keyPath in $GameRegistryPaths) {
    if (-not (Test-Path $keyPath)) {
        $needsRegUpdate = $true
        break
    }
    $currentVal = (Get-ItemProperty -Path $keyPath -Name $ValueName -ErrorAction SilentlyContinue).$ValueName
    if ($currentVal -ne $addressIpFormatted) {
        $needsRegUpdate = $true
        break
    }
}

if (-not $needsRegUpdate) {
    Write-Host " - All registry entries are already configured correctly. Skipping update." -ForegroundColor DarkGray
} else {
    Write-Host " - Backing up registry keys..." -ForegroundColor Yellow
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    $timestamp = (Get-Date).ToString('yyyyMMdd-HHmmss')

    foreach ($regPath in $RegistryBackupPaths) {
        if (Test-Path $regPath) {
            $cleanName = ($regPath -replace 'HKCU:\\', 'HKCU_') -replace '[\\: ]', '_'
            $backupFile = Join-Path $desktopPath "Earth2150-Backup-$cleanName-$timestamp.reg"
            $winRegPath = $regPath -replace 'HKCU:\\', 'HKEY_CURRENT_USER\'

            Start-Process reg.exe -ArgumentList "export `"$winRegPath`" `"$backupFile`" /y" -NoNewWindow -Wait
            Write-Host " - Exported backup to: $backupFile" -ForegroundColor DarkGray
        }
    }

    foreach ($keyPath in $GameRegistryPaths) {
        try {
            if (-not (Test-Path $keyPath)) {
                New-Item -Path $keyPath -Force | Out-Null
                Write-Host " - Created registry path: $keyPath" -ForegroundColor DarkGray
            }

            $gameName = switch -Regex ($keyPath) {
                'Earth 2150'      { 'Earth 2150' }
                'TheMoonProject'  { 'The Moon Project' }
                'LostSouls'       { 'Lost Souls' }
                default           { 'Unknown Game' }
            }

            Set-ItemProperty -Path $keyPath -Name $ValueName -Value $addressIpFormatted -Type String
            Write-Host " - Updated registry entries successfully for: $gameName" -ForegroundColor Green
        } catch {
            Write-Host " ! Registry update failed for $keyPath : $_" -ForegroundColor Red
        }
    }
}

# ---------- 3) Configure Firewall Rules ------------------------------
Write-Host
Write-Host " [3/4] Configuring Windows Firewall Rules..." -ForegroundColor Cyan

$Subnet = '10.21.50.0/24'
# Windows reports /24 subnets back in mask form, so accept either spelling when comparing
$SubnetAliases = @($Subnet, '10.21.50.0/255.255.255.0')

$fwRules = @(
    @{ Name = 'Earth2150 - DirectPlay Control (TCP 47624)';   Protocol = 'TCP';    LocalPort = '47624';     RemoteAddress = $Subnet },
    @{ Name = 'Earth2150 - DirectPlay Range (TCP 2300-2400)'; Protocol = 'TCP';    LocalPort = '2300-2400'; RemoteAddress = $Subnet },
    @{ Name = 'Earth2150 - DirectPlay Range (UDP 2300-2400)'; Protocol = 'UDP';    LocalPort = '2300-2400'; RemoteAddress = $Subnet },
    @{ Name = 'Earth2150 - ICMPv4 Allow Subnet';              Protocol = 'ICMPv4'; RemoteAddress = $Subnet }
)

function Set-Earth2150FirewallRules {
    param($rules)
    foreach ($r in $rules) {
        Get-NetFirewallRule -DisplayName $r.Name -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue

        $params = @{
            DisplayName   = $r.Name
            Direction     = 'Inbound'
            Action        = 'Allow'
            Protocol      = $r.Protocol
            Profile       = 'Any'
            RemoteAddress = $r.RemoteAddress
        }
        if ($r.LocalPort) { $params['LocalPort'] = $r.LocalPort }

        New-NetFirewallRule @params | Out-Null
    }
}

# Check if rules exist, are enabled, AND match the target subnet scope
$needsFwUpdate = $false
foreach ($r in $fwRules) {
    $existingRule = Get-NetFirewallRule -DisplayName $r.Name -ErrorAction SilentlyContinue
    if (-not $existingRule -or (@($existingRule | Where-Object { $_.Enabled -ne 'True' }).Count -gt 0)) {
        $needsFwUpdate = $true
        break
    }

    $existingScope = @($existingRule | Get-NetFirewallAddressFilter)[0]
    $existingAddr  = @($existingScope.RemoteAddress)[0]
    if ($SubnetAliases -notcontains $existingAddr) {
        $needsFwUpdate = $true
        break
    }
}

if (-not $needsFwUpdate) {
    Write-Host " - All firewall rules and subnet scopes are already configured correctly. Skipping." -ForegroundColor DarkGray
} else {
    try {
        # Script self-elevates at the top, so we are always admin here
        Set-Earth2150FirewallRules -rules $fwRules
        Write-Host " - Firewall rules and subnet scope applied successfully." -ForegroundColor Green
    } catch {
        Write-Host " ! Firewall setup failed: $_" -ForegroundColor Red
    }
}

# ---------- 4) Configure DirectPlay ------------------------------
Write-Host
Write-Host " [4/4] Configuring DirectPlay..." -ForegroundColor Cyan

try {
    # Query the DirectPlay feature state
    $dpFeature = Get-WindowsOptionalFeature -Online -FeatureName DirectPlay -ErrorAction Stop

    if ($dpFeature.State -ne 'Enabled') {
        Write-Host " - DirectPlay is disabled. Enabling Windows DirectPlay..." -ForegroundColor Yellow

        # Enable DirectPlay without forcing a restart
        Enable-WindowsOptionalFeature -Online -FeatureName DirectPlay -All -NoRestart | Out-Null

        Write-Host " - DirectPlay feature enabled successfully." -ForegroundColor Green
    } else {
        Write-Host " - DirectPlay feature is already enabled." -ForegroundColor DarkGray
    }
} catch {
    Write-Host " ! Failed to verify or enable DirectPlay: $_" -ForegroundColor Red
}

# ---------- Complete -------------------------------------------------
Write-Host
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   Setup complete. Launch Earth 2150 and Enjoy!" -ForegroundColor Green
Write-Host " ===================================================" -ForegroundColor Green
Write-Host

Read-Host "Press Enter to exit..."