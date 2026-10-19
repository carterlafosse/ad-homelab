# 05-password-policy.ps1

# Purpose: set the domain-wide password and account lockout policy
# Run on: DC01, PowerShell as Administrator

# MinPasswordLength 12    - anything shorter is refused
# ComplexityEnabled       - needs 3 of: upper, lower, number, symbol
# LockoutThreshold 5      - five wrong passwords locks the account
# LockoutDuration 15 min  - a locked account frees itself after 15 minutes
# ObservationWindow 15min - failed attempts older than 15 minutes stop counting

Set-ADDefaultDomainPasswordPolicy -Identity carterlab.local `
    -MinPasswordLength 12 `
    -ComplexityEnabled $true `
    -LockoutThreshold 5 `
    -LockoutDuration 00:15:00 `
    -LockoutObservationWindow 00:15:00