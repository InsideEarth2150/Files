if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

powershell -c "New-NetFirewallRule -DisplayName "Earth2150_DirectPlay__TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 47624,2300-2400"
powershell -c "New-NetFirewallRule -DisplayName "Earth2150_DirectPlay__UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 47624,2300-2400"
##powershell -c "New-NetFirewallRule -DisplayName "Earth2150_DirectPlay_TCP" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 47624,2300-2400"
##powershell -c "New-NetFirewallRule -DisplayName "Earth2150_DirectPlay_UDP" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol UDP -LocalPort 47624,2300-2400"
##powershell -c "Get-NetConnectionProfile -InterfaceAlias "Ethernet*" | Set-NetConnectionProfile -NetworkCategory Private"
powershell -c "Get-NetConnectionProfile -InterfaceAlias "OpenVPN*" | Set-NetConnectionProfile -NetworkCategory Private"
powershell -c "Stop-Service -Name upnphost"
powershell -c "Set-Service -Name upnphost -StartupType Disabled"

Write-Host "If no errors (in RED) shown above, all configurations completed successfully"
Write-Host "This window will close in 5 seconds"
Start-Sleep -Seconds 5