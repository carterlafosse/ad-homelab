# Build Log

## 2026-10-05
**Did:** Phase 0 setup. Checked my PC: 16 GB RAM, virtualization enabled in Task Manager, about 73 GB free on C drive. Installed Git, VS Code and the Powershell extension. Set my Git name and email. Created the repo folder structure with Powershell. 
**Problems:** Wasn't sure how to open Powershell extension inside VS Code. It's Terminal > New Terminal or CTRL + `.
**Learned:** Git only tracks files, not folders, empty folders need a .gitkeep files to show up on GitHub.
**Concept Check:** 'git config --global' saves settings for every repo on this PC, not just this one.
**Next:** Create the GitHub repo and push.

## 2026-10-07
**Did:** Created the LabNet NAT network (10.0.2.0/24, DHCP on) and documented it in docs/01-virtualbox-setup.md.
**Problems:** Initially I was unable to locate Network under Tools. Once I clicked Expert Mode, Network showed up.
**Learned:** NAT Network lets VMs reach each other and the internet; plain NAT isolates each VM.
**Concept check:** /24 leaves 254 usable addresses, because .0 is the network address and .255 is the broadcast address.
**Next:** Download the Windows Server ISO if not done, then build DC01 (Phase 2).

## 2026-10-08
**Did:** Built the DC01 VM, installed Windows Server 2025, connected it to LabNet, installed Guest Additions, and set up the shared folder. Documented it in docs/02-domain-controller.md.
**Problems:** Guest Additions reboot hung for 15 min; forced a power off and the VM came back fine. Auto-resize still doesn't work, but the shared folder does, so I moved on.
**Learned:** Guest Additions is what makes shared folders work. Dynamic disks are the only way two VMs fit on 73 GB free.
**Concept check:** The hypervisor (VirtualBox) runs the VMs and splits the real hardware between them. DC01 is one of those VMs. Dynamic disk because fixed would claim all 50 GB up front.
**Next:** Phase 3, static IP and hostname.

## 2026-10-15
**Did:** Wrote scripts/01-configure-network.ps1 to set DC01's static IP to 10.0.2.10 and rename it. Ran it from the shared folder and verified after the restart. Documented it in docs/02-domain-controller.md.
**Problems:** ping google.com failed while ping 8.8.8.8 worked. Expected: DNS points at 127.0.0.1 and there's no DNS server until Phase 4. Also forgot a before shot of the DHCP address.
**Learned:** Connectivity and name resolution are separate. You can reach the internet by IP and still fail on names.
**Concept check:** [your answer to the Phase 3 concept check]
**Next:** Phase 4, install Active Directory.