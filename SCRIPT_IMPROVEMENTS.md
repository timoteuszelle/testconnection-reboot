# PowerShell/PowerCLI Script Improvements TODO

## Code Structure & Readability

### ☐ TODO 1: Fix Inconsistent Indentation
**Issue**: Mix of spaces and tabs throughout the script
**Solution**: Standardize to 4 spaces or tabs
```powershell
# Current (inconsistent):
if ($testrslt -eq $true)
{
        write-host "Server $vmname is up."
        }

# Improved (consistent 4-space indentation):
if ($testrslt -eq $true) {
    Write-Host "Server $vmname is up."
}
```

### ☐ TODO 2: Break Long Nested Blocks into Functions
**Issue**: Main logic is deeply nested and hard to follow
**Solution**: Create reusable functions
```powershell
# Create functions like:
function Test-VMConnectivity {
    param([string]$VMName)
    return (Test-Connection -Quiet -ComputerName $VMName -Count 2)
}

function Repair-VMConnectivity {
    param($VM)
    # Handle NIC reconnection logic
}

function Restart-VMAndLog {
    param($VM, $LogPath)
    # Handle VM restart and logging
}
```

### ☐ TODO 3: Improve Variable Naming
**Issue**: Variables like `$testrslt` are not descriptive
**Solution**: Use descriptive names
```powershell
# Current:
$testrslt = (Test-Connection -Quiet -ComputerName $vmname -count 2)

# Improved:
$isVMResponding = Test-Connection -Quiet -ComputerName $vmname -Count 2
```

## Error Handling

### ☐ TODO 4: Add Try-Catch Blocks
**Issue**: No error handling for critical operations
**Solution**: Wrap operations in try-catch
```powershell
# Current:
Connect-VIServer -Server $vcenterserver -Credential $credential | Out-Null

# Improved:
try {
    Connect-VIServer -Server $vcenterserver -Credential $credential -ErrorAction Stop | Out-Null
    Write-Host "Successfully connected to vCenter: $vcenterserver"
} catch {
    Write-Error "Failed to connect to vCenter $vcenterserver: $($_.Exception.Message)"
    exit 1
}
```

### ☐ TODO 5: Add Configuration Validation
**Issue**: No validation of CSV file or required fields
**Solution**: Validate inputs before processing
```powershell
# Add validation:
$settingsPath = "c:\temp\settings.csv"
if (-not (Test-Path $settingsPath)) {
    Write-Error "Settings file not found: $settingsPath"
    exit 1
}

$variablesettings = Import-Csv -Path $settingsPath -Delimiter ";"
if ($variablesettings.Count -lt 6) {
    Write-Error "Settings file must contain at least 6 entries"
    exit 1
}
```

### ☐ TODO 6: Replace Silent Failures
**Issue**: Many operations use `| Out-Null` hiding errors
**Solution**: Use proper error handling
```powershell
# Current:
get-vm -Name $vmname | Stop-VM -confirm:$false | Out-Null

# Improved:
try {
    Get-VM -Name $vmname | Stop-VM -Confirm:$false -ErrorAction Stop
    Write-Host "Successfully stopped VM: $vmname"
} catch {
    Write-Warning "Failed to stop VM $vmname: $($_.Exception.Message)"
}
```

## Logic Issues

### ☐ TODO 7: Make Boot Wait Time Configurable
**Issue**: Hardcoded 30-second sleep may not be enough
**Solution**: Add configurable wait time
```powershell
# Add to settings.csv:
# BootWaitTimeSeconds;120

# In script:
$bootWaitTime = $variablesettings[7].Value -as [int]
if (-not $bootWaitTime) { $bootWaitTime = 60 }  # Default fallback
Start-Sleep -Seconds $bootWaitTime
```

### ☐ TODO 8: Consolidate Logging Logic
**Issue**: Inconsistent logging to different files
**Solution**: Create unified logging function
```powershell
function Write-ActionLog {
    param(
        [string]$VMName,
        [string]$Action,
        [string]$Result,
        [string]$LogPath
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp;$VMName;$Action;$Result"
    Add-Content -Path $LogPath -Value $logEntry
}
```

### ☐ TODO 9: Remove Code Duplication
**Issue**: Connectivity testing logic is duplicated
**Solution**: Create reusable function (see TODO 2)

## PowerShell Best Practices

### ☐ TODO 10: Fix PowerState Typo
**Issue**: "Poweredon" should be "PoweredOn"
```powershell
# Current:
$selection = Get-VM | Where-Object {($_.Name -like "$filter") -and ($_.PowerState -eq "Poweredon")}

# Fixed:
$selection = Get-VM | Where-Object {($_.Name -like "$filter") -and ($_.PowerState -eq "PoweredOn")}
```

### ☐ TODO 11: Remove Redundant Variable Assignments
**Issue**: Unnecessary variable reassignment
```powershell
# Current:
foreach ($vm in $filteredvms) { 
    $vmname = Get-VM -name $vm

# Improved:
foreach ($vm in $filteredvms) {
    # $vm is already the VM object, use it directly
```

### ☐ TODO 12: Add Proper Resource Cleanup
**Issue**: No disconnect from vCenter
**Solution**: Always disconnect, even on errors
```powershell
# Add at end of script:
try {
    # Main script logic here
} finally {
    if ($global:DefaultVIServer) {
        Disconnect-VIServer -Server * -Confirm:$false
        Write-Host "Disconnected from vCenter"
    }
}
```

### ☐ TODO 13: Fix Array Initialization
**Issue**: Unnecessary comma in array addition
```powershell
# Current:
$recheck += ,$vmname

# Fixed:
$recheck += $vmname
```

## Security & Reliability

### ☐ TODO 14: Add Credential Validation
**Issue**: No validation of encrypted password file
**Solution**: Validate credential file exists and is readable
```powershell
$encryptedPasswordPath = $variablesettings[1].Value
if (-not (Test-Path $encryptedPasswordPath)) {
    Write-Error "Encrypted password file not found: $encryptedPasswordPath"
    exit 1
}

try {
    $encrypted = Get-Content $encryptedPasswordPath | ConvertTo-SecureString -ErrorAction Stop
} catch {
    Write-Error "Failed to read encrypted password: $($_.Exception.Message)"
    exit 1
}
```

### ☐ TODO 15: Improve Logging Format
**Issue**: Basic logging without timestamps or context
**Solution**: Enhanced logging with structured format
```powershell
# Enhanced logging function:
function Write-StructuredLog {
    param(
        [string]$Level = "INFO",
        [string]$Message,
        [string]$VMName = "",
        [string]$LogPath
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    if ($VMName) { $logEntry += " (VM: $VMName)" }
    
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}
```

### ☐ TODO 16: Add Progress Indicators
**Issue**: No feedback during long operations
**Solution**: Add progress bars or status updates
```powershell
$totalVMs = $filteredvms.Count
for ($i = 0; $i -lt $totalVMs; $i++) {
    $vm = $filteredvms[$i]
    Write-Progress -Activity "Testing VM Connectivity" -Status "Processing $($vm.Name)" -PercentComplete (($i + 1) / $totalVMs * 100)
    # Process VM logic here
}
Write-Progress -Activity "Testing VM Connectivity" -Completed
```

## Nice-to-Have Improvements

### ☐ TODO 17: Add Parameter Support
**Issue**: No command-line parameter support
**Solution**: Make script more flexible
```powershell
param(
    [string]$SettingsPath = "c:\temp\settings.csv",
    [switch]$WhatIf,
    [string]$LogLevel = "INFO"
)
```

### ☐ TODO 18: Add Parallel Processing
**Issue**: Sequential processing is slow for many VMs
**Solution**: Use PowerShell jobs or ForEach-Object -Parallel (PS 7+)
```powershell
# For PowerShell 7+:
$filteredvms | ForEach-Object -Parallel {
    # VM processing logic
} -ThrottleLimit 10
```

### ☐ TODO 19: Create Configuration Template
**Issue**: No documentation for settings.csv format
**Solution**: Create example configuration file
```csv
# settings.csv example:
Setting;Value
EncryptedPasswordPath;c:\temp\encrypted_password.txt
Username;domain\serviceaccount
vCenterServer;vcenter.domain.com
VMFilter;PROD-*
MainLogPath;c:\temp\vm_actions.log
NICLogPath;c:\temp\nic_reconnections.log
BootWaitTimeSeconds;120
```

---

## How to Use This TODO List

- ☐ = Not started
- 🔄 = In progress  
- ✅ = Completed
- ❌ = Decided not to implement

Feel free to mark items as ❌ if you decide a particular improvement isn't needed for your use case.

