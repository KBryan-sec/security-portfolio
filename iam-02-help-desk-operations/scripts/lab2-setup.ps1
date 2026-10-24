# IAM Lab 2 setup: lockout policy, lockout auditing, and one disabled account
Set-ADDefaultDomainPasswordPolicy -Identity cedarridge.local -LockoutThreshold 5 -LockoutDuration 00:30:00 -LockoutObservationWindow 00:15:00
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable | Out-Null
Disable-ADAccount jblake

Write-Host "`n=== Domain password and lockout policy ===" -ForegroundColor Cyan
Get-ADDefaultDomainPasswordPolicy | Format-List LockoutThreshold, LockoutDuration, LockoutObservationWindow, MinPasswordLength, MaxPasswordAge
Write-Host "=== Lockout auditing ===" -ForegroundColor Cyan
auditpol /get /subcategory:"User Account Management"
