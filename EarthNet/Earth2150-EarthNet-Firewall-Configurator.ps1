if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

##
write-host "== Checking Firewall Rules =="

# TCP Firewall Rule
$firewallProtocolTCP = "TCP"
$firewallPortTCP = @('47624','2300-2400')
$firewallRuleNameTCP = "Earth2150_DirectPlay_TCP"

write-host "  Checking for '$firewallRuleNameTCP' firewall rule with protocol '$firewallProtocolTCP' now...."
if ($(Get-NetFirewallRule -DisplayName $firewallRuleNameTCP | Get-NetFirewallPortFilter | Where { $_.Protocol -eq $firewallProtocolTCP }))
{
    write-host "  Firewall rule for '$firewallRuleNameTCP' with '$firewallProtocolTCP' Protocol already exists, not creating new rule"
}
else
{
    write-host "  Firewall rule for '$firewallRuleNameTCP' with '$firewallProtocolTCP' Protocol does not already exist, creating new rule now..."
    New-NetFirewallRule -DisplayName $firewallRuleNameTCP -Direction Inbound -Profile Domain,Private,Public -Action Allow -Protocol $firewallProtocolTCP -LocalPort $firewallPortTCP -RemoteAddress Any
    write-host "  Firewall rule for '$firewallRuleNameTCP' with '$firewallProtocolTCP' Protocol created successfully"
}

# UDP Firewall Rule
$firewallProtocolUDP = "UDP"
$firewallPortUDP = @('47624','2300-2400')
$firewallRuleNameUDP = "Earth2150_DirectPlay_UDP"

write-host "  Checking for '$firewallRuleNameUDP' firewall rule with protocol '$firewallProtocolUDP' now...."
if ($(Get-NetFirewallRule -DisplayName $firewallRuleNameUDP | Get-NetFirewallPortFilter | Where { $_.Protocol -eq $firewallProtocolUDP }))
{
    write-host "  Firewall rule for '$firewallRuleNameUDP' with '$firewallProtocolUDP' Protocol already exists, not creating new rule"
}
else
{
    write-host "  Firewall rule for '$firewallRuleNameUDP' with '$firewallProtocolUDP' Protocol does not already exist, creating new rule now..."
    New-NetFirewallRule -DisplayName $firewallRuleNameUDP -Direction Inbound -Profile Domain,Private,Public -Action Allow -Protocol $firewallProtocolUDP -LocalPort $firewallPortUDP -RemoteAddress Any
    write-host "  Firewall rule for '$firewallRuleNameUDP' with '$firewallProtocolUDP' Protocol created successfully"
}

# ICMP Firewall Rule for 10.21.0.0/23
$firewallRuleNameICMP = "EarthNet_Allow_ICMP_from_10.21.0.0/23"
write-host "  Checking for '$firewallRuleNameICMP' firewall rule now...."
if ($(Get-NetFirewallRule -DisplayName $firewallRuleNameICMP | Where { $_.Protocol -eq "ICMPv4" }))
{
    write-host "  Firewall rule for '$firewallRuleNameICMP' already exists, not creating new rule"
}
else
{
    write-host "  Firewall rule for '$firewallRuleNameICMP' does not already exist, creating new rule now..."
    New-NetFirewallRule -DisplayName $firewallRuleNameICMP -Direction Inbound -Action Allow -Protocol ICMPv4 -RemoteAddress 10.21.0.0/23
    write-host "  Firewall rule for '$firewallRuleNameICMP' created successfully"
}

# DirectPlay Helper Firewall Rule
$firewallRuleNameDPS = "Allow dplaysvr Inbound"
write-host "  Checking for '$firewallRuleNameDPS' firewall rule now...."
if ($(Get-NetFirewallRule -DisplayName $firewallRuleNameDPS }))
{
    write-host "  Firewall rule for '$firewallRuleNameDPS' already exists, not creating new rule"
}
else
{
    write-host "  Firewall rule for '$firewallRuleNameDPS' does not already exist, creating new rule now..."
    New-NetFirewallRule -DisplayName $firewallRuleNameDPS -Direction Inbound -Program "%windir%\syswow64\dplaysvr.exe" -Profile Private,Public -Action Allow
    write-host "  Firewall rule for '$firewallRuleNameDPS' created successfully"
}