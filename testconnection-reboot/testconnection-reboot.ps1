<#
Author: Tim Zelle
--
#> 
Import-Module "C:\Users\Timoteus\Documents\gihub repo\functions\vcenterserver.psm1" -Global
$file = (get-content "C:\x.txt") #path for your hosts in file

foreach ($vm in $file) {

$names = Get-VM -name $vm 
$testrslt =(Test-Connection -Quiet -ComputerName $names -count 2) #test connection true or false
    if ($testrslt -eq $true){ #check for result true print on screen
    write-host "Server $names is up."}
    else {write-host "Server $names is not responding." #if result is not true, will start the reboot sequence.
    write-host "Server $names will reboot."
    get-vm -Name $names | Stop-VM -confirm:$false
    get-vm -Name $names | Start-VM
    write-host "Server $names booting up."
    }
                               }