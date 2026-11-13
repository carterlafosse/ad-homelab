# Help desk tickets

Help desk scenarios run against the lab, each investigated and documented the way
a real ticket would be: what was reported, how it was narrowed down, what
actually caused it, how it was fixed, and what would stop it recurring.

The environment models a small municipal aquatics department: ten staff
across lifeguards, instructors, supervisors, front desk attendants and IT
support, each in a security group, with a file share only lifeguards can
reach. How it was built is in [/docs](../docs).

Tickets 001–005 run against the on-premises Active Directory domain. Ticket
006 onward runs against the Microsoft 365 tenant added later, documented in
[docs/06-microsoft-365-entra.md](../docs/06-microsoft-365-entra.md).

| Ticket | Issue | Root cause |
|---|---|---|
| [001](001-password-reset.md) | Forgotten password | User error |
| [002](002-account-locked-out.md) | Account locked out | Lockout policy working as configured |
| [003](003-new-hire-access.md) | New hire needs access | Provisioning request, not a fault |
| [004](004-mapped-drive-missing.md) | Mapped drive disappeared | User removed from a security group |
| [005](005-no-logon-servers.md) | "No logon servers available" | Client DNS pointed at a public resolver |
| [006](006-new-hire-no-license.md) | New hire has no Outlook | Not added to the licensing group |
| [008](008-mfa-new-phone.md) | New phone, can't complete MFA | Authenticator tied to the old device |

Most of them turned out to be configuration working exactly as designed, or
a step that was missed, rather than anything actually broken, which is
usually how it goes.