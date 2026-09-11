# =====================================================================
#   InsideEARTH - Earth 2150 Multiplayer - one-click setup
#
#   Two steps, no admin, no manual input
#     1) adds the community server to the game's server list
#        (per-user registry HKCU, makes a .reg backup first)
#     2) installs + activates the MP DirectPlay8 replacement DLL
#        (per-user COM registration under WOW6432Node - no admin), so the
#        game's multiplayer sessions no longer depend on the flaky Windows
#        DirectPlay component.
#
#   Meant to be fetched from GitHub and run
#     powershell -ExecutionPolicy Bypass -Command iex (irm https://raw.githubusercontent.com/InsideEarth2150/Files/refs/heads/main/EarthNet/Earth2150-MP-Setup.ps1)
#   or just double-click IE-E2150-MP-Setup.bat.
#
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
$addressIpFormatted = "`"EarthNet - InsideEARTH`"`"`"$ServerHost`:$IEPort`"`"`"EarthNet - TopWare`"`"`"netserver.earth2150.com:$TWPort`"`""

# Display Banner First
Write-Host 
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   InsideEARTH - Earth 2150 MP community server setup" -ForegroundColor Green
Write-Host "   Server: $Name" -ForegroundColor Green
Write-Host "   Host: $ServerHost" -ForegroundColor Green
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

# DirectPlay8 CLSIDs
$Clsids = [ordered]@{
    '{286F484D-375E-4458-A272-B138E2F80A6A}' = 'DirectPlay8Peer'
    '{934A9523-A3CA-4BC5-ADA0-D6D95D979421}' = 'DirectPlay8Address'
}
$DllDir = Join-Path $env:LOCALAPPDATA 'MP'
$Dll    = Join-Path $DllDir 'dpnetreplace.dll'
$DllUrl = "https://raw.githubusercontent.com/$Repo/$Ref/directplay-replace/dpnetreplace.dll"

