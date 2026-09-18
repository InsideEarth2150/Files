# =====================================================================
#   InsideEARTH - Earth 2150 Registry Editor v1.1
# =====================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Self-elevation check to run as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

clear

$host.ui.RawUI.WindowTitle = "InsideEARTH - Earth 2150 Registry Editor v1.0"
$ErrorActionPreference = 'Stop'

# Define game configurations with both HKCU and HKLM paths
$games = @(
    @{ 
        Name = "Earth 2150"; 
        Paths = @(
            "HKCU:\Software\Topware\TheMoonProject\BaseGame\FileSystem",
            "HKLM:\SOFTWARE\WOW6432Node\Topware\TheMoonProject\BaseGame\FileSystem"
        ) 
    },
    @{ 
        Name = "The Moon Project"; 
        Paths = @(
            "HKCU:\Software\Topware\TheMoonProject\BaseGame\FileSystem",
            "HKLM:\SOFTWARE\WOW6432Node\Topware\TheMoonProject\BaseGame\FileSystem"
        ) 
    },
    @{ 
        Name = "Lost Souls"; 
        Paths = @(
            "HKCU:\Software\Reality Pump\LostSouls\BaseGame\FileSystem",
            "HKLM:\SOFTWARE\WOW6432Node\Reality Pump\LostSouls\BaseGame\FileSystem"
        ) 
    }
)

function Show-GameMenu {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host "   InsideEARTH - Earth 2150 Registry Editor v1.0" -ForegroundColor Green
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Select an option to configure registry paths:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $games.Count; $i++) {
        Write-Host "   [$($i + 1)]$($games[$i].Name)" -ForegroundColor White
    }
    Write-Host "   [$($games.Count + 1)] Exit" -ForegroundColor White
    Write-Host ""
}

function Edit-RegistryValues {
    param(
        [string]$GameName,
        [string[]]$RegPaths
    )

    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host "   InsideEARTH - $GameName Registry Configuration" -ForegroundColor Green
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host ""

    # Display current information from the first path as a reference
    $referencePath =$RegPaths[0]
    if (-not (Test-Path $referencePath)) {
        New-Item -Path $referencePath -Force | Out-Null
    }

    $currentDatapath = (Get-ItemProperty -Path$referencePath -Name "datapath" -ErrorAction SilentlyContinue).datapath
    $currentOutputDir = (Get-ItemProperty -Path$referencePath -Name "OutputDir" -ErrorAction SilentlyContinue).OutputDir

    Write-Host "Current Registry Information (Reference):" -ForegroundColor Cyan
    Write-Host "  datapath  : $(if ($currentDatapath) {$currentDatapath } else { '(not set)' })" -ForegroundColor White
    Write-Host "  OutputDir : $(if ($currentOutputDir) {$currentOutputDir } else { '(not set)' })" -ForegroundColor White
    Write-Host ""

    $choice = Read-Host "Do you wish to update these values for all registry locations? (y/n)"
    if ($choice -eq 'y' -or$choice -eq 'Y') {
        Write-Host ""
        $fullPath = Read-Host "Enter the full file path (e.g., G:\Games\Steam\steamapps\common\GameName)"
        
        # Clean trailing slashes to format properly matching the expected pattern
        $cleanPath =$fullPath.TrimEnd('/').TrimEnd('\')
        $newDatapath = "$cleanPath\>"
        $newOutputDir =$cleanPath

        foreach ($RegPath in $RegPaths) {
            Write-Host "Processing path: $RegPath" -ForegroundColor DarkGray
            
            # Ensure registry path exists
            if (-not (Test-Path $RegPath)) {
                New-Item -Path $RegPath -Force | Out-Null
            }

            # Apply changes for datapath
            if (Get-ItemProperty -Path $RegPath -Name "datapath" -ErrorAction SilentlyContinue) {
                Set-ItemProperty -Path $RegPath -Name "datapath" -Value $newDatapath
            } else {
                New-ItemProperty -Path $RegPath -Name "datapath" -Value $newDatapath -PropertyType String | Out-Null
            }

            # Apply changes for OutputDir
            if (Get-ItemProperty -Path $RegPath -Name "OutputDir" -ErrorAction SilentlyContinue) {
                Set-ItemProperty -Path $RegPath -Name "OutputDir" -Value $newOutputDir
            } else {
                New-ItemProperty -Path $RegPath -Name "OutputDir" -Value $newOutputDir -PropertyType String | Out-Null
            }
        }

        Write-Host ""
        Write-Host "Changes successfully applied to all targets!" -ForegroundColor Green
        Write-Host "Updated Registry Information:" -ForegroundColor Cyan
        Write-Host "  datapath  : $newDatapath" -ForegroundColor White
        Write-Host "  OutputDir : $newOutputDir" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "Press any key to return to the main menu..." -ForegroundColor DarkGray
    $null =$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main loop
do {
    Show-GameMenu
    $maxOption = $games.Count + 1
    $selection = Read-Host "Enter option (1-$maxOption)"
    
    switch ($selection) {
        '1' { Edit-RegistryValues -GameName $games[0].Name -RegPaths$games[0].Paths }
        '2' { Edit-RegistryValues -GameName $games[1].Name -RegPaths$games[1].Paths }
        '3' { Edit-RegistryValues -GameName $games[2].Name -RegPaths$games[2].Paths }
        '4' { exit }
        default { 
            Write-Host ""
            Write-Host "Invalid selection. Press any key to try again..." -ForegroundColor Red
            $null =$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($true)