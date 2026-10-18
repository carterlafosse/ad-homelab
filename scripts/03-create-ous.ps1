# 03-create-ous.ps1
# Purpose: create the OU structure for the fake company
# run on: DC01, Powershell as Administrator

$domain = "DC=carterlab,DC=local"

foreach ($ou in "Staff", "IT", "Groups", "Workstations") {
    New-ADOrganizationalUnit -Name $ou -Path $domain
    Write-Host "Created OU: $ou"
}