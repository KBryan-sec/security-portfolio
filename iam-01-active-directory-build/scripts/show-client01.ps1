# Shows where CLIENT01's computer account lives in AD and what it reports back
Get-ADComputer CLIENT01 -Properties OperatingSystem, IPv4Address |
    Format-List Name, DNSHostName, OperatingSystem, IPv4Address, DistinguishedName
