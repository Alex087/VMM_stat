#Collect info about VM in SC VMM
Import-Module virtualmachinemanager
Remove-Item -Path C:\tmp\vmm\all_vm3.txt -Force
$totalsizes = 0
$user = ""
$vm = ""
$GrantedToList_all = ""
$mem = 0
$hdd = 0
$net = ""


$vm_subnets = New-Object 'system.collections.generic.list[System.Object]'
$all = "VM Name" + ";" + "Owner" + ";" + "Company" + ";" + "Owner Department" + ";" + "All Departments"+ ";" + "GrantedToList" + ";" + "Memory" + ";" + "CPUCount" + ";" + "HDD" + ";" + "Net" + ";" + "Cloud" + ";" + "IPAddr" + ";" + "VMSubnets" + ";" + "Status" 
$all | add-content C:\tmp\vmm\all_vm3.txt -encoding Unicode

$vms = get-vm | select -property name,owner,DynamicMemoryMaximumMB,CPUCount,TotalSize,GrantedToList,memory,cloud,status
$GrantedToList_all = @()
foreach ($vm in $vms) {
if ($vm.Name -like "*VDI*") {continue} else {
if ($vm.owner) {
$owner = $vm.owner.Split("\")
if ($owner[1] -eq "Admins") {$user = "Admins"} else { $user = get-aduser $owner[1] -Properties * | select displayname, Department, Company, o } 

   } else {$user = " "}


#---GrantedToList-------------------

if ($vm.GrantedToList) {
$GrantedToList_all = " "
$split = $vm.GrantedToList.Name.Split(" ")


foreach ($split_ in $split) {

#$split_

$split1 = $split_.Split("\")

$h = get-aduser $split1[1] -Properties * | select displayname
$GrantedToList_all = $GrantedToList_all + "," + $h.displayname 

} 

} else {$GrantedToList_all = " "}

#------------------------------

#---Disk Size-------------------
$vm_hards = Get-SCVirtualDiskDrive -VM $vm.Name
$totalsizes = 0
foreach ($vm_hards_ in $vm_hards) {

$totalsizes += $vm_hards_.VirtualHardDisk.MaximumSize
 }

$totalsizes_ = $totalsizes / 1GB

#------------------------------
$ipaddr = $null  
$ipaddr = Get-SCVirtualNetworkAdapter -VM $vm.Name
$IP_join = $ipaddr.IPv4Addresses -join ", "
#------------------------------
#VMSubnet
$vm_subnets = $null
$vm_subnets = New-Object 'system.collections.generic.list[System.Object]'
$ipaddr | foreach {
$vm_subnets.add($_.VMSubnet.Name)
}
$vm_subnet = $vm_subnets -join ", "
#------------------------------
$net = $ipaddr | select name, slotid | group name
if ($vm.DynamicMemoryMaximumMB) {$mem = $vm.DynamicMemoryMaximumMB} else {$mem = $vm.memory }
#$mem1 = $mem / 1GB 
$hdd = $vm.TotalSize / 1GB

$all = $vm.Name + ";" + $user.displayname + ";" + $user.Company + ";" + $user.Department + ";" + $user.o + ";" + $GrantedToList_all + ";" + $mem + ";" + $vm.CPUCount + ";" + $totalsizes_ + ";" + $net.Count + ";" + $vm.cloud + ";" + $IP_join + ";" + $vm_subnet + ";" +$vm.Status
$all | add-content C:\tmp\vmm\all_vm3.txt -encoding Unicode


}
 }
 
  
