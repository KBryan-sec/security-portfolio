# Quick health check on DC01
Clear-Host
hostname
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, DomainMode, PDCEmulator | Format-List
Get-ADDomainController | Select-Object Name, IPv4Address, Site, IsGlobalCatalog | Format-List
ipconfig /all | Select-String "IPv4|Subnet|DNS Servers"
