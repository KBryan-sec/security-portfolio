# Security Portfolio

I'm Karon Bryan. I'm working toward a security analyst role. This repo is my hands-on lab work, and each lab is documented with what I did, what broke, and what I learned. Everything here was done by me in my own lab. I'm new to security and still learning, so I write down the mistakes too.

There are two tracks here. The blue team track is about watching the network, reading logs, and catching attacks. The IAM track is about who gets access to what, and proving it. Both build on the same isolated lab.

## Blue Team / SOC Labs

| # | Lab | What it covers | Status |
|---|-----|----------------|--------|
| 1 | [Home Lab Build and Network Diagram](01-home-lab-build/) | Isolated Kali and Metasploitable lab, static IPs, snapshots | Complete |
| 2 | Nmap Scan and Wireshark Capture | Scanning a target and reading the traffic | Planned |
| 3 | Phishing Email Analysis | Pulling apart a suspicious email | Planned |
| 4 | Malicious PCAP Investigation | Finding bad activity in a packet capture | Planned |
| 5 | SSH Brute Force and Linux Log Analysis | Attacking SSH and reading the logs | Planned |
| 6 | Windows Event Logs and Sysmon | Windows logging and what to look for | Planned |
| 7 | SIEM Deployment with Wazuh | Setting up a SIEM and feeding it logs | Planned |
| 8 | Attack, Detect, and Map to MITRE ATT&CK | Running an attack, catching it, mapping it | Planned |
| 9 | Incident Response Report (Capstone) | Writing up a full incident | Planned |

## Identity and Access Management (IAM) Labs

| # | Lab | What it covers | Status |
|---|-----|----------------|--------|
| 1 | Build the Directory | Windows Server domain controller, OUs, users, and groups for a fictional clinic; join a Windows 11 client | Planned |
| 2 | Identity Help Desk Operations | Password resets, unlocks, disabled accounts, lockout policies | Planned |
| 3 | RBAC and Least Privilege | Role groups and shared folders, tested as each user | Planned |
| 4 | Delegated Administration | A Help Desk group that can reset passwords in one OU only | Planned |
| 5 | Joiner, Mover, Leaver with PowerShell | Bulk create from CSV, department moves, offboarding | Planned |
| 6 | Entra ID Tenant and MFA | Free tenant, users, groups, admin roles, MFA | Planned |
| 7 | Single Sign-On | Connecting a SaaS app to Entra ID | Planned |
| 8 | Access Request and Approval Workflow | Request form, approval, fulfillment, audit trail | Planned |
| 9 | Access Review and Certification (Capstone) | Export memberships, review, remediate, report | Planned |

## Lab Environment

- Oracle VirtualBox on a Windows 11 PC
- Kali Linux as the analyst and attacker machine
- Metasploitable 2 as the intentionally vulnerable target
- A VirtualBox internal network with no route to the internet or my home network
- Windows Server and Windows 11 VMs will be added for the IAM track

## Tools and Skills So Far

- VirtualBox
- Kali Linux
- Linux networking commands
- Static IP configuration
- Network segmentation
- Snapshots
- Technical documentation

## Background

I come from tech support (Tier 2) and healthcare IT. That work was mostly triage, tickets, and escalation, and staying calm when things are broken. It also meant verifying who I was talking to before touching an account, handling lockouts and resets, and working inside Epic with SSO. That maps pretty directly to both security operations and identity work. I'm also studying for CompTIA A+ and Security+.

## Contact

GitHub: [github.com/KBryan-sec](https://github.com/KBryan-sec)
