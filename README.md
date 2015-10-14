# Powershell Baseline Script
This is a work in progress. The goal is to create a script that will take a snapshot of interesting data (processes, services, etc) of a machine and have the ability to do a comparison of the snapshot in the future. 

```powershell
 
[cmdletbinding()]  
param([switch]$baseline_local, [switch]$persistence, [switch]$help)  
if($baseline_local)   
{  
  
Write-Host "Creating your file" -ForegroundColor Green  
  
$path = "$home\desktop\baseline_$env:COMPUTERNAME"  
  
#define your path  
New-Item -ItemType directory -Path $path | out-null 
New-Item -ItemType directory -Path $path\network | out-null   
New-Item -ItemType directory -Path $path\host  | out-null  
  
#create your timestamp  
get-date | Tee-Object -FilePath $path\timestamp.txt  
  
Write-Host "Gathering information on processes" -ForegroundColor Green 
Get-Process | Sort-Object -Descending WS | Out-File $path\host\tasklist_.txt  
Get-WmiObject win32_process | select name,processid,path,description,starttime | ft -AutoSize | Out-File $path\host\process_path.txt 
  
Write-Host "Gathering OS information" -foregroundcolor green  
 
 
#print out basic OS information  
Get-WmiObject win32_operatingsystem | Format-List * | Out-File $path\host\os_info.txt  
Get-WmiObject win32_operatingsystem | Select-Object -property csname, osarchitecture, name, freephysicalmemory, freespaceinpagingfiles, freevirtualmemory, serialnumber | Out-File $path\host\architecture.txt  
Write-Host "Getting information on your hot fixes" -ForegroundColor Green 
Get-HotFix | Out-File $path\host\hotfix.txt 
 
 
Write-Host " getting info on audits" -ForegroundColor Green 
$audit = auditpol /get /category:*  
$audit | Out-File $path\host\auditpol.txt 
 
 
#print out network adapter info  
Get-WmiObject win32_networkadapter | select netconnectionid, name, interfaceindex, netconnectionstatus | Format-Table | Out-File $path\network\network.txt  
ipconfig /all | Out-File $PATH\network\network.txt  
#Start-Process .\promiscdetect.exe | Out-File $path\network\promisc.txt 
$net = netstat -anob 
$net | Out-File $path\network\netstat_anob.txt 
$net | Select-String listening | Out-File $path\network\netstat_listening.txt 
$net | Select-String established | Out-File $path\network\netstat_established.txt 
$dnschace = ipconfig /displaydns 
$dnschace | Out-File $path\network\dnscache.txt 
  
Write-Host "Gathering named pipes" -ForegroundColor Green 
[System.IO.Directory]::GetFiles("\\.\\pipe\\") | Out-File $path\host\name_pipes.txt 
  
Write-Host "Gathering local time information" -ForegroundColor green  
Get-WmiObject win32_localtime | Select-Object month,day,year,hour,minute,second | Out-File $path\host\time.txt  
[system.timezone]::currenttimezone | Out-File $path\host\timezone.txt  
  
Write-Host "Gathering Network Shares Information" -ForegroundColor green  
Get-WmiObject Win32_NetworkConnection | Out-File $path\network\network_shares_2.txt  
Get-WmiObject -Query "Select * From Win32_LogicalDisk Where DriveType = 4" | Out-File $path\network\network_shares.txt  
Get-WmiObject -Class Win32_Share | Out-File $path\network\network_shares.txt  
  
Write-Host "Gathering Services Information" -ForegroundColor green  
Get-WmiObject win32_service | select Name, DisplayName, State, PathName | Out-File $path\host\services.txt  
  
Write-Host "Gathering Reg Queries" -ForegroundColor green  
Get-ItemProperty HKLM:\Software | Out-File $path\host\hklm_software_reg.txt  
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $path\host\hklm_run_reg.txt  
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Runonce | Out-File $path\host\hklm_runonce_reg.txt  
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $path\host\hkcu_run_reg.txt  
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce | Out-File $path\host\hkcu_runonce_reg.txt  
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Internet Explorer' | Out-File $path\host\IE_reg.txt  
Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\MAIN' | out-file $path\host\IE_main.txt  
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Typedurls' -ErrorAction silentlycontinue | Out-File $path\host\IE_typed_urls.txt  
  
Write-Host "Doing a directory listing and listing prefetch files" -ForegroundColor green  
get-childitem C:\Windows\Prefetch -ErrorAction "silentlycontinue" | select name, lastwritetime, lastaccesstime, creationtime | Out-File $path\prefetch.txt   
#get-childitem C:\ -recurse -ErrorAction "silentlycontinue"| select directory, name, creationtime | ft -auto | out-file $path\dirwalk.txt   
  
Write-Host "Doing a scan of scheduled tasks" -ForegroundColor green  
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
$tasks | Out-File $path\host\scheduled_tasks.txt  
  
Write-Host "Doing a local user scan" -ForegroundColor green  
#get local user accounts  
Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" |  
  Select PSComputername, Name, Status, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable, SID | Out-File $path\host\local_users.txt  
 
 
Get-ChildItem C:\Windows\System32\tasks -filter * | Out-File $path\host\scheduledtasks_folder.txt 
 
 
driverquery /SI | Out-File $path\host\drivers.txt 
driverquery /SI | Select-String -NotMatch "true" | Out-File $path\host\drivers_unsigned.txt 
 
 
}  
  
elseif($persistence)   
{  
  
Write-Host "Creating your file" -ForegroundColor Green  
$path = "$home\desktop\Persistence_info_$env:COMPUTERNAME"  
 
 
#define your path  
New-Item -ItemType directory -Path $path | Out-Null 
New-Item -ItemType directory -Path $path\persistence | Out-Null  
New-Item -ItemType directory -Path $path\persistence\services | Out-Null 
New-Item -ItemType directory -Path $path\persistence\run | Out-Null 
New-Item -ItemType directory -Path $path\persistence\wmi | Out-Null 
  
#create your timestamp  
get-date | Tee-Object -FilePath $path\timestamp.txt  
  
#check for modifications of accessibility features (i.e. sticky keys)  
Write-Host "Checking your accessibility features..." -ForegroundColor green  
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' | Out-File $path\persistence\image_file_execution.txt  
Get-ItemProperty C:\Windows\System32\sethc.exe | Format-List * | Out-File $path\persistence\sethc_info.txt  
 
 
##collecting hash information 
Write-Host " Gathering hashes of c:\windows and c:\windows\system32" -ForegroundColor Green 
Get-FileHash C:\Windows\System32\sethc.exe -Algorithm MD5 -erroraction silentlycontinue | Out-File $path\persistence\sethc_hash.txt 
Get-FileHash C:\Windows\* -Algorithm md5 -erroraction silentlycontinue | Out-File $path\persistence\windows_hash.txt 
Get-FileHash C:\Windows\System32\* -Algorithm MD5 -erroraction silentlycontinue | Out-File $path\persistence\system32_hash.txt 
  
#check for DLL search order hijacking  
Write-Host "Collecting the number of instances of dlls in c:\windows and c:\windows\system32" -ForegroundColor green  
Get-ChildItem C:\Windows -filter *.dll -Recurse -ErrorAction silentlycontinue | Group-Object -Property name | Sort-Object -desc count | Out-File $path\dllhijacking.txt  
  
#check for modified or new services  
Write-Host "Collecting information on your services" -ForegroundColor green  
Get-WmiObject win32_service | select -Property displayname, state, pathname | ft -AutoSize | Out-File $path\persistence\services\service_list.txt  
Get-WmiObject win32_service | where-object {$_.state -eq "Running"} | select -Property displayname, processid, state, pathname | out-file $path\persistence\services\running.txt  
Get-EventLog security -InstanceId 4697 -ErrorAction silentlycontinue | Out-File $path\persistence\services\new_service_eventlog.txt  
   
#check for run and runonce keys  
Write-Host "Collecting information on your run and runonce keys" -ForegroundColor green  
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $path\persistence\run\hklm_run_reg.txt  
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Runonce | Out-File $path\persistence\run\hklm_runonce_rege.txt  
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $path\persistence\run\hkcu_run_reg.txt  
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce | Out-File $path\persistence\run\hkcu_runonce_reg.txt  
#Write-Host "Collecting information on your startup folders" -ForegroundColor green  
#Get-ChildItem 'C:\users\<user>\appdata\roaming\microsoft\windows\start menu\programs\startup' -ErrorAction silentlycontinue  
  
#check for wmi event subscriptions  
Write-Host "Collecting information on WMI" -ForegroundColor green  
Get-WmiObject -Namespace root\Subscription -Class __FiltertoConsumerBinding | out-file $path\persistence\wmi\filter_to_consumer_binding.txt  
   
}  
elseif($help)  
{  
Write-Host "use -baseline to conduct a baseline of your current system" -ForegroundColor green  
Write-Host "use -persistence to conduct a IOC scan that checks for known methods of persistence" -ForegroundColor green  
}  
   
else  
{  
write-host "use -h for switch options" -foregroundcolor red  
}  
   
#hashes of C:\windows and C:\windows\system32 with hashdeep  
#switch with a baseline option and a comparison option  
  
#$windowsthings = (Get-ChildItem C:\Windows -Filter *.dll).Name 
#foreach ($file in $windowsthings) { Test-Path C:\Windows\System32\$file } 
# (get-process notepad).handle  
# $processes = Get-Process | select name  
# foreach ($process in $processes) { (get-process $_.name).handle } 
 
 
#.\Listdlls.exe /accepteula > C:\Users\dci1\Desktop\dlls.txt 
#Get-Content .\dlls.txt | Select-String -NotMatch "system32" 

```
