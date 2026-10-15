# 01-configure-network.ps1

# Purpose: give DC01 a permanent (static) IP on LabNet and a proper hostname
# Run on: DC01, in Powershell as Administrator
# Before running: confirm the adapter name with Get-NetAdapter

# Static IP: 10.0.2.10 on the 10.0.2.0/24 network, using LabNet gateway
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.2.10 -PrefixLength 24 -DefaultGateway 10.0.2.1

# DNS points at DC01 itself (127.0.0.1), because DC01 becomes the DNS server in Phase 4
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1

#Rename the computer and restart so the new name takes effect
Rename-Computer -NewName "DC01" -Restart