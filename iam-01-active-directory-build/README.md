# IAM Lab 1: Build the Directory

## Objective

Every IAM lab after this one needs a real directory to work against, so this is the foundation. I built an Active Directory domain for a fictional healthcare practice, Cedar Ridge Clinic. It has a domain controller, an OU layout that matches how a clinic is organized, role-based security groups, eight staff accounts, and a Windows 11 workstation joined to the domain. I picked a clinic on purpose because I've worked in healthcare IT, and that's the kind of environment I've actually supported.

## Tools Used

- Oracle VirtualBox (on my Windows 11 PC)
- Windows Server 2022 Standard Evaluation (Desktop Experience)
- Windows 11 Enterprise Evaluation
- PowerShell with the ActiveDirectory module
- Active Directory Users and Computers (ADUC)

## Lab Architecture

![IAM lab network diagram](<diagrams/iam lab diagram.png>)

Both VMs sit on a VirtualBox Internal Network named `iamlab`. Nothing else is attached, so they can only see each other. This is a separate network from my SOC lab (`soclab`), so the two tracks don't touch.

| Machine | Role | OS | IP Address | DNS |
|---------|------|----|------------|-----|
| DC01 | Domain controller and DNS | Windows Server 2022 | 192.168.10.10/24 | 127.0.0.1 (itself) |
| CLIENT01 | Domain workstation | Windows 11 Enterprise | 192.168.10.20/24 | 192.168.10.10 (DC01) |

The domain is `cedarridge.local` (NetBIOS name `CEDARRIDGE`).

DC01 got 4 GB RAM, 2 CPUs, and a 60 GB disk:

![DC01 VM specs](<screenshots/01 vm specs1.png>)

CLIENT01 got 4 GB RAM, 2 CPUs, and a 64 GB disk, with EFI, TPM 2.0, and Secure Boot turned on because Windows 11 won't install without them:

![CLIENT01 VM specs](<screenshots/02 vm specs2.png>)

## Directory Design

```
cedarridge.local
└── CedarRidge
    ├── Users
    │   ├── Clinical
    │   ├── Billing
    │   ├── FrontDesk
    │   └── IT
    ├── Groups
    ├── Workstations
    ├── Service Accounts
    └── Disabled Accounts
```

I put everything under one top-level `CedarRidge` OU instead of using the built-in `Users` and `Computers` containers. Group Policy can't be linked to those default containers, and later labs need to apply policy and delegate permissions by department. Splitting users by department now means I can hand the Help Desk reset rights on one OU later without giving them the whole domain.

`Disabled Accounts` is there for offboarding. When someone leaves, the account gets disabled and moved, not deleted, so there's still a record of who had what.

| User | Name | Title | Department | Group |
|------|------|-------|------------|-------|
| mreyes | Maria Reyes | Registered Nurse | Clinical | GG_Clinical |
| dokafor | David Okafor | Medical Assistant | Clinical | GG_Clinical |
| pshah | Priya Shah | Billing Specialist | Billing | GG_Billing |
| tbecker | Tom Becker | Billing Manager | Billing | GG_Billing |
| lpark | Lena Park | Patient Coordinator | FrontDesk | GG_FrontDesk |
| mhill | Marcus Hill | Receptionist | FrontDesk | GG_FrontDesk |
| jblake | Jordan Blake | Help Desk Technician | IT | GG_IT_HelpDesk |
| kbryan | Karon Bryan | Systems Administrator | IT | GG_IT_HelpDesk |

The groups use a `GG_` prefix for global security groups. Access in later labs gets granted to the group, never to a person directly. That way when someone changes jobs, you move them between groups and their access follows.

## Build Steps

1. Created both VMs in VirtualBox and put Adapter 1 on Internal Network `iamlab`. Installed Windows Server 2022 with Desktop Experience on DC01 and Windows 11 Enterprise on CLIENT01.

2. Gave DC01 a static IP and pointed its DNS at itself, since it was about to become the DNS server:

   ```
   New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.168.10.10 -PrefixLength 24
   ```
   ```
   Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 127.0.0.1
   ```

3. Installed the AD DS role:

   ```
   Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
   ```

   ![AD DS role installed](<screenshots/03 adds role.png>)

4. Promoted DC01 to the first domain controller in a new forest. It prompts for a Directory Services Restore Mode password, and the server reboots when it's done.

   ```
   Install-ADDSForest -DomainName cedarridge.local -DomainNetbiosName CEDARRIDGE -InstallDns -Force
   ```

   ![Domain promotion in progress](<screenshots/04 domain promotion.png>)

5. Logged back in as `CEDARRIDGE\Administrator` and confirmed the domain, the DC, and the network settings with [verify-domain.ps1](scripts/verify-domain.ps1):

   ![Domain verified](<screenshots/05 domain verified.png>)

6. Built the OUs, groups, and users with [build-directory.ps1](scripts/build-directory.ps1). The script asks for the temporary password at runtime with `Read-Host -AsSecureString`, so no password is saved in the file. Every account is set to change its password at first logon.

   OU structure:

   ![OU structure](<screenshots/06 ou structure.png>)

   Users and group memberships:

   ![Users and groups](<screenshots/07 users and groups.png>)

   The same thing in ADUC, looking at the IT OU:

   ![ADUC IT OU](<screenshots/08 aduc it ou.png>)

7. Set CLIENT01's IP to 192.168.10.20 with DNS pointed at DC01, then confirmed it could reach the DC and resolve the domain:

   ```
   ping -n 2 192.168.10.10
   ```
   ```
   nslookup cedarridge.local
   ```

   ![CLIENT01 ping and DNS](<screenshots/09 client01 ping and dns.png>)

