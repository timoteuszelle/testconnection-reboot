<#
Author: Tim Zelle
--
#> 
Import-Module ".\testconnection-reboot\functions\vcenterserver.psm1" -Global
$file = (get-content "C:\x.txt") 

foreach ($vm in $file) {

    $vmname = Get-VM -name $vm 
    foreach ($vm in $file) {
        $vmname = Get-VM -name $vm 
        $testrslt =(Test-Connection -Quiet -ComputerName $vmname -count 2) 
            if (
                $testrslt -eq $true){ 
                    write-host "Server $vmname is up."}
            else    {
                    write-host "Server $vmname is not responding."
                    
                    $nicinfo = (get-vm -name $vmname | Get-NetworkAdapter)
                    }
                    if ($nicinfo.ConnectionState -eq $false) {
                            get-vm -name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -StartConnected:$true
                            Write-Host "NIC is set on disconnected. The NIC will be set to connected and startconnected currently set as $nicinfo.ConnectionState.StartConnected."
                    }
                        $testrslt =(Test-Connection -Quiet -ComputerName $vmname -count 2) 
                        if ($testrslt -eq $true){ 
                        write-host "Server $vmname is up."}
                        elseif ($testrslt -eq $false)    {
                            write-host "Server $vmname is still not responding."
                            write-host "Server $vmname will reboot."
                            get-vm -Name $vmname | Stop-VM -confirm:$false
                            get-vm -Name $vmname | Start-VM
                            write-host "Server $vmname booting up."}
                        
                    
                        else {write-host "Server $vmname will reboot."
                                    get-vm -Name $vmname | Stop-VM -confirm:$false
                                    get-vm -Name $vmname | Start-VM
                                    write-host "Server $vmname booting up."}
                    }   
                         }   
                               