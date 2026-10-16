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
**Concept check:** Servers get static IPs because other machines have to find them at a known address. CLIENT01 is configured to ask 10.0.2.10 for DNS, so if that address changed on a reboot, every client would lose the domain. Laptops are the opposite: they move between networks, nothing needs to reach them at a fixed address, and DHCP means nobody has to hand out addresses by hand.
ping 8.8.8.8 works because routing is fine. The packet goes out through the gateway at 10.0.2.1 and comes back. ping google.com fails because that name has to be turned into an IP first, and DC01 is pointed at 127.0.0.1 for DNS, where no DNS server exists yet. The AD DS install in Phase 4 puts one there.
**Next:** Phase 4, install Active Directory.

## 2026-10-16
**Did:** Installed AD DS with scripts/02-install-adds.ps1 and promoted DC01 to domain controller for carterlab.local. Added a DNS forwarder, explored ADUC and DNS Manager, took the "Clean DC" snapshot.
**Problems:** Two DNS warnings (4013, 4017) at boot and a red Local Server tile. Both turned out to be noise: 4013 is DNS waiting on AD sync, and the service was InventorySvc, unrelated to AD.
**Learned:** Red in Server Manager means "look at this", not "it's broken". Clicking into the detail view named the exact service in seconds.
**Concept check:** AD needs DNS because clients have no other way to find a domain controller. They don't know DC01 exists or what its IP is; they only know the domain name. DNS is the lookup layer that turns carterlab.local into "the DC is at 10.0.2.10." No DNS, no logins.
SRV records are service records. A normal A record maps a name to an IP, but an SRV record also says which service runs where, on what port, with what priority. The _ldap and _kerberos entries under _msdcs.carterlab.local tell a client "for LDAP in this domain, talk to DC01 on port 389." That's how a machine finds a DC it has never heard of.
A domain is one group of users and computers managed together under a name, here carterlab.local. A forest is the outer container that holds one or more domains and defines the trust boundary between them. Mine is a single-domain forest, which is the usual setup for small and mid-sized companies.
**Next:** Phase 5, OUs, groups and users.
