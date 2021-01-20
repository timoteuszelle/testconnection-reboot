<#
Author: Tim Zelle
--
#> 
function vcenterserver {
Import-Module  ".\testconnection-reboot\functions\server-user-vcenter.psm1"  -Global
 Get-Module -ListAvailable *vmware* | Import-Module 
Add-PSSnapIn vmware*
Connect-VIServer -Server $vcenterserver -User $vcenteruser -pass $vcenterpassword
}