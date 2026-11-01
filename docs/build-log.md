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
**Did:** Wrote scripts/01-configure-network.ps1 to give DC01 the static IP 10.0.2.10 and rename it. Ran it from the shared folder and checked everything after the restart. Documented in docs/02-domain-controller.md.
**Problems:** ping google.com failed but ping 8.8.8.8 worked. That turned out to be expected, since DNS points at 127.0.0.1 and there's no DNS server on the box until Phase 4. I also forgot to take a before shot of the DHCP address.
**Learned:** Connectivity and name resolution are two different things. You can reach the internet by IP and still fail on names.
**Concept check:** Servers get static IPs because other machines need to find them at an address that doesn't change. CLIENT01 is set to ask 10.0.2.10 for DNS, so if that moved on a reboot every client would lose the domain. Laptops are the opposite. They move between networks, nothing needs to reach them at a fixed address, and DHCP means nobody is handing out addresses by hand.
ping 8.8.8.8 works because the routing is fine. The packet goes out the gateway at 10.0.2.1 and comes back. ping google.com fails because the name has to be turned into an IP first, and DC01 is pointed at 127.0.0.1 where no DNS server exists yet. Installing AD DS in Phase 4 puts one there.
**Next:** Phase 4, install Active Directory.

## 2026-10-16
**Did:** Installed AD DS with scripts/02-install-adds.ps1 and promoted DC01 to domain controller for carterlab.local. Added a DNS forwarder, had a look around ADUC and DNS Manager, and took the Clean DC snapshot.
**Problems:** Two DNS warnings at boot (4013 and 4017) and a red Local Server tile. Both turned out to be nothing. 4013 is DNS waiting for AD to finish syncing, and the service behind the red tile was InventorySvc, which has nothing to do with AD.
**Learned:** Red in Server Manager means look at this, not it's broken. Clicking into the detail view told me the exact service in a few seconds.
**Concept check:** AD needs DNS because clients have no other way to find a domain controller. They don't know DC01 exists or what its IP is, they only know the domain name. DNS is what turns carterlab.local into the DC is at 10.0.2.10. No DNS, no logins.
SRV records are service records. A normal A record maps a name to an IP, but an SRV record also says which service is running where, on what port, with what priority. The _ldap and _kerberos entries under _msdcs.carterlab.local tell a client to talk to DC01 on port 389 for LDAP in this domain. That's how a machine finds a DC it has never heard of before.
A domain is one group of users and computers managed together under a name, mine being carterlab.local. A forest is the container that holds one or more domains and sets the trust boundary between them. Mine is a single-domain forest, which is what most small and mid-sized companies run.
**Next:** Phase 5, OUs, groups and users.

## 2026-10-18
**Did:** Built the directory structure. Four OUs, five security groups based on job roles, and ten users imported from users.csv with their job titles. Added ppatel to a second group since head lifeguards still guard. Documented in docs/03-users-and-groups.md.
**Problems:** The import failed with could not find users.csv. The script used `.\users.csv`, which resolves against whatever directory I was sitting in rather than the script's own folder, and I was running it by full path from my home directory. Fixed it with $PSScriptRoot. When I re-ran it, the script printed "Created group" right after every "already exists" error, because Write-Host runs whether or not the command before it worked. Rewrote the loop to check with Get-ADGroup first so it's safe to run twice and tells the truth about what it did.
**Learned:** A script that reports success on a failure is worse than one that just crashes. Checking before acting makes it idempotent, which matters the moment anyone else runs it.
**Concept check:** An OU is a container that organizes objects and is where Group Policy attaches, so it decides what settings apply. A security group is a list of members used to grant permissions, and it doesn't care where in the tree those members sit. A user lives in exactly one OU but can be in as many groups as you want.
OU=IT,DC=carterlab,DC=local reads from the object outward. The IT organizational unit, inside the domain carterlab.local. Each DC= is one piece of the domain name split at the dots.
The pipeline sends the output of one command into the next. In 04-create-users.ps1, Import-Csv hands each row to ForEach-Object, so the loop runs once per user instead of me writing ten separate New-ADUser calls.
**Next:** Phase 6, password and lockout policy.

## 2026-10-18
**Did:** Set the domain password and lockout policy with scripts/05-password-policy.ps1. Used splatting so the parameters stay readable. Verified with Get-ADDefaultDomainPasswordPolicy and documented it in docs/03-users-and-groups.md.
**Problems:** None this phase.
**Learned:** Password policy is set per domain, not per OU. A GPO with password settings linked to an OU does nothing at all, which would be a confusing thing to debug if you didn't already know it.
**Concept check:** No, they wouldn't be locked out. The observation window is 15 minutes, so the four failures from 20 minutes ago have expired and don't count any more. The counter restarts and the two recent failures put them at 2 of 5. They'd need three more wrong attempts within 15 minutes of those two to actually lock the account.
**Next:** Phase 7, file share and Group Policy.

## 2026-10-18
**Did:** Created the Lifeguards share with both permission layers, then two GPOs linked to the Staff OU. One maps L: for lifeguards only, the other blocks Control Panel for all staff. Exported both as HTML reports and documented it in docs/04-group-policy.md.
**Problems:** Spent a while looking for Drive Maps under Computer Configuration before realizing it only exists under User Configuration. DC01 also froze and I had to force a power off, which logged Kernel-Power 41 on the next boot.
**Learned:** Security Filtering and item-level targeting are two different filters doing two different jobs. The GPO reaches everyone in Staff, and the targeting inside the preference decides who actually gets the drive. I also noticed icacls showing inherited BUILTIN\Users rights coming down from C:\, which means the share permission is what's really restricting access here, not NTFS.
**Concept check:** Full Control on the share but Read in NTFS means they can only read over the network. Effective access is whichever of the two layers is more restrictive, and that's NTFS here. Locally they'd only get Read either way, since NTFS applies no matter how you reach the folder.
The guide's question uses lbrooks, but in my CSV Logan Brooks is a lifeguard so he'd get both. Using mchen instead. She's in the Staff OU, so Restrict Control Panel applies to her like everyone else in there. The drive map GPO applies to her too, but the item-level targeting inside it checks for Lifeguards membership and she's an Instructor, so that preference gets skipped and no L: drive shows up. Same GPO, different result, decided entirely by group membership.
**Next:** Phase 8, build CLIENT01 and join the domain.

## 2026-10-19
**Did:** Built CLIENT01 on Windows 11 Enterprise, pointed its DNS at DC01, renamed it and joined it to carterlab.local, then moved the computer object into the Workstations OU. Tested as jsmith and mchen to confirm the Phase 7 GPOs behave the way they're supposed to. Documented in docs/05-client-join.md.
**Problems:** Missed the five-second boot-from-CD prompt and had to reset the VM to try again. Guest Additions mounts silently so nothing appeared to happen and I had to run the installer by hand from the CD drive. The domain join failed with domain does not exist or could not be contacted, which was just DC01 not being powered on. Add-Computer -Restart rebooted before I could read its output. Free space dropped to 16 GB, so I deleted the Windows 11 ISO and the Clean DC snapshot and skipped the optional client snapshot.
**Learned:** The join failed before it ever asked for credentials, which rules out a password problem straight away and points at DNS or reachability instead. I also learned the default Computers container isn't a real OU and can't have GPOs linked to it, which is why machines get moved into a Workstations OU.
**Concept check:** When someone types a password on CLIENT01, the machine asks its DNS server which servers handle carterlab.local and reads the SRV records to find a domain controller. It sends the username and proof of the password to DC01, which checks it using Kerberos. DC01 sends back a ticket saying who the user is and what groups they're in. CLIENT01 then pulls down the Group Policy for that user and machine, applies it, and builds the desktop with whatever mapped drives and restrictions come with it. The group list in that ticket is what decides whether the L: drive shows up.
CLIENT01 needed 10.0.2.10 as its DNS server because the SRV records naming DC01 only exist in DC01's own DNS. Pointed at my home router and my ISP, a lookup for carterlab.local comes back with nothing, so the client has no way to find a domain controller and the join fails before authentication even starts.
**Next:** Phase 9, help desk tickets.

## 2026-11-01
**Did:** Worked five help desk tickets start to finish: password reset, account lockout, new hire provisioning, a missing mapped drive, and a client that couldn't find a domain controller. Wrote each one up in tickets/ with investigation, root cause, resolution and prevention, and added an index with the scenario context.
**Problems:** Ticket 005 wouldn't reproduce at first. DNS was broken but users were still logging in fine. It turned out the DC Locator cache was holding DC01's address, so authentication was going straight there and skipping DNS entirely. Running nltest /dsgetdc with /force exposed it. Then I locked myself out of CLIENT01 trying to fix it as a domain admin who had never signed in on that machine, and had to get back in through the local admin account's security questions. CLIENT01 also froze during a restart and needed a hard power off.
**Learned:** Three of the five tickets turned out to be configuration working exactly as designed rather than anything broken, and telling those apart quickly is most of the job. Also that when one tool gives an answer the others contradict, it's often answering from a cache. And domain credentials are useless on a machine that can't reach a DC, which is the whole reason you keep a known local admin password.
**Next:** Phase 10, finish the project.