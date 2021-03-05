<#
Author: Tim Zelle
--
#> 
Import-Module ".\testconnection-reboot\functions\vcenterserver.psm1" -Global
$file = (get-content "C:\x.txt") 
$date = get-date
foreach ($vm in $file)
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
                                                            get-vm -name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -StartConnected:$true
                                                            Write-Host "NIC was set on disconnected. The NIC will be set to connected and startconnected will be set on."
                                                            $testrslt =(Test-Connection -Quiet -ComputerName $vmname -count 2) 
                                                            if ($testrslt -eq $true) {
                                                            write-host "Server $vmname is up now."
                                                            Add-Content $log "$vmname ; $date ; NIC"
                                                            }
                                                            
                                                            
                                                            else 
                                                            {
                                                            write-host "Server $vmname is not responding while NIC is set as connected."
                                                            write-host "Server $vmname will reboot."
                                                            get-vm -Name $vmname | Stop-VM -confirm:$false
                                                            get-vm -Name $vmname | Start-VM
                                                            write-host "Server $vmname booting up."
                                                            Add-Content $log "$vmname ; $date"
                                                            }
                                                                    }
                                                            
                    else {
                    write-host "Server $vmname is not responding while NIC is set as connected."
                    write-host "Server $vmname will reboot."
                    get-vm -Name $vmname | Stop-VM -confirm:$false
                    get-vm -Name $vmname | Start-VM
                    write-host "Server $vmname booting up."
                    Add-Content $log "$vmname ; $date"
                        }
        }
 }   