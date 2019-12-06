[CmdletBinding()]
# Command input
Param(
    [string[]]$ComputerName = $env:COMPUTERNAME,
    [Parameter(Mandatory=$true)]
    [ValidateSet("Create", "Quit", "Remove", "Rename")]
    [string]$Command 
)

# Creating the user
if($Command -eq "Create") { 
    [string]$ObjectName = Read-Host -Prompt "Enter a username for the user account"
    $PasswordForUser = Read-Host -Prompt "Enter a password for user account" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordForUser)
    $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) 
    
    foreach($Computer in $ComputerName) {
        if(Test-Connection -ComputerName $Computer -count 1 -Quiet) {
                try {
                    $CompObject = [ADSI]"WinNT://$Computer"
                    $NewObj = $CompObject.Create("User",$ObjectName)
                    $NewObj.SetPassword($PlainPassword)
                    $NewObj.SetInfo()
                    Write-Host "User account with the name $ObjectName created successfully" -ForegroundColor Green
                } catch {
                    Write-Warning "Error occurred while creating the user"
                    Write-Verbose "More details : $_"

                }
        } else {
                Write-Warning "$Computer is not online or avaliable"
        }
    }
}

# Removing the user
if($Command -eq "Remove") { 
    [string]$ObjectName = Read-Host -Prompt "Enter the username for the user account to be removed"

    foreach($Computer in $ComputerName) {
        if(Test-Connection -ComputerName $Computer -count 1 -Quiet) {
            try {
                Remove-LocalUser -Name $ObjectName
                Write-Host "Removed the user account: $ObjectName" -ForegroundColor Green
            } catch {
                Write-Warning "Error occurred while removing the user"
                Write-Verbose "More details : $_"
            }    
        } else {
                Write-Warning "$Computer is not online or avaliable"
        }
    }
}

# Renaming the user
if($Command -eq "Rename") { 
    [string]$CurrentUsername = Read-Host -Prompt "Enter the username for the user account to be renamed"
    [string]$NewUsername = Read-Host -Prompt "Enter the new username"

    foreach($Computer in $ComputerName) {
        if(Test-Connection -ComputerName $Computer -count 1 -Quiet) {
            try {
                Rename-LocalUser -Name $CurrentUsername -NewName $NewUsername
                Write-Host "Renamed the user account $CurrentUsername to $NewUsername" -ForegroundColor Green
            } catch {
                Write-Warning "Error occurred while renaming the user"
                Write-Verbose "More details : $_"
            }    
        } else {
                Write-Warning "$Computer is not online or avaliable"
        }
    }
}

# Quitting the script
if($Command -eq "Quit") {   
    Write-Host "Quitting application..." -ForegroundColor Red
}