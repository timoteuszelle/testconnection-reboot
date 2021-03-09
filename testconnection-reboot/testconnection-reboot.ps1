<#
Author: Tim Zelle
--
Testconnection-reboot:
The filter variable is used to define vm based on powerstatus and ore names, or any other filter if you like.
The best practice to use a service account, note, the encrypted file needs to be created on the same host it will be read to work.
--
It will test the vm for connection, if the NIC was disconnected it will be connected, if the host doesn't respond, it will reboot.
Run this from your admin / jump host.
It will fix the most simple unresponsive systems and common faults of a not connected NIC.
--
#> 
$variablesettings = Import-csv -Path c:\temp\settings.csv -Delimiter ";"
$selection = ($vmname = Get-VM |Where-Object {$_.Name -like "$filter"} )
$username = $variablesettings[2].Value
$encrypted = Get-Content $variablesettings[1].Value | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($username, $encrypted)
$vcenterserver = $variablesettings[3].Value
Get-Module -ListAvailable *vmware* | Import-Module
Add-PSSnapIn vmware*
Connect-VIServer -Server $vcenterserver -Credential $credential 
$log = $variablesettings[5].Value
$nic = $variablesettings[6].Value
$filter = $variablesettings[4].Value
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