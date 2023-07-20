if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

##
write-host "== Checking Firewall Rules=="
$firewallProtocolTCP = "TCP"
$firewallPortTCP = "47624,2300-2400"
$firewallRuleNameTCP = "Earth2150_DirectPlay_TCP"

write-host "  Checking for '$firewallRuleNameTCP' firewall rule with protocol '$firewallProtocolTCP' now...."
if ($(Get-NetFirewallRule -DisplayName $firewallRuleNameTCP | Get-NetFirewallPortFilter | Where { $_.Protocol -eq $firewallProtocolTCP }))
{
write-host "  Firewall rule for '$firewallRuleNameTCP' with '$firewallProtocolTCP' Protocol already exists, not creating new rule"
}
else
{
write-host "  Firewall rule for '$firewallRuleNameTCP' with '$firewallProtocolTCP' Protocol does not already exist, creating new rule now..."
New-NetFirewallRule -DisplayName $firewallRuleNameTCP -Direction Inbound -Profile Domain,Private,Public -Action Allow -Protocol $firewallProtocolTCP -LocalPort 47624,2300-2400 -RemoteAddress Any
write-host "  Firewall rule for '$firewallRuleNameTCP' with '$firewallProtocolTCP' Protocol created successfully"
};

$firewallProtocolUDP = "UDP"
$firewallPortUDP = "47624,2300-2400"
$firewallRuleNameUDP = "Earth2150_DirectPlay_UDP"

write-host "  Checking for '$firewallRuleNameUDP' firewall rule with protocol '$firewallProtocolUDP' now...."
if ($(Get-NetFirewallRule -DisplayName $firewallRuleNameUDP | Get-NetFirewallPortFilter | Where { $_.Protocol -eq $firewallProtocolUDP }))
{
write-host "  Firewall rule for '$firewallRuleNameUDP' with '$firewallProtocolUDP' Protocol already exists, not creating new rule"
}
else
{
write-host "  Firewall rule for '$firewallRuleNameUDP' with '$firewallProtocolUDP' Protocol does not already exist, creating new rule now..."
New-NetFirewallRule -DisplayName $firewallRuleNameUDP -Direction Inbound -Profile Domain,Private,Public -Action Allow -Protocol $firewallProtocolUDP -LocalPort 47624,2300-2400 -RemoteAddress Any
write-host "  Firewall rule for '$firewallRuleNameUDP' with '$firewallProtocolUDP' Protocol created successfully"
};

##
write-host ""
write-host "== Checking Network Profiles =="

$NetworkCategoryOLD = "Public"
$NetworkCategoryNEW = "Private"
$NetConnectionProfileName = "OpenVPN"
$NetConnectionProfileNameSearch = "OpenVPN*"

write-host "  Checking for '$NetConnectionProfileName' Profile now...."
if ($(Get-NetConnectionProfile -InterfaceAlias $NetConnectionProfileNameSearch | Where { $_.NetworkCategory -eq $NetworkCategoryNEW }))
{
write-host "  '$NetConnectionProfileName' with '$NetworkCategoryNEW' profile already exists, not adjusting"
}
else
{
write-host "  '$NetConnectionProfileName' with '$NetworkCategoryNEW' profile does not already exist, updating now..."
Get-NetConnectionProfile -InterfaceAlias $NetConnectionProfileNameSearch | Set-NetConnectionProfile -NetworkCategory $NetworkCategoryNEW
write-host "  '$NetConnectionProfileName' with '$NetworkCategoryOLD' profile successfully updated to '$NetworkCategoryNEW' profile."
};

##
write-host ""
write-host "== Checking UPNP Service Status =="

$ServiceName = "upnphost"
$ServiceStatusOLD = "Running"
$ServiceStatusNew = "Stopped"

write-host "  Checking for '$ServiceName' running status now...."
if ($(Get-Service -Name $ServiceName | Where { $_.Status -eq $ServiceStatusNEW }))
{
write-host "  '$ServiceName' with status '$ServiceStatusNew' found, not adjusting"
}
else
{
write-host "  '$ServiceName' with status '$ServiceStatusNew' not found, updating now..."
Stop-Service -Name upnphost
write-host "  '$ServiceName' with status '$ServiceStatusOLD' successfully updated to '$ServiceStatusNEW'."
};

$ServiceName = "upnphost"
$StartupTypeOLD = "Automatic"
$StartupTypeNew = "Disabled"

write-host "  Checking for '$ServiceName' startup setting now...."
if ($(Get-Service -Name $ServiceName | Where { $_.starttype -eq $StartupTypeNEW }))
{
write-host "  '$ServiceName' with startup setting '$StartupTypeNew' found, not adjusting"
}
else
{
write-host "  '$ServiceName' with startup setting '$StartupTypeNew' not found, updating now..."
Set-Service -Name $ServiceName -StartupType $StartupTypeNew
write-host "  '$ServiceName' with startup setting '$StartupTypeOLD' successfully updated to '$StartupTypeNEW'."
};

##
write-host ""
Write-Host ">>>> Press any key when you have connected to IE-VPN <<<<"
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
write-host "== Checking DNS resolution and connectivity to EarthNet =="
ping vpnnetserver.insideearth.info

write-host " = Configuration & Tests Completed"
write-host ""
Write-Host ">>>> If no errors (in RED) shown above, all configurations completed successfully <<<<"
Write-Host -NoNewLine 'Press any key to close.';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');