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
$log = "c:\temp\connectiontest.log"
$nic = "c:\temp\connectiontestnic.log"
$date = get-date
$recheck = @()
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