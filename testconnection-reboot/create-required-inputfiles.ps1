<#
Author: Tim Zelle
--
#>
$file = read-host "Type a file location where to create the files, example c:\temp" 
$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content "$file\encrypted_password.txt" 
$username = read-host "type the user used for the passwordfile"
$encrypted = "$file\encrypted_password.txt"
$vcenterserver = read-host "type the vcenter host name or ip"
$logname0 = read-host "filename for the log, example failed.log"
$logname1 = read-host "filename for the log, example failed.log"
$filter = read-host 'type a filter, for example ($_.name -like test)'
$log0 = "$file\$logname0"
$log1 = "$file\$logname1"
$settings = @(  [PSCustomObject]@{
    Name = 'File location' ; Value = $file ; Description = 'Input file location root for input and output files?'
}  
                [PSCustomObject]@{
    Name = 'Password file' ; Value = $encrypted ; Description = 'location of encrypyed password file?'
}
                [PSCustomObject]@{
    Name = 'Username' ; Value = $username ; Description = 'Input of username, for example, admin account or service account?'
}
                [PSCustomObject]@{
    Name = 'Vcenter' ; Value = $vcenterserver ; Description = 'Input hostname or ip of vCenter server?'
}
                [PSCustomObject]@{
    Name = 'Filter' ; Value = $filter ; Description = 'input filters, for example: $_.name -like?'
}
                [PSCustomObject]@{
    Name = 'Log file F' ; Value = $log0 ; Description = 'Setting for name and location log F file?'
}
                [PSCustomObject]@{
    Name = 'Log file N' ; Value = $log1 ; Description = 'Setting for name and location log N file?'
}  
)
$settings | Export-Csv -path $file\settings.csv -NoTypeInformation -Delimiter ";"