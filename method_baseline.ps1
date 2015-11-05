[cmdletbinding()]
param([switch]$baseline_local, [switch]$persistence, [switch]$comparison)
if($baseline_local) 
{

Write-Host "Setting up your scripting environment" -ForegroundColor Green

$scriptpath = "$home\desktop\system_info_$env:COMPUTERNAME"

#define your scriptpath
New-Item -ItemType directory -Path $scriptpath
New-Item -ItemType directory -Path $scriptpath\network_info
New-Item -ItemType directory -Path $scriptpath\host_system_info 

#create your timestamp
get-date | Tee-Object -FilePath $scriptpath\timestamp_$env:COMPUTERNAME.txt
#$IP= Read-Host -Prompt "Enter IP:"

Write-Host "Collecting Process information" -ForegroundColor Green
Get-Process | Sort-Object -Descending WS | Out-File $scriptpath\host_system_info\tasklist_$env:COMPUTERNAME.txt

Write-Host "Collecting OS and NIC information" -foregroundcolor green
#print out basic OS information
Get-WmiObject win32_operatingsystem | Format-List * | Out-File $scriptpath\host_system_info\os_info_$env:computername.txt
Get-WmiObject win32_operatingsystem | Select-Object -property csname, osarchitecture, name, freephysicalmemory, freespaceinpagingfiles, freevirtualmemory, serialnumber | Out-File $scriptpath\host_system_info\architecture_$env:computername.txt
#print out network adapter info
Get-WmiObject win32_networkadapter | select netconnectionid, name, interfaceindex, netconnectionstatus | Format-Table | Out-File $scriptpath\network_info\network_info_$env:computername.txt
ipconfig /all | Out-File $SCRIPTPATH\network_info\network_info_$env:computername.txt


Write-Host "Collecting locattime information" -ForegroundColor green
Get-WmiObject win32_localtime | Select-Object month,day,year,hour,minute,second | Out-File $scriptpath\host_system_info\time_$env:computername.txt
[system.timezone]::currenttimezone | Out-File $scriptpath\host_system_info\timezone_$env:computername.txt

Write-Host "Collecting Network Shares Information" -ForegroundColor green
Get-WmiObject Win32_NetworkConnection | Out-File $scriptpath\network_info\network_shares_2_$env:computername.txt
Get-WmiObject -Query "Select * From Win32_LogicalDisk Where DriveType = 4" | Out-File $scriptpath\network_info\network_shares_$env:computername.txt
Get-WmiObject -Class Win32_Share | Out-File $scriptpath\network_info\network_shares_$env:computername.txt

Write-Host "Collecting Services Information" -ForegroundColor green
Get-WmiObject win32_service | select Name, DisplayName, State, PathName | Out-File $scriptpath\host_system_info\services_$env:computername.txt

Write-Host "Conducting Reg Queries" -ForegroundColor green
Get-ItemProperty HKLM:\Software | Out-File $scriptpath\host_system_info\hklm_software_reg_$env:computername.txt
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $scriptpath\host_system_info\hklm_run_reg_$env:computername.txt
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Runonce | Out-File $scriptpath\host_system_info\hklm_runonce_reg_$env:computername.txt
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $scriptpath\host_system_info\hkcu_run_reg_$env:computername.txt
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce | Out-File $scriptpath\host_system_info\hkcu_runonce_reg_$env:computername.txt
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Internet Explorer' | Out-File $scriptpath\host_system_info\IE_Info_$env:computername.txt
Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\MAIN' | out-file $scriptpath\host_system_info\IE_Info2_$env:computername.txt
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Typedurls' -ErrorAction silentlycontinue | Out-File $scriptpath\host_system_info\IE_Info3_$env:computername.txt

Write-Host "Conducting dirwalk and listing prefetch files" -ForegroundColor green
get-childitem C:\Windows\Prefetch -ErrorAction "silentlycontinue" | select name, lastwritetime, lastaccesstime, creationtime | Out-File $scriptpath\prefetch_$env:computername.txt 
get-childitem C:\ -recurse -ErrorAction "silentlycontinue"| select directory, name, creationtime | ft -auto | out-file $scriptpath\dirwalk_$env:computername.txt 

Write-Host "Conduncting scan of scheduled tasks" -ForegroundColor green
function getTasks($path) 
{
    $out = @()
    # Get root tasks
    $schedule.GetFolder($path).GetTasks(0) | % {
        $xml = [xml]$_.xml
        $out += New-Object psobject -Property @{
            "Name" = $_.Name
            "Path" = $_.Path
            "LastRunTime" = $_.LastRunTime
            "NextRunTime" = $_.NextRunTime
            "Actions" = ($xml.Task.Actions.Exec | % { "$($_.Command) $($_.Arguments)" }) -join "`n"
        }
    }
    # Get tasks from subfolders
    $schedule.GetFolder($path).GetFolders(0) | % {
        $out += getTasks($_.Path)
    }
    #Output
    $out
}
$tasks = @()
$schedule = New-Object -ComObject "Schedule.Service"
$schedule.Connect() 
# Start inventory
$tasks += getTasks("\")
# Close com
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($schedule) | Out-Null
Remove-Variable schedule
# Output all tasks
$tasks | Out-File $scriptpath\host_system_info\scheduled_tasks.$computername.txt


Write-Host "Conduncting local user scan" -ForegroundColor green
#get local user accounts
Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" |
  Select PSComputername, Name, Status, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable, SID | Out-File $scriptpath\host_system_info\local_users_$env:computername.txt
}

elseif($persistence) 
{

Write-Host "Setting up your scripting environment" -ForegroundColor Green

$scriptpath = "$home\desktop\system_info_$env:COMPUTERNAME"

#define your scriptpath
New-Item -ItemType directory -Path $scriptpath
New-Item -ItemType directory -Path $scriptpath\persistence
New-Item -ItemType directory -Path $scriptpath\persistence\services
New-Item -ItemType directory -Path $scriptpath\persistence\run
New-Item -ItemType directory -Path $scriptpath\persistence\wmi

#create your timestamp
get-date | Tee-Object -FilePath $scriptpath\timestamp_$env:COMPUTERNAME.txt

#check for modifications of accessibility features (i.e. sticky keys)
Write-Host "Checking your accessibility features..." -ForegroundColor green
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' | Out-File $scriptpath\persistence\image_file_execution_$env:computername.txt
Get-ItemProperty C:\Windows\System32\sethc.exe | Format-List * | Out-File $scriptpath\persistence\sethc_info_$env:computername.txt
##add hashdeep of sethc

#check for DLL search order hijacking
Write-Host "Collecting the number of instances of dlls in c:\windows and c:\windows\system32" -ForegroundColor green
Get-ChildItem C:\Windows -Recurse -ErrorAction silentlycontinue | Group-Object -Property name | Sort-Object -desc count | Out-File $scriptpath\dllhijacking_$env:computername.txt

#check for modified or new services
Write-Host "Collecting information on your services" -ForegroundColor green
Get-WmiObject win32_service | select -Property displayname, state, pathname | Out-File $scriptpath\persistence\services\service_list_$env:computername.txt
Get-WmiObject win32_service | where-object {$_.state -eq "Running"} | select -Property displayname, processid, state, pathname | out-file $scriptpath\persistence\services\running_$env:computername.txt
Get-EventLog security -InstanceId 4697 -ErrorAction silentlycontinue | Out-File $scriptpath\persistence\services\new_service_eventlog_$env:computername.txt

#check for run and runonce keys
Write-Host "Collecting information on your run and runonce keys" -ForegroundColor green
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $scriptpath\persistence\run\hklm_run_reg_$env:computername.txt
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Runonce | Out-File $scriptpath\persistence\run\hklm_runonce_reg_$env:computername.txt
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $scriptpath\persistence\run\hkcu_run_reg_$env:computername.txt
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce | Out-File $scriptpath\persistence\run\hkcu_runonce_reg_$env:computername.txt
#Write-Host "Collecting information on your startup folders" -ForegroundColor green
#Get-ChildItem 'C:\users\<user>\appdata\roaming\microsoft\windows\start menu\programs\startup' -ErrorAction silentlycontinue

#check for wmi event subscriptions
Write-Host "Collecting information on WMI" -ForegroundColor green
Get-WmiObject -Namespace root\Subscription -Class __FiltertoConsumerBinding | out-file $scriptpath\persistence\wmi\filter_to_consumer_binding_$env:computername.txt

}
elseif($comparison)
{


}
}

#hashes of C:\windows and C:\windows\system32 with hashdeep
#switch with a baseline option and a comparison option




 