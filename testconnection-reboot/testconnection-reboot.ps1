<#
Author: Tim Zelle
--
#> 
$vcenterserver ="" #set the vcenter server  
Get-Module -ListAvailable *vmware* | Import-Module 
Add-PSSnapIn vmware*
Connect-VIServer -Server $vcenterserver -User '' #set the username
$file = (get-content "C:\x.txt") #path for your hosts in file

foreach ($vm in $file) {

$names = Get-VM -name $vm 
$testrslt =(Test-Connection -Quiet -ComputerName $names -count 2) #test connection true or false
    if ($testrslt -eq $true){ #check for result true print on screen
    write-host "Server $names is up"}
    else {write-host "Server $names is not responding" #if result is not true, will start the reboot sequence.
    write-host "Server $names will reboot"
    get-vm -Name $names | Stop-VM -confirm:$false
    get-vm -Name $names | Start-VM
    }
                               }