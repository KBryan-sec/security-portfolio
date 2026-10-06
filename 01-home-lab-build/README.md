# Lab 1: Home Lab Build and Network Diagram

## Objective

I built this lab so I could attack something without breaking anything real. Two VMs, one isolated network, no path to the internet or my home network. Every later lab in this repo runs on top of this one.

## Tools Used

- Oracle VirtualBox (on Windows 11)
- Kali Linux 2026.2
- Metasploitable 2
- draw.io (network diagram)

## Lab Architecture

![Lab network diagram](diagrams/lab-network-diagram.png)

The host is a Windows 11 PC running VirtualBox, with the VMs stored on the D: drive. Kali is the analyst and attacker machine. Metasploitable 2 is the target. Both sit on a VirtualBox Internal Network named `soclab`, and nothing else is attached, so they can only talk to each other.

Both VMs running in VirtualBox Manager:

![VirtualBox Manager with both VMs running](screenshots/01-virtualbox-manager.png)

## IP Scheme

| Machine | Role | OS | IP Address |
|---------|------|----|------------|
| Kali | Analyst / attacker | Kali Linux 2026.2 | 192.168.56.10/24 |
| Metasploitable 2 | Target | Ubuntu 32-bit, kernel 2.6 | 192.168.56.20/24 |

Kali has 8 GB RAM and 4 CPUs. Metasploitable has 1 GB RAM and 1 CPU.

## Build Steps

1. Installed VirtualBox on the Windows 11 host and pointed VM storage at the D: drive.
2. Imported the prebuilt Kali Linux 2026.2 VirtualBox image and set it to 8 GB RAM and 4 CPUs.
3. Created a new VM for Metasploitable 2 as Linux, Ubuntu 32-bit, with 1 GB RAM and 1 CPU. Built it from the existing .vmdk disk.
4. Set Adapter 1 on both VMs to Internal Network `soclab`. No NAT, no bridged adapter.

   Kali adapter on `soclab`:

   ![Kali network settings](screenshots/02-kali-network-settings.png)

   Metasploitable adapter on `soclab`:

   ![Metasploitable network settings](screenshots/03-metasploitable-network-settings.png)

5. Set static IPs. On Kali I made it permanent with NetworkManager:

   ```
   sudo nmcli con mod "Wired connection 1" ipv4.addresses 192.168.56.10/24
   sudo nmcli con mod "Wired connection 1" ipv4.method manual
   sudo nmcli con up "Wired connection 1"
   ```

6. On Metasploitable I made it permanent by editing `/etc/network/interfaces`:

   ```
   auto eth0
   iface eth0 inet static
   address 192.168.56.20
   netmask 255.255.255.0
   ```

7. Verified the config, tested connectivity, tested isolation, and took snapshots.

## Verification

I checked the IP config on each machine. `ip a` on Kali:

![ip a on Kali](screenshots/04-kali-ip-config.png)

`ifconfig eth0` on Metasploitable:

![ifconfig eth0 on Metasploitable](screenshots/05-metasploitable-ip-config.png)

Then I pinged in both directions with `ping -c 4`. Kali to Metasploitable:

![Ping from Kali to Metasploitable](screenshots/06-ping-kali-to-metasploitable.png)

Metasploitable to Kali:

![Ping from Metasploitable to Kali](screenshots/07-ping-metasploitable-to-kali.png)

Both directions came back 4 of 4 replies, 0% packet loss, under 1 ms average. The replies showed ttl=64, which is the Linux default.

## Isolation Test

This one failed on purpose. That's the point. I pinged 8.8.8.8 from Kali with `ping -c 4 8.8.8.8` and got "Network is unreachable". That is the result I wanted, because it proves the lab can't reach the internet.

![Isolation test showing no internet](screenshots/08-isolation-test-no-internet.png)

## Snapshots

I took a snapshot named `clean-baseline` on both VMs. If I wreck something in a later lab, I can roll back in a minute instead of rebuilding.

Metasploitable snapshot:

![Metasploitable snapshot](screenshots/09a-metasploitable-snapshot.png)

Kali snapshot:

![Kali snapshot](screenshots/09b-kali-snapshot.png)

## Challenges and Fixes

**1. Wrong OS type in the new VM wizard.**
Problem: The wizard defaulted to Windows 11 64-bit.
Fix: Changed it to Linux, Ubuntu 32-bit, since Metasploitable 2 is an old 32-bit Ubuntu.
Takeaway: Don't trust the defaults. Match the VM settings to what's actually on the disk.

**2. Leftover IPv6 address from NAT.**
Problem: Metasploitable booted once before I moved its adapter off NAT. `ifconfig` showed a leftover global IPv6 address (starting fd17) handed out by VirtualBox NAT.
Fix: Switched Adapter 1 to Internal Network `soclab` and rebooted. The address was gone.
Takeaway: Check the adapter before first boot, and read the whole interface output, not just the IPv4 line.

**3. Two commands on one line.**
Problem: I typed `sudo ifconfig ... up ifconfig` as one line and got a "Host name lookup failure".
Fix: Ran them as two separate commands.
Takeaway: One command per line unless I mean to chain them.

**4. Connection name is case sensitive.**
Problem: `nmcli con up "wired connection 1"` failed with unknown connection.
Fix: It needed a capital W. Linux is case sensitive. I found that out the annoying way.
Takeaway: Copy names exactly as the system shows them.

**5. Missing count on ping.**
Problem: I left the number off `ping -c` and got "invalid argument".
Fix: `-c` needs a number, like `ping -c 4`.
Takeaway: Read the error. It was telling me exactly what was wrong.

**6. IPs that disappeared on reboot.**
Problem: IPs I set by hand with `ip addr add` and `ifconfig` did not survive a reboot.
Fix: Used the permanent config shown in Build Steps (NetworkManager on Kali, `/etc/network/interfaces` on Metasploitable).
Takeaway: A working IP right now doesn't mean it's saved.

## What I Learned

- NAT, Bridged, and Internal Network are not the same thing. NAT gives a VM internet through the host. Bridged puts it on my real network. Internal Network only connects VMs to each other, which is what I wanted here.
- /24 means the first three numbers are the network. So 192.168.56.1 to 192.168.56.254 are all on the same network, and that's why Kali and Metasploitable can talk.
- ttl=64 in a ping reply hints the other side is Linux. Windows usually starts at a different value.
- Setting an IP by hand is temporary. Editing the config files is permanent. I learned the difference after a reboot wiped my work.
- Snapshots are cheap insurance. Take one while everything is clean, then break things freely.
- A deliberately vulnerable box has to stay isolated. Metasploitable is easy to break into on purpose, so it should never touch the internet or my home network.

## Next Steps

Lab 2: scan Metasploitable with Nmap from Kali and capture the traffic in Wireshark.
