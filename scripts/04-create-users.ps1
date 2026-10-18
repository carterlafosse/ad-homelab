# 04-create-users.ps1

# Purpose: create security groups, then bulk-create users from users.csv
#          and add each one to their group.
# Run on: DC01, PowerShell as Administrator, from the scripts folder.

$groupsOU = "OU=Groups,DC=carterlab,DC=local"

# Security groups, one per job role at the pool.
# Access is always granted to groups, never to individual users.
foreach ($g in "Lifeguards", "Instructors", "Supervisors", "Attendants", "HelpDesk") {
    if (Get-ADGroup -Filter "Name -eq '$g'") {
        Write-Host "Group already exists: $g"
    } else {
        New-ADGroup -Name $g -GroupScope Global -GroupCategory Security -Path $groupsOU
        Write-Host "Created group: $g"
    }
}

# One temporary password for all new users, typed at runtime, never stored.
$pw = Read-Host -AsSecureString "Temporary password for new users"

# Each CSV row becomes one user. $_ is the current row; $_.First is its First column.
# -Title records the job title in AD, so the directory says what each person does.
Import-Csv (Join-Path $PSScriptRoot "users.csv") | ForEach-Object {
    New-ADUser -Name "$($_.First) $($_.Last)" -GivenName $_.First -Surname $_.Last `
      -SamAccountName $_.Username -UserPrincipalName "$($_.Username)@carterlab.local" `
      -Path $_.OU -Title $_.Title -AccountPassword $pw -Enabled $true -ChangePasswordAtLogon $true
    Add-ADGroupMember -Identity $_.Group -Members $_.Username
    Write-Host "Created $($_.Username) in $($_.Group)"
}

# Head lifeguards supervise and still guard, so ppatel holds both groups.
# The aquatics supervisor doesn't take a chair, so she stays in Supervisors only.
# Real people hold more than one role, and this is why access goes through groups.
Add-ADGroupMember -Identity Lifeguards -Members ppatel