param (
    [string]$ServerName,  # The remote server name
    [int]$Option = 1      # Option to perform (1=Check, 2=Enable, 3=Disable, 4=Delete)
)

$regKeyPath = "HKLM\SYSTEM\CurrentControlSet\Control\Lsa"
$regValueName = "DisableRestrictedAdmin"

# Function to check the value of the registry key
function Check-RestrictedAdmin {
    try {
        $regQuery = Invoke-Command -ComputerName $ServerName -ScriptBlock {
            try {
                # Attempt to query the registry value
                $queryResult = reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin
                if ($queryResult) {
                    Write-Host "Registry Query Result:"
                    Write-Host $queryResult
                }
            }
            catch {
                Write-Host "Registry key $using:regKeyPath\$using:regValueName not found."
            }
        }

    } catch {
        Write-Host "Error checking the registry key: $_"
    }
}

# Function to enable RestrictedAdmin (set DisableRestrictedAdmin to 0)
function Enable-RestrictedAdmin {
    try {
        $enableCommand = Invoke-Command -ComputerName $ServerName -ScriptBlock {
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin /t REG_DWORD /d 0 /f
        }

        Write-Host "RestrictedAdmin has been enabled (DisableRestrictedAdmin set to 0)."
    } catch {
        Write-Host "Error enabling RestrictedAdmin: $_"
    }
}

# Function to disable RestrictedAdmin (set DisableRestrictedAdmin to 1)
function Disable-RestrictedAdmin {
    try {
        $disableCommand = Invoke-Command -ComputerName $ServerName -ScriptBlock {
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin /t REG_DWORD /d 1 /f
        }

        Write-Host "RestrictedAdmin has been disabled (DisableRestrictedAdmin set to 1)."
    } catch {
        Write-Host "Error disabling RestrictedAdmin: $_"
    }
}

# Function to delete the RestrictedAdmin registry key
function Delete-RestrictedAdminKey {
    try {
        $deleteCommand = Invoke-Command -ComputerName $ServerName -ScriptBlock {
            reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin /f
        }

        Write-Host "RestrictedAdmin registry key (DisableRestrictedAdmin) has been deleted."
    } catch {
        Write-Host "Error deleting the RestrictedAdmin key: $_"
    }
}

# Function to execute the appropriate option
function Execute-Action {
    if ($Option -eq 1) {
        Write-Host "[*] Checking the current value of the DisableRestrictedAdmin key..."
        Check-RestrictedAdmin
    } elseif ($Option -eq 2) {
        Write-Host "[*] Enabling RestrictedAdmin..."
        Enable-RestrictedAdmin
    } elseif ($Option -eq 3) {
        Write-Host "[*] Disabling RestrictedAdmin..."
        Disable-RestrictedAdmin
    } elseif ($Option -eq 4) {
        Write-Host "[*] Deleting the DisableRestrictedAdmin registry key..."
        Delete-RestrictedAdminKey
    } else {
        Write-Host "[!] Invalid option. Please provide 1, 2, 3, or 4 as an option."
    }
}

# Validate the server 
if (-not $ServerName) {
    Write-Host "[!] Error: Please provide the remote server name using the -ServerName argument."
    Write-Host "[*] exemple: RestrictedAdmin.ps1 -ServerName srv01.mylab.local -option 1"
    Write-Host "[*] Option 1 : Checking the current value of the DisableRestrictedAdmin key."
    Write-Host "[*] Option 2 : Enabling RestrictedAdmin."
    Write-Host "[*] Option 3 : Disabling RestrictedAdmin."
    Write-Host "[*] Option 4 : Deleting the DisableRestrictedAdmin registry key."

    exit
}

# Invoke the script on the remote server
Execute-Action
