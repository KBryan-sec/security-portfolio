# IAM Lab 1: build the Cedar Ridge Clinic directory
# Run on DC01 as CEDARRIDGE\Administrator
# Creates the OU tree, security groups, and 8 fictional employees, then adds each to their department group.

Import-Module ActiveDirectory
$domain = "DC=cedarridge,DC=local"
$root   = "OU=CedarRidge,$domain"

# OU tree
New-ADOrganizationalUnit -Name "CedarRidge" -Path $domain
foreach ($ou in "Users","Groups","Workstations","Service Accounts","Disabled Accounts") {
    New-ADOrganizationalUnit -Name $ou -Path $root
}
foreach ($dept in "Clinical","Billing","FrontDesk","IT") {
    New-ADOrganizationalUnit -Name $dept -Path "OU=Users,$root"
}

# Security groups (GG_ = global group)
foreach ($g in "GG_Clinical","GG_Billing","GG_FrontDesk","GG_IT_HelpDesk") {
    New-ADGroup -Name $g -GroupScope Global -GroupCategory Security -Path "OU=Groups,$root"
}

# Employees: first, last, title, department OU, group
$people = @(
    @("Maria","Reyes","Registered Nurse","Clinical","GG_Clinical"),
    @("David","Okafor","Medical Assistant","Clinical","GG_Clinical"),
    @("Priya","Shah","Billing Specialist","Billing","GG_Billing"),
    @("Tom","Becker","Billing Manager","Billing","GG_Billing"),
    @("Lena","Park","Patient Coordinator","FrontDesk","GG_FrontDesk"),
    @("Marcus","Hill","Receptionist","FrontDesk","GG_FrontDesk"),
    @("Jordan","Blake","Help Desk Technician","IT","GG_IT_HelpDesk"),
    @("Karon","Bryan","Systems Administrator","IT","GG_IT_HelpDesk")
)

# One temporary password for all new hires, typed at the prompt (never stored in this file)
$temp = Read-Host "Temporary password for new users" -AsSecureString

foreach ($p in $people) {
    $first,$last,$title,$dept,$group = $p
    $sam = ($first.Substring(0,1) + $last).ToLower()
    New-ADUser -Name "$first $last" -GivenName $first -Surname $last `
        -SamAccountName $sam -UserPrincipalName "$sam@cedarridge.local" `
        -DisplayName "$first $last" -Title $title -Department $dept -Company "Cedar Ridge Clinic" `
        -Path "OU=$dept,OU=Users,$root" -AccountPassword $temp `
        -ChangePasswordAtLogon $true -Enabled $true
    Add-ADGroupMember -Identity $group -Members $sam
}

# Verify
Clear-Host
Get-ADOrganizationalUnit -Filter * -SearchBase $root | Sort-Object DistinguishedName | Select-Object -ExpandProperty DistinguishedName
""
Get-ADUser -Filter * -SearchBase "OU=Users,$root" -Properties Title,Department | Select-Object Name,SamAccountName,Department,Title | Format-Table -AutoSize
foreach ($g in "GG_Clinical","GG_Billing","GG_FrontDesk","GG_IT_HelpDesk") {
    "$g : " + ((Get-ADGroupMember $g | Select-Object -ExpandProperty SamAccountName) -join ", ")
}
