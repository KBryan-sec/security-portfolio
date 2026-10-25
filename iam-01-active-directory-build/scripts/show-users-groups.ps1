# Lists every CedarRidge user with department and title, then each GG_ group and its members
Get-ADUser -Filter * -SearchBase "OU=Users,OU=CedarRidge,DC=cedarridge,DC=local" -Properties Department, Title |
    Select-Object Name, SamAccountName, Department, Title |
    Sort-Object Department |
    Format-Table -AutoSize

Get-ADGroup -Filter 'Name -like "GG_*"' | Sort-Object Name | ForEach-Object {
    $members = (Get-ADGroupMember $_ | Select-Object -ExpandProperty SamAccountName) -join ", "
    "{0,-16}: {1}" -f $_.Name, $members
}
