# 03-create-ous.ps1
# Purpose: create the OU structure for the fake company
# Run on: DC01, PowerShell as Administrator

$domain = "DC=carterlab,DC=local"

foreach ($ou in "Staff", "IT", "Groups", "Workstations") {
    if (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'") {
        Write-Host "OU already exists: $ou"
    } else {
        New-ADOrganizationalUnit -Name $ou -Path $domain
        Write-Host "Created OU: $ou"
    }
}