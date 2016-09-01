#load the VMware Powershell Snapin
#Add-PSSnapin VMware.VimAutomation.Core -ErrorAction 'Silently Continue'
Import-Module VMware.VimAutomation.Extensions

#Connect to server environment
Connect-VIServer vcenter-web.home -user <username> -Password <Password>

# Get All the ESX Hosts
$ESXSRV = Get-VMhost

# Get All Powered On VMs
$onvms = get-vm | where-object {$_.PowerState -eq  'PoweredOn'} | select name,PowerState

# For each of the VMs on the ESX hosts
# Shutdown the guest cleanly
$onvms | foreach-object -process {shutdown-vmguest $_.name -Confirm:$false}


# Set the amount of time to wait before assuming the remaining powered on guests are stuck
$waittime = 200 #Seconds

$Time = (Get-Date).TimeofDay
do {
    # Wait for the VMs to be Shutdown cleanly
    sleep 1.0
    $timeleft = $waittime - ($Newtime.seconds)
    $numvms = ($ESXSRV | Get-VM | Where { $_.PowerState -eq "poweredOn" }).Count
    Write "Waiting for shutdown of $numvms VMs or until $timeleft seconds"
    $Newtime = (Get-Date).TimeofDay - $Time
    } until ((@($ESXSRV | Get-VM | Where { $_.PowerState -eq "poweredOn" }).Count) -eq 0 -or ($Newtime).Seconds -ge $waittime)

# Shutdown the ESX Hosts
 foreach ($esxhost in $ESXSERV) { $esxhost | Stop-VMHost -Confirm:$false }
