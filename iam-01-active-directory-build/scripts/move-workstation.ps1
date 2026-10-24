# Moves CLIENT01 out of the default Computers container and into the Workstations OU
Get-ADComputer CLIENT01 | Move-ADObject -TargetPath "OU=Workstations,OU=CedarRidge,DC=cedarridge,DC=local"

Write-Host "`n=== CLIENT01 in AD ===" -ForegroundColor Cyan
Get-ADComputer CLIENT01 -Properties OperatingSystem, IPv4Address, whenCreated |
    Format-List Name, DNSHostName, OperatingSystem, IPv4Address, DistinguishedName, whenCreated