8. Joined CLIENT01 to the domain. It asks for domain admin credentials and reboots:

   ```
   Add-Computer -DomainName cedarridge.local -NewName CLIENT01 -Credential CEDARRIDGE\Administrator -Restart
   ```

9. New computer accounts land in the default `Computers` container, so I moved CLIENT01 into the Workstations OU with [move-workstation.ps1](scripts/move-workstation.ps1):

   ```
   Get-ADComputer CLIENT01 | Move-ADObject -TargetPath "OU=Workstations,OU=CedarRidge,DC=cedarridge,DC=local"
   ```

   ![CLIENT01 in Workstations OU](<screenshots/10 client01 in workstations ou.png>)

10. Logged into CLIENT01 as `CEDARRIDGE\kbryan`, set a new password when Windows forced the change, and checked who I was:

    ```
    whoami; hostname; whoami /upn; whoami /groups | findstr CEDARRIDGE
    ```

    ![kbryan logged into CLIENT01](<screenshots/11 kbryan domain login.png>)

11. Shut both VMs down and took a `clean-baseline` snapshot of each.

    ![clean-baseline snapshots](<screenshots/12 clean baseline snapshots.png>)

## Verification

- `Get-ADDomain` shows `cedarridge.local`, NetBIOS `CEDARRIDGE`, and DC01 as the PDC emulator.
- CLIENT01 pings DC01 with 0% loss, and `nslookup cedarridge.local` resolves to 192.168.10.10.
- `Get-ADComputer CLIENT01` shows it in `OU=Workstations,OU=CedarRidge`, with its OS and IP reported back to AD.
- A domain user can sign into the workstation. `whoami` returns `cedarridge\kbryan`, the UPN is `kbryan@cedarridge.local`, and the login token includes `CEDARRIDGE\GG_IT_HelpDesk`. That last one matters most, because it proves group membership actually makes it into the session. Later access checks depend on that.

## Challenges and Fixes

**Two warnings during domain promotion.** `Install-ADDSForest` threw two yellow warnings. The first one said a DNS delegation couldn't be created. That's expected in a brand new forest with no parent DNS zone above it, and this lab has no internet anyway, so no action needed. The second was about Windows Server 2022 blocking older NT 4.0-style cryptography by default. That one is informational. Part of this job is knowing which warnings to act on and which ones are just the system telling you what it did.

**Windows 11 missed the boot prompt.** The first time CLIENT01 started, it skipped past "Press any key to boot from CD" before I could hit a key, so there was nothing to boot from. I reset the VM and pressed a key right away.

**CLIENT01 shut itself off mid setup.** It powered off partway through the out-of-box setup and I had to go through it again. The account name I used the first time (`localadmin`) was already taken by then, so the local admin ended up as `labadmin`. The desktop also shows a "Windows License is expired" watermark, which is the evaluation build. Expired eval builds can shut down on a timer, so I kept the client work short and took the snapshot as soon as it was done.

**Couldn't paste into the VMs.** Clipboard sharing didn't work even after installing Guest Additions and setting it to Host to Guest. Instead of typing long scripts by hand, I set up a read-only VirtualBox shared folder that shows up as `Z:` on DC01 and ran the scripts straight from there:

```
powershell -ep bypass -f Z:\build-directory.ps1
```

**First ping from CLIENT01 failed.** Right after setting the static IP, the ping came back `General failure`. The address was still in a "Tentative" state while Windows checked the network for duplicates. A few seconds later the same ping worked. The first `nslookup` also timed out once before it answered.

**Renaming an account instead of rebuilding it.** The IT admin account started as a placeholder, Sam Carter (`scarter`). I wanted my own name on it, so I renamed it in place with [update-it-admin.ps1](scripts/update-it-admin.ps1) instead of deleting it and making a new one. The account kept its group membership and OU. In a real environment that's how you handle a legal name change. The account's identity in AD (its SID) stays the same, and only the name attributes change.

```
Get-ADUser scarter | Rename-ADObject -NewName "Karon Bryan"
```
```
Set-ADUser scarter -GivenName "Karon" -Surname "Bryan" -DisplayName "Karon Bryan" -UserPrincipalName "kbryan@cedarridge.local" -SamAccountName "kbryan"
```

**Keeping the snapshots small.** My drives are tight on space, so I shut both VMs down before taking snapshots instead of snapshotting them running. A running snapshot saves the whole contents of RAM too. I also ejected the Windows 11 ISO from CLIENT01's virtual drive so the VM isn't tied to that file.

## What I Learned

- A domain controller is also the DNS server, and that's why DNS on the client has to point at the DC and not at a router or 8.8.8.8. If DNS is wrong, nothing else works, including the domain join.
- The default `Users` and `Computers` containers aren't OUs. You can't link Group Policy to them, which is why everything here lives under its own OU tree.
- Give access to groups, not people. Moving someone between groups is how access changes when their job changes.
- Renaming an account keeps the same SID, so its permissions and group memberships come with it. Deleting and recreating gives you a brand new identity with none of that.
- "Must change password at next logon" works the way it should. The first time I signed in, Windows made me set my own password before it would load the desktop.
- `whoami /groups` is the fastest way to see what a user can actually access in the session they're in right now.

## Next Steps

IAM Lab 2: Identity Help Desk Operations. Password resets, account unlocks, disabling and re-enabling accounts, and setting up an account lockout policy, all done against this domain.
