<#
Author: Tim Zelle
--
#> 
function vcenterserver {
Import-Module  "C:\Users\Timoteus\Documents\gihub repo\functions\server-user-vcenter.psm1"  -Global
 Get-Module -ListAvailable *vmware* | Import-Module 
Add-PSSnapIn vmware*
Connect-VIServer -Server $vcenterserver -User $vcenteruser -pass $vcenterpassword
}