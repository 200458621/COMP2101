Param ( [switch]$System , [switch]$Disks , [switch]$Network)

Import-Module kanika

if ($System -eq $false -and $Disks -eq $false -and $Network -eq $false) {
	write-host "Insert kanika-System for system information."
	write-host "Insert kanika-Disks for disks information."
	write-host "Insert kanika-Network for network information."	
	write-host "If no arguments found then it will display everything available here from a module."
	write-host "==================================================================================="	
    kanika-System;    kanika-Disks;    kanika-Network;
}else {
    if ($System) {  kanika-System }
    if ($Disks)  {  kanika-Disks  }
    if ($Network){  kanika-Network}
}