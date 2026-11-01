# Scripts

Run in numbered order on a fresh Windows Server VM. Each one is written to be
run on DC01 from an elevated PowerShell window, with the execution policy
bypassed for that session only:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

| Script | What it does |
|---|---|
| `01-configure-network.ps1` | Sets DC01's static IP to 10.0.2.10 and renames the machine, then restarts |
| `02-install-adds.ps1` | Installs the AD DS role and promotes DC01 to the first domain controller in a new forest, `carterlab.local` |
| `03-create-ous.ps1` | Creates the Staff, IT, Groups and Workstations OUs |
| `04-create-users.ps1` | Creates the five role-based security groups, then imports ten users from `users.csv` and adds each to their group |
| `05-password-policy.ps1` | Sets the domain password and account lockout policy |
| `06-create-share.ps1` | Creates the Lifeguards share with share and NTFS permissions |

`users.csv` is the data source for `04-create-users.ps1`. All names in it are
fictional.

## Notes

Scripts 03 and 04 must run in that order, since the Groups OU has to exist
before the security groups can be placed in it.

`04-create-users.ps1` prompts for a temporary password at runtime rather than
storing one. The password has to meet the policy set in `05-password-policy.ps1`
if that script has already run, so use 12 or more characters with mixed types.

`04-create-users.ps1` checks whether each group already exists before creating
it, so it can be run more than once without producing misleading output.