<#
Author: Tim Zelle
--
#> 
 function myuserandserver
 {
Get-Module -ListAvailable *vmware* | Import-Module 
Add-PSSnapIn vmware*
$vcenterserver = "testvcenterserver.intra.domain"
$vcenteruser = "testuser"
$vcenterpassword = "testpassword"
 }