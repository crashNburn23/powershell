[cmdletbinding()] 
param([switch]$baseline, [switch]$persistence, [switch]$hash, [switch]$help)
if($baseline) 
{
Write-Host "Creating your results folder" -ForegroundColor Green -BackgroundColor Black
$path = "$home\desktop\baseline_$env:COMPUTERNAME" 

#Create the folders that will store the data
New-Item -ItemType Directory -Path $path | Out-Null
New-Item -ItemType Directory -Path $path\network_info | Out-Null
New-Item -ItemType Directory -Path $path\host_system_info | Out-Null 
New-Item -ItemType Directory -Path $path\reg | Out-Null
New-Item -ItemType Directory -Path $path\eventlog | Out-Null

#create a timestamp that will record when the script was ran
get-date | Out-File $path\timestamp.txt 

#collect information on processes
Write-Host "Collecting Process information" -ForegroundColor Green -BackgroundColor Black
Get-Process | Sort-Object -Descending WS | Out-File $path\host_system_info\tasklist_desceding.txt
Get-WmiObject win32_process | Select name, processid, executablepath, commandline | Out-File $path\host_system_info\tasklist_detailed.txt
Get-WmiObject win32_process | select processname,@{NAME='CreationDate';EXPRESSION={$_.ConvertToDateTime($_.CreationDate)}},ProcessId,ParentProcessId,CommandLine,sessionID |sort ParentProcessId | Out-File $path\host_system_info\processes_creationtime.txt
openfiles.exe > $path\host_system_info\open_files.txt

#collect information on software on the system
Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Select DisplayName,DisplayVersion,Publisher,InstallDate,InstallLocation | Sort InstallDate -Desc  | Out-File $path\host_system_info\software.txt 

#selects all of the svchost.exe's that are running and ties them to a service under win32_service
Get-WmiObject win32_process -ErrorAction SilentlyContinue | where {$_.name -eq 'svchost.exe'} | select ProcessId |foreach-object {$P = $_.ProcessID ;gwmi win32_service |where {$_.processId -eq $P} | select processID,name,DisplayName,state,startmode,PathName} | Out-File $path\host_system_info\svchost_in_processlist.txt

#collect information on the volume shadow copy
Write-Host "Collecting information on the VSC" -ForegroundColor Green -BackgroundColor Black
Get-WmiObject Win32_ShadowCopy -ErrorAction SilentlyContinue | select DeviceObject,@{NAME='CreationDate';EXPRESSION={$_.ConvertToDateTime($_.InstallDate)}} | Out-File $path\host_system_info\volumeshadow.txt
vssadmin.exe list shadows > $path\host_system_info\vsc_vssadmin.txt

#Collect a descending list of the prefetch
Write-Host "Collecting information on the prefetch" -ForegroundColor Green -BackgroundColor Black
Get-ChildItem C:\windows\prefetch\*.pf -ErrorAction SilentlyContinue | select Name, LastAccessTime,CreationTime | sort LastAccessTime -Descending | Out-File $path\host_system_info\prefetch.txt

#Collect information on the operating system
Write-Host "Collecting OS and NIC information" -ForegroundColor Green -BackgroundColor Black
Get-WmiObject win32_operatingsystem | Format-List * | Out-File $path\host_system_info\os_info_detailed.txt
Get-WmiObject win32_operatingsystem | Select-Object -property csname, osarchitecture, name, freephysicalmemory, freespaceinpagingfiles, freevirtualmemory, serialnumber | Out-File $path\host_system_info\architecture.txt
Get-WmiObject -ea 0 Win32_StartupCommand | select command,user,caption | Out-File $path\host_system_info\startupcommand.txt
Get-HotFix | Out-File $path\host_system_info\hotfix.txt

#print out network adapter info
Get-WmiObject win32_networkadapter | select netconnectionid, name, interfaceindex, netconnectionstatus | Format-Table | Out-File $path\network_info\netadapters.txt
ipconfig /all | Out-File $path\network_info\ipconfig.txt
ipconfig /displaydns | Out-File $path\network_info\dns.txt
Get-NetTCPConnection | where-object state -eq Established | where-object remoteaddress -notlike 127.0.0.1 | Select OwningProcess, LocalAddress, LocalPort, RemoteAddress, RemotePort | Format-Table | Out-File $path\network_info\nettcpinfo.txt

#collect information on the current time and timezone
Write-Host "Collecting locattime information" -ForegroundColor Green -BackgroundColor Black
Get-WmiObject win32_localtime | Select-Object month,day,year,hour,minute,second | Out-File $path\host_system_info\time.txt
[system.timezone]::currenttimezone | Out-File $path\host_system_info\timezone.txt

#collect information on auditing policy
Write-Host "Collecting info on auditing policy and firewall settings" -ForegroundColor Green -BackgroundColor Black
auditpol /get /category:* | Out-File $path\host_system_info\timezone.txt
netsh advfirewall show allprofiles | Out-File $path\host_system_info\firewall.txt

#Collect information on network shares
Write-Host "Collecting Network Shares Information" -ForegroundColor Green -BackgroundColor Black
Get-WmiObject -Class Win32_Share | Out-File $path\network_info\network_shares.txt

Write-Host "Collecting Services Information" -ForegroundColor Green -BackgroundColor Black
Get-WmiObject win32_service | select Name, DisplayName, State | Out-File $path\host_system_info\services.txt
Get-WmiObject win32_service | select name, path | Out-File $path\host_system_info\services_path.txt
Get-ItemProperty 'hkcu:\Software\Microsoft\Windows\CurrentVersion\explorer\Map Network Drive MRU' -ErrorAction SilentlyContinue | Out-File $path\network_info\network_drive_mru.txt

#collect information on the network connections
netstat -anob > $path\network_info\netstat_anob.txt

#collect information on name pipes
Write-Host "Gathering named pipes" -foregroundcolor green -backgroundcolor black
[System.IO.Directory]::GetFiles("\\.\\pipe\\") | Out-File $path\host_system_info\name_pipes.txt

#collect information on reg keys of interest
Write-Host "Conducting Reg Queries" -ForegroundColor Green -BackgroundColor Black
Get-ItemProperty HKLM:\Software | Out-File $path\reg\hklm_software_reg.txt
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $path\reg\hklm_run_reg.txt
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Runonce | Out-File $path\reg\hklm_runonce_reg.txt
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $path\reg\hkcu_run_reg.txt
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce | Out-File $path\reg\hkcu_runonce_reg.txt
Get-ItemProperty 'HKLM:\software\wow6432node\microsoft\windows\currentversion\Run' -ErrorAction SilentlyContinue | Out-File $path\reg\hklm_wow_run.txt 
Get-ItemProperty 'HKLM:\software\wow6432node\microsoft\windows\currentversion\runonce' -ErrorAction SilentlyContinue | Out-File $path\reg\hklm_wow_runonce.txt
Get-ItemProperty 'HKCU:\software\wow6432node\microsoft\windows\currentversion\runonce' -ErrorAction SilentlyContinue | Out-File $path\reg\hkcu_wow_runonce.txt 

#this will tell you the internet explorer version being ran
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Internet Explorer' | Out-File $path\reg\IE_Info.txt

#can tell you some IE defaults (search page, default page)
Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\MAIN' | out-file $path\reg\IE_defaults.txt
Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\Typedurls' -ErrorAction silentlycontinue | Out-File $path\reg\type_urls.txt

#Other Random Reg keys
Get-ItemProperty 'HKLM:\Software\Microsoft\Active Setup\Installed Components\*' -ErrorAction SilentlyContinue | select ComponentID,'(default)',StubPath | Out-File $path\reg\install_components_reg.txt
Get-ItemProperty 'hklm:\Software\Microsoft\Windows\CurrentVersion\App Paths\*' -ErrorAction SilentlyContinue | select ComponentID,'(default)',StubPath | Out-File $path\reg\app_path.txt
Get-ItemProperty 'hklm:\software\microsoft\windows nt\CurrentVersion\winlogon\*\*' | select '(default)',DllName | Out-File $path\reg\winlogon_dlls.txt
Get-ItemProperty 'hkcu:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths' | Out-File $path\reg\win_explorer_typedurls.txt
Get-ItemProperty 'hklm:\SOFTWARE\Classes\HTTP\shell\open\command' | select '(default)' | Out-File $path\reg\iexplore_shell.txt
Get-ItemProperty 'hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\*' | select '(default)' | Out-File $path\reg\iexplore_browser_helper.txt
Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\*' | select '(default)' | Out-File $path\reg\iexplore_wow_browser_helper.txt
Get-ItemProperty 'hklm:\Software\Microsoft\Internet Explorer\Extensions\*' | select ButtonText, Icon | Out-File $path\reg\iexplore_extensions.txt
Get-ItemProperty 'hklm:\Software\Wow6432Node\Microsoft\Internet Explorer\Extensions\*' | select ButtonText, Icon | Out-File $path\reg\iexplore_wow_extensions.txt
Get-ItemProperty 'hklm:\system\currentcontrolset\enum\usbstor\*\*' -ErrorAction SilentlyContinue | select FriendlyName,PSChildName,ContainerID | Out-File $path\reg\usb_enum.txt

#collect information on windows event logs
Get-WinEvent -max 50 -ea 0 -FilterHashtable @{Logname='application';ID=1002} | select TimeCreated,ID,Message | Out-File $path\eventlog\application_install.txt
Get-WinEvent -max 50 -ea 0 -FilterHashtable @{Logname='security';ID=4625} | select TimeCreated,ID,Message | Out-File $path\eventlog\failed_logins.txt
Get-WinEvent -max 50 -ea 0 -FilterHashtable @{Logname='security';ID=4624} | select TimeCreated,ID,Message | Out-File $path\eventlog\last50_logins.txt
Get-WinEvent -max 50 -ea 0 -FilterHashtable @{Logname='security';ID=4688} | select TimeCreated,ID,Message | Out-File $path\eventlog\last50_processes_started.txt
Get-WinEvent -max 50 -ea 0 -FilterHashtable @{Logname='security';ID=4720} | select TimeCreated,ID,Message | Out-File $path\eventlog\user_created.txt
Get-WinEvent -max 50 -ea 0 -FilterHashtable @{Logname='security';ID=4672} | select TimeCreated,ID,Message | Out-File $path\eventlog\admin_logins.txt
Get-WinEvent -max 50 -ea 0 -FilterHashtable @{Logname='system';ID=64001} | select TimeCreated,ID,Message | Out-File $path\eventlog\file_replacement.txt

Write-Host "Conduncting scan of scheduled tasks" -ForegroundColor Green -BackgroundColor Black
Get-ScheduledTask | select TaskName, TaskPath, Description, URI, State -ErrorAction SilentlyContinue | Out-File $path\host_system_info\scheduledtasks.txt

#list items in scheduled tasks folder
Get-ChildItem C:\Windows\System32\tasks -filter * | Out-File $path\host_system_info\scheduledtasks_folder.txt

#get local user accounts
Write-Host "Conduncting local user scan" -ForegroundColor Green -BackgroundColor Black
Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" |
  Select PSComputername, Name, Status, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable, SID | Out-File $path\host_system_info\local_users.txt
Get-WmiObject -ea 0 Win32_UserProfile | select LocalPath, SID,@{NAME='last used';EXPRESSION={$_.ConvertToDateTime($_.lastusetime)}} | Out-File $path\host_system_info\local_users_lastused.txt

#collects information on the last 50 accessed .dlls 
Get-ChildItem c:\ -Filter *.dll -Recurse -erroraction silentlycontinue | select name, creationdate, lastaccesstime, directory | sort creationtime -Descending | select -First 50 | Out-File $path\host_system_info\last50_dlls.txt

#collect information on drivers and unsigned drivers
driverquery /SI | Out-File $path\host_system_info\drivers.txt
driverquery /SI | Select-String -NotMatch "true" | Out-File $path\host_system_info\drivers_unsigned.txt

}

elseif($persistence) 
{
Write-Host "Creating the results folder" -ForegroundColor Green -BackgroundColor blac

$path = "$home\desktop\Persistence_$env:COMPUTERNAME"

#Creating the rest of the folders
New-Item -ItemType directory -Path $path | Out-Null
New-Item -ItemType directory -Path $path\persistence | Out-Null
New-Item -ItemType directory -Path $path\persistence\services | Out-Null
New-Item -ItemType directory -Path $path\persistence\run | Out-Null
New-Item -ItemType directory -Path $path\persistence\wmi | Out-Null

#Create a timestamp
get-date | out-file $path\timestamp.txt

#check for modifications of accessibility features (i.e. sticky keys)
Write-Host "Checking your accessibility features" -ForegroundColor Green -BackgroundColor Black
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' | Out-File $path\persistence\image_file_execution.txt
Get-ItemProperty C:\Windows\System32\sethc.exe | Format-List * | Out-File $path\persistence\sethc_info.txt
Get-FileHash C:\Windows\System32\sethc.exe -Algorithm MD5 -ErrorAction SilentlyContinue | Out-File $path\persistence\sethc_info.txt -Append

#check for modified or new services
Write-Host "Collecting information on your services" -ForegroundColor Green -BackgroundColor Black
Get-WmiObject win32_service | select -Property displayname, state, pathname | Out-File $path\persistence\services\service_list.txt
Get-WmiObject win32_service | where-object {$_.state -eq "Running"} | select -Property displayname, processid, state, pathname | Out-File $path\persistence\services\running.txt

#looks for services that were installed
Get-EventLog Security -InstanceId 4697 -ErrorAction silentlycontinue | Out-File $path\persistence\services\new_service_eventlog.txt

#check for run and runonce keys
Write-Host "Collecting information on your run and runonce keys" -ForegroundColor Green -BackgroundColor Black
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $path\persistence\run\hklm_run_reg.txt
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Runonce | Out-File $path\persistence\run\hklm_runonce_reg.txt
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File $path\persistence\run\hkcu_run_reg.txt
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce | Out-File $path\persistence\run\hkcu_runonce_reg.txt

#Write-Host "Collecting information on your startup folders" -ForegroundColor green

#Get-ChildItem 'C:\users\<user>\appdata\roaming\microsoft\windows\start menu\programs\startup' -ErrorAction silentlycontinue

#check for wmi event subscriptions
Write-Host "Collecting information on WMI" -ForegroundColor Green -BackgroundColor Black
Get-WmiObject -Namespace root\Subscription -Class __FiltertoConsumerBinding | Out-File $path\persistence\wmi\filter_to_consumer_binding.txt

}
elseif($hash)
{
Write-Host "Hashing C:\windows" -ForegroundColor Green -BackgroundColor Black
Get-ChildItem C:\Windows | Get-FileHash -Algorithm SHA1 -ErrorAction SilentlyContinue | Out-File $home\desktop\windows_hash.txt

Write-Host "Hashing C:\Windows\System32 -recurse" -ForegroundColor Green -BackgroundColor Black
Get-ChildItem C:\Windows\System32 -Recurse -ErrorAction SilentlyContinue | Get-FileHash -Algorithm MD5 | Out-File $home\desktop\system32_hash.txt
}

elseif($help)
{ 
Write-Host " -baseline `t`t Conduct a baseline scan of the host machine. Results stored on user's desktop." -ForegroundColor Green -BackgroundColor Black
Write-Host " -persistence `t Conduct a scan that scans common areas where persistence is found. Results stored on the Desktop."  -ForegroundColor Green -BackgroundColor Black
Write-Host " -hash `t`t`t Conduct a hash of files located in C:\windows and C:\windows\system32 -recurse" -ForegroundColor Green -BackgroundColor Black
}
else 
{
Write-Host "Use -help for switch options." -ForegroundColor Red -BackgroundColor Black
}




 
