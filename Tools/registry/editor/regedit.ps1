# =====================================================================
#    InsideEARTH - Earth 2150 Registry Editor v1.2
# =====================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Self-elevation check to run as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host

$host.UI.RawUI.WindowTitle = "InsideEARTH - Earth 2150 Tools & Utilities Launcher v1.1"
$ErrorActionPreference = 'Stop'

# Define game configurations with both HKCU and HKLM paths
$games = @(
    @{ 
        Name  = "Earth 2150"
        Paths = @(
            "HKCU:\Software\Topware\Earth 2150\BaseGame\FileSystem",
            "HKLM:\Software\WOW6432Node\Topware\Earth 2150\BaseGame\FileSystem"
        ) 
    },
    @{ 
        Name  = "The Moon Project"
        Paths = @(
            "HKCU:\Software\Topware\TheMoonProject\BaseGame\FileSystem",
            "HKLM:\Software\WOW6432Node\Topware\TheMoonProject\BaseGame\FileSystem"
        ) 
    },
    @{ 
        Name  = "Lost Souls"
        Paths = @(
            "HKCU:\Software\Reality Pump\LostSouls\BaseGame\FileSystem",
            "HKLM:\Software\WOW6432Node\Reality Pump\LostSouls\BaseGame\FileSystem"
        ) 
    }
)

function Show-GameMenu {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host "   InsideEARTH - Earth 2150 Tools & Utilities Menu" -ForegroundColor Green
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Select an option to configure registry paths:" -ForegroundColor White
    for ($i = 0; $i -lt $games.Count; $i++) {
        Write-Host "    [$($i + 1)]$($games[$i].Name)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "    [$($games.Count + 1)] Exit" -ForegroundColor Red
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

    Write-Host "Current Registry Information (HKCU & HKLM):" -ForegroundColor Cyan
    
    foreach ($path in$RegPaths) {
        Write-Host "  [$path]" -ForegroundColor DarkGray
        try {
            if (Test-Path -Path $path) {
                $currentDatapath = (Get-ItemProperty -Path$path -Name "datapath" -ErrorAction SilentlyContinue).datapath
                $currentOutputDir = (Get-ItemProperty -Path$path -Name "OutputDir" -ErrorAction SilentlyContinue).OutputDir
            } else {
                $currentDatapath =$null
                $currentOutputDir =$null
            }

            Write-Host "     datapath  : $(if ($currentDatapath) {$currentDatapath } else { '(not set)' })" -ForegroundColor White
            Write-Host "     OutputDir : $(if ($currentOutputDir) {$currentOutputDir } else { '(not set)' })" -ForegroundColor White
        } catch {
            Write-Host "    [!] Could not access registry path: $_" -ForegroundColor Red
        }
    }
    Write-Host ""

    $choice = Read-Host "Do you wish to edit these values for both locations? (y/n)"
    if ($choice -eq 'y' -or$choice -eq 'Y') {
        Write-Host ""
        $fullPath = Read-Host "Enter the full file path (e.g., G:\Games\Steam\steamapps\common\GameName)"
        
        if ([string]::IsNullOrWhiteSpace($fullPath)) {
            Write-Host "Path cannot be empty." -ForegroundColor Red
            Start-Sleep -Seconds 2
            return
        }

        # Clean trailing slashes and append required Earth 2150 datapath suffix
        $cleanPath =$fullPath.TrimEnd('/', '\')
        $newDatapath = "$cleanPath\>"
        $newOutputDir =$cleanPath

        foreach ($path in$RegPaths) {
            try {
                # Create registry key folder hierarchy ONLY if it does not exist yet
                if (-not (Test-Path -Path $path)) {
                    $null = New-Item -Path$path -Force
                }

                # Target ONLY datapath and OutputDir explicitly
                Set-ItemProperty -Path $path -Name "datapath" -Value $newDatapath -Type String -Force
                Set-ItemProperty -Path $path -Name "OutputDir" -Value $newOutputDir -Type String -Force

            } catch {
                Write-Host "    [!] Failed to update $path :$_" -ForegroundColor Red
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
    $maxOption = $games.Count + 1$selection = Read-Host "Enter option (1-$maxOption)"
    
    switch ($selection) {
        '1' { Edit-RegistryValues -GameName $games[0].Name -RegPaths$games[0].Paths }
        '2' { Edit-RegistryValues -GameName $games[1].Name -RegPaths$games[1].Paths }
        '3' { Edit-RegistryValues -GameName $games[2].Name -RegPaths$games[2].Paths }
        "$maxOption" { exit }
        default { 
            Write-Host ""
            Write-Host "Invalid selection. Press any key to try again..." -ForegroundColor Red
            $null =$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($true)