# Swap the Systems Administrator account from the placeholder (Sam Carter) to Karon Bryan.
# Same account, same group, same OU. Only the identity details change.
Get-ADUser scarter | Rename-ADObject -NewName "Karon Bryan"
Set-ADUser scarter -GivenName "Karon" -Surname "Bryan" -DisplayName "Karon Bryan" -UserPrincipalName "kbryan@cedarridge.local" -SamAccountName "kbryan"
Clear-Host
Get-ADUser -Filter * -SearchBase "OU=Users,OU=CedarRidge,DC=cedarridge,DC=local" -Properties Title,Department | Select-Object Name,SamAccountName,Department,Title | Format-Table -AutoSize
foreach ($g in "GG_Clinical","GG_Billing","GG_FrontDesk","GG_IT_HelpDesk") {
    "$g : " + ((Get-ADGroupMember $g | Select-Object -ExpandProperty SamAccountName) -join ", ")
}
