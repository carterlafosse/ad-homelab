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