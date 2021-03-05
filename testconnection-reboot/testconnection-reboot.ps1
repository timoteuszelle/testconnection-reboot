<#
Author: Tim Zelle
--
If you need to use your admin account, because you want to schedule things, auto fix stuff while you sleep.
$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content "C:\temp\encrypted_password1.txt"
The best practice to use a service account, note, the encrypted file needs to be created on the same host it will be read to work.
--
It will test the vm for connection, if the NIC was disconnected it will be connected, if the host doesn't respond, it will reboot.
Run this from your admin / jump host.
#> 
$file = (get-content -path c:\temp\temp.txt)
$username = "svc_user"
$encrypted = Get-Content "C:\temp\encrypted_password1.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($username, $encrypted)
$vcenterserver ="test.domain.ps"
Get-Module -ListAvailable *vmware* | Import-Module
Add-PSSnapIn vmware*
Connect-VIServer -Server $vcenterserver -Credential $credential 
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