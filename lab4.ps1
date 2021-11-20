function get-hardwareinfo {
Write-Host "System Hardware Details:"
Get-cimInstance Win32_ComputerSystem |Format-list
}

function get-OS {
Write-Host "Operating System Information:"
get-CimInstance win32_operatingsystem | Format-list Name, Version
}

function get-processors {
Write-Host "processor info:"
gwmi -class win32_processor | fl Description, MaxClockSpeed, NumberOfCores, @{n="L1CacheSize";e={switch($_.L1CacheSize){$null{$stat="data unavailable."}};$stat}}, L2CacheSize, L3CacheSize
}

function get-memory {
Write-Host "Total installed RAM in the system:"
$init = 0
gwmi -class win32_physicalmemory |
foreach {
New-Object -TypeName psobject -Property @{
Manufacturer = $_.Manufacturer
Description = $_.description
"Size(GB)" = $_.Capacity/1gb
Bank = $_.banklabel
Slot = $_.Devicelocator
}
$init += $_.capacity/1gb
}|
Format-Table Manufacturer, Description, "Size(GB)", Bank, Slot
"Total RAM: ${init}GB"
}

function get-mydisks {
Write-Host "physical disk drives information:"
Get-WmiObject -Class Win32_DiskDrive | where-object DeviceID -ne $null |
Foreach {
    $drive = $_
    $drive.GetRelated("Win32_DiskPartition")|
    foreach {$logicaldisk =$_.GetRelated("win32_LogicalDisk");
    if($logicaldisk.size) {
        new-object -TypeName PSobject -Property @{
            Manufacturer = $drive.manufacturer
            DriveLetter = $logicaldisk.deviceID
            Model = $drive.Model
            Size = [String]($logicaldisk.size/1gb -as [int])+"GB"
            Free=[string]((($logicaldisk.freespace / $logicaldisk.size) * 100) -as [int])+ "%"
            FreeSpace= [string]($logicaldisk.freespace / 1gb -as [int]) +"GB"
    } |ft -autoSize
}}}}

function get-interfaceinfo {
get-ciminstance -ClassName Win32_NetworkAdapterConfiguration |? {$_.ipenabled -eq "True" } |
 format-table -AutoSize Description, Index, IPAddress, IPSubnet,
  @{n="DNSDomain";e={switch($_.DNSDomain){$null{$stat="data unavailable.";$stat}};if($null -ne $_.DNSDomain){$_.DNSDomain}}},
 @{n="DNSServerSearchOrder";e={switch($_.DNSServerSearchOrder){$null{$stat="data unavailable.";$stat}};if($null -ne $_.DNSServerSearchOrder){$_.DNSServerSearchOrder}}}
}

function get-videoinfo {
Write-Host "Graphics card info in detail:"
$HDimension=(get-wmiobject -class Win32_videocontroller).CurrentHorizontalResolution -as [String]
$VDimension=(gwmi -classNAME win32_videocontroller).CurrentVerticalresolution -as [string]
$Bit=(gwmi -classNAME Win32_videocontroller).CurrentBitsPerPixel -as [string]
$sum= $HDimension + " x " + $VDimension + " and " + $Bit + " bits"
gwmi -classNAME win32_videocontroller|
fl @{n="Video Card Vendor"; e={$_.AdapterCompatibility}},
Description, @{n="Resolution"; e={$sum -as [string]}}
}

get-hardwareinfo
get-OS
get-processors
get-memory
get-mydisks
get-interfaceinfo
get-videoinfo