# ---------- 1) OpenVPN Installation & Profile Setup -----------------
Write-Host 
Write-Host " [1/4] OpenVPN Setup..." -ForegroundColor Cyan
if ($InstallOpenVPN) {
    try {
        # Ensure OpenVPN is not running during profile import
        Write-Host " - Stopping OpenVPN processes if running..." -ForegroundColor Yellow
        Stop-Process -Name "openvpnconnect", "openvpn" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1

        # Check if OpenVPN Connect is already installed
        $isInstalled = winget list --id OpenVPNTechnologies.OpenVPNConnect --exact 2>$null | Out-String
        if ($isInstalled -match 'OpenVPNConnect') {
            Write-Host " - OpenVPN Connect is already installed. Skipping installation." -ForegroundColor DarkGray
        } else {
            Write-Host " - Installing OpenVPN Connect silently..." -ForegroundColor Yellow
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
            Write-Host " - Importing profile into OpenVPN Connect..." -ForegroundColor Yellow
            
            # Delete existing profile first and pipe everything to Out-Null
            $profileName = "vpn-2150.insideearth.info [IE-2150-VPN-TCP]"
            & "$ovpnCli" --delete-profile="$profileName" 2>&1 | Out-Null

            # Import new profile and completely discard any resulting text
            & "$ovpnCli" --import-profile="$ovpnPath" 2>&1 | Out-Null

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
    $timestamp   = (Get-Date).ToString('yyyyMMdd-HHmmss')

    foreach ($regPath in $RegistryBackupPaths) {
        if (Test-Path $regPath) {
            $cleanName = ($regPath -replace 'HKCU:\\', 'HKCU_') -replace '[\\:]', '_'
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

$fwRules = @(
    @{ Name = 'Earth2150 - DirectPlay Control (TCP 47624)'; Protocol = 'TCP'; LocalPort = '47624' },
    @{ Name = 'Earth2150 - DirectPlay Range (TCP 2300-2400)'; Protocol = 'TCP'; LocalPort = '2300-2400' },
    @{ Name = 'Earth2150 - DirectPlay Range (UDP 2300-2400)'; Protocol = 'UDP'; LocalPort = '2300-2400' }
)

# Check if all firewall rules exist and are enabled
$needsFwUpdate = $false
foreach ($r in $fwRules) {
    $existingRule = Get-NetFirewallRule -DisplayName $r.Name -ErrorAction SilentlyContinue
    if (-not $existingRule -or $existingRule.Enabled -ne 'True') {
        $needsFwUpdate = $true
        break
    }
}

if (-not $needsFwUpdate) {
    Write-Host " - All firewall rules are already configured correctly. Skipping." -ForegroundColor DarkGray
} else {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    $applyFwScript = {
        param($rules)
        foreach ($r in $rules) {
            Get-NetFirewallRule -DisplayName $r.Name -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.Name -Direction Inbound -Action Allow -Protocol $r.Protocol -LocalPort $r.LocalPort -Profile Any | Out-Null
        }
    }

    try {
        if ($isAdmin) {
            & $applyFwScript $fwRules
            Write-Host " - Firewall rules set successfully." -ForegroundColor Green
        } else {
            Write-Host " - Requesting Admin permissions for Firewall configuration..." -ForegroundColor Yellow
            $jsonRules = $fwRules | ConvertTo-Json -Compress
            $innerCmd = "`$rules = '$jsonRules' | ConvertFrom-Json; foreach (`$r in `$rules) { Get-NetFirewallRule -DisplayName `$r.Name -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue; New-NetFirewallRule -DisplayName `$r.Name -Direction Inbound -Action Allow -Protocol `$r.Protocol -LocalPort `$r.LocalPort -Profile Any | Out-Null }"
            $encCmd = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($innerCmd))
            Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile','-WindowStyle','Hidden','-EncodedCommand',$encCmd
            Write-Host " - Firewall rules applied." -ForegroundColor Green
        }
    } catch {
        Write-Host " ! Firewall setup failed: $_" -ForegroundColor Red
    }
}

# ---------- 4) DirectPlay Replacement & Optional Feature Handling -----------
Write-Host 
Write-Host " [4/4] DirectPlay Handling..." -ForegroundColor Cyan

# Check if DirectPlay replacement DLL is currently registered
$dpClsidKey = 'HKCU:\Software\Classes\WOW6432Node\CLSID\{286F484D-375E-4458-A272-B138E2F80A6A}'
$isDpInstalled = Test-Path $dpClsidKey

# Interactive Prompts
$Remove = $false
$SkipDP = $false

if ($env:MP_REMOVE -eq '1') {
    $Remove = $true
    $SkipDP = $true
} elseif ($env:MP_SKIP_DIRECTPLAY -eq '1') {
    $SkipDP = $true
} else {
    if ($isDpInstalled) {
        $removeInput = Read-Host " - DirectPlay replacement is already installed. Do you wish to Remove it? (y/N)"
        $Remove = ($removeInput -eq 'y' -or $removeInput -eq 'yes')
        if (-not $Remove) {
            $SkipDP = $true
        }
    } else {
        $installInput = Read-Host " - Do you wish to Install the DirectPlay replacement? (Y/n)"
        $InstallDP = ($installInput -eq '' -or $installInput -eq 'y' -or $installInput -eq 'yes')
        $SkipDP = (-not $InstallDP)
    }
}

if ($Remove) {
    Write-Host " - Removing DirectPlay Replacement..." -ForegroundColor Yellow
    foreach ($id in $Clsids.Keys) {
        $parent = "HKCU:\Software\Classes\WOW6432Node\CLSID\$id"
        if (Test-Path $parent) { Remove-Item $parent -Recurse -Force; Write-Host " - Removed $($Clsids[$id])" -ForegroundColor Green }
    }
} elseif ($SkipDP) {
    Write-Host " - Replacement skipped." -ForegroundColor DarkGray
    
    # Check/enable native Windows DirectPlay ONLY if replacement DLL was skipped and isn't installed
    if (-not $isDpInstalled) {
        Write-Host " - Checking Windows Optional Feature: DirectPlay..." -ForegroundColor Cyan
        try {
            $dpFeature = Get-WindowsOptionalFeature -Online -FeatureName DirectPlay -ErrorAction Stop
            if ($dpFeature.State -ne 'Enabled') {
                Write-Host " - DirectPlay feature is disabled. Enabling Windows DirectPlay..." -ForegroundColor Yellow
                Enable-WindowsOptionalFeature -Online -FeatureName DirectPlay -All -NoRestart | Out-Null
                Write-Host " - Windows DirectPlay feature enabled successfully." -ForegroundColor Green
            } else {
                Write-Host " - Windows DirectPlay feature is already enabled." -ForegroundColor DarkGray
            }
        } catch {
            Write-Host " ! Failed to verify/enable Windows DirectPlay feature: $_" -ForegroundColor Red
        }
    }
} else {
    # Installing DirectPlay replacement - Native Windows DirectPlay feature check is skipped here
    try {
        New-Item -ItemType Directory -Force -Path $DllDir | Out-Null
        Invoke-WebRequest -Uri $DllUrl -OutFile $Dll -UseBasicParsing
        $len = (Get-Item $Dll).Length
        if ($len -lt 4096) { throw "DLL download invalid ($len bytes)" }
        try { Unblock-File -Path $Dll -ErrorAction SilentlyContinue } catch {}

        foreach ($id in $Clsids.Keys) {
            $key = "HKCU:\Software\Classes\WOW6432Node\CLSID\$id\InprocServer32"
            if (-not (Test-Path $key)) { New-Item $key -Force | Out-Null }
            Set-ItemProperty $key -Name '(default)'      -Value $Dll
            Set-ItemProperty $key -Name 'ThreadingModel' -Value 'Both'
            Write-Host " - Registered $($Clsids[$id])" -ForegroundColor Green
        }
    } catch {
        Write-Host " ! DLL Replacement failed: $_" -ForegroundColor Red
    }
}

# ---------- Complete -------------------------------------------------
Write-Host 
Write-Host " ===================================================" -ForegroundColor Green
Write-Host "   Setup complete. Launch Earth 2150 and Enjoy!" -ForegroundColor Green
Write-Host " ===================================================" -ForegroundColor Green
Write-Host

Read-Host "Press Enter to exit..."
