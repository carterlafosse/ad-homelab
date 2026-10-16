# 02-install-adds.ps1

# Purpose: install Active Directory Domain Services (ADDS) and promote DC01
# to the first domain controller of a new forest, carterlab.local, with DNS

# Run on: DC01, PowerShell as Administrator, after 01-configure-network.ps1
# Note: the DSRM password is typed at runtime and never stored in this file

# Step 1: install the AD DS role and its management tools
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Step 2: create the forest and promote this server. It restarts automatically
Install-ADDSForest -DomainName "carterlab.local" -DomainNetbiosName "CARTERLAB" `
-InstallDns -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM password")