# 06-create-share.ps1

# Purpose: create a shared folder that only the lifeguards group can use
# Run on: DC01, PowerShell as Administrator

# The folder on DC01's disk
New-Item -Path C:\Shares\Lifeguards -ItemType Directory -Force

# Share permission: Lifeguards get full access over the network
New-SmbShare -Name Lifeguards -Path C:\Shares\Lifeguards -FullAccess "CARTERLAB\Lifeguards"

# NTFS permission: Lifeguards can modify files in the folder
# (OI) = Object Inherit, applies to files inside
# (CI) = Container Inherit, applies to subfolders inside
# M = Modify: read, write, edit and delete files, but not change permissions
icacls C:\Shares\Lifeguards /grant "CARTERLAB\Lifeguards:(OI)(CI)M"
