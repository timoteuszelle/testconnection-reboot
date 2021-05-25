<#
Author: Tim Zelle
--
Testconnection-reboot:
The filter variable is used to define vm based on powerstatus and/or any other filter if you like.
The best practice to use a service account
Note: the encrypted password file needs to be created on the same host as it will be read for it to be read back as the password.
--
This sscript will test the vm for connectivity, if the NIC was disconnected it will be connected, if the host doesn't respond, it will reboot and checked again.
Host that were disconnected and didn't respond will be logged seperately. 
--
#> 
$variablesettings = Import-csv -Path c:\temp\settings.csv -Delimiter ";"
$username = $variablesettings[2].Value
$encrypted = Get-Content $variablesettings[1].Value | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($username, $encrypted)
$vcenterserver = $variablesettings[3].Value
Get-Module -ListAvailable *vmware* | Import-Module | Out-Null
Add-PSSnapIn vmware* | Out-Null
Connect-VIServer -Server $vcenterserver -Credential $credential | Out-Null
$log = $variablesettings[5].Value
$nic = $variablesettings[6].Value
$filter = $variablesettings[4].Value
$selection = ($vmname = Get-VM |Where-Object {($_.Name -like "$filter") -and ($_.PowerState -eq "Poweredon")})
$date = get-date
$recheck = @()
$filteredvms = $selection
foreach ($vm in $filteredvms)
{ 
        $vmname = Get-VM -name $vm 
        $testrslt =(Test-Connection -Quiet -ComputerName $vmname -count 2) 
        if ($testrslt -eq $true)
        {
                    write-host "Server $vmname is up."
                    }
        else
        {
                    write-host "Server $vmname is not responding."
                    $nicinfo = (get-vm -name $vmname | Get-NetworkAdapter)
                    if ($nicinfo.ConnectionState.Connected -eq $false) {
                                                            get-vm -name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -confirm:$false -Connected:$true -StartConnected:$true | Out-Null
                                                            Write-Host "NIC was set on disconnected. The NIC will be set to connected and startconnected on."
                                                            $testrslt =(Test-Connection -Quiet -ComputerName $vmname -count 2) 
                                                            if ($testrslt -eq $true) {
                                                            write-host "Server $vmname is up now. Server is logged in $nic"
                                                            Add-Content $nic "$vmname ; $date"
                                                            }
                                                            
                                                            
                                                            else 
                                                            {
                                                            write-host "Server $vmname is not responding while NIC is set as connected."
                                                            write-host "Server $vmname will reboot."
                                                            get-vm -Name $vmname | Stop-VM -confirm:$false | Out-Null
                                                            get-vm -Name $vmname | Start-VM | Out-Null
                                                            write-host "Server $vmname booting up."
                                                            $recheck += ,$vmname
                                                            Add-Content $nic "$vmname ; $date"
                                                            }}
                                                            
                    else {
                    write-host "Server $vmname is not responding while NIC is set as connected."
                    write-host "Server $vmname will reboot."
                    get-vm -Name $vmname | Stop-VM -confirm:$false | Out-Null
                    get-vm -Name $vmname | Start-VM | Out-Null
                    write-host "Server $vmname booting up."
                    $recheck += ,$vmname
                    }
                    }
                    }         
start-sleep -Seconds 30
foreach ($vm in $recheck)
{ 
        $vmname = Get-VM -name $vm 
        $testrslt =(Test-Connection -Quiet -ComputerName $vmname -count 2) 
        if ($testrslt -eq $true)
        {
                write-host "Server recheck $vmname is up."
                }
        else {
                write-host "Server recheck $vmname is not responding."
                write-host "Server $vmname will reboot and logged."
                get-vm -Name $vmname | Stop-VM -confirm:$false | Out-Null
                get-vm -Name $vmname | Start-VM | Out-Null
                write-host "Server $vmname booting up."
                Add-Content $log "$vmname ; $date"
                }
}
Read-Host "Press any key to exit..."
exit