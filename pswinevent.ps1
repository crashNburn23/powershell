[cmdletbinding()]
param([switch]$csv,[switch]$txt,[string]$filepath)

#Set the console color to black and green
$console = $host.ui.rawui
$console.BackgroundColor="black"
$console.ForegroundColor="green"
cls
Write-Host "Let's get rid of those nasty powershell colors" -ForegroundColor Yellow  

$events= (4672,4720,4722,624,4625,539,2,3,21,400,4698,1008,1006,219,3001,3002,3003,3004,3010,3023,6281,5038,6,6005,1102,104,2006,2033,2005,2004,7022,7023,7024,7026,7031,7032,7034,2,1001,1002,865,866,867,868,882,8006,8007)
$count = $events.count

#Define what happens with the -csv
if($csv)
{

#create a folder on the desktop
Write-Host "Creating a folder on your desktop called eventlogs" -ForegroundColor Yellow
mkdir $env:USERPROFILE\desktop\eventlogs | out-null

#create a for loop that will go through each of the identified security ids

Write-Host "Parsing out select windows event logs" -ForegroundColor Yellow
$i = 0
foreach($event in $events)
{
$i = $i + 1

Write-Progress -Activity "Parsing Data" -Status "Going through event id $event" -PercentComplete ($i/$count*100) 

Get-WinEvent -Path $filepath | Where-Object {$_.id -eq $event} | Export-Csv -Path $env:USERPROFILE\Desktop\eventlogs\events_$event.csv -Append

}

Write-Host "Parsing Complete" -ForegroundColor Yellow

}

#Define what happens with the -txt
if($txt)
{

#create a folder on the desktop
Write-Host "Creating a folder on your desktop called eventlogs" -ForegroundColor Yellow
mkdir $env:USERPROFILE\desktop\eventlogs | out-null

#create a for loop that will go through each of the identified security ids
Write-Host "Parsing out select windows event logs" -ForegroundColor Yellow
$i = 0 
foreach($event in $events)
{
$i = $i + 1

Write-Progress -Activity "Parsing Data" -Status "Going through event id $event" -PercentComplete ($i/$count) 

Get-WinEvent -Path $filepath | Where-Object {$_.id -eq $event} | Select timecreated,providername,id,level,logname,processid,message | Format-List | Out-File $env:USERPROFILE\Desktop\eventlogs\events_$event.txt

}

Write-Host "Parsing Complete" -ForegroundColor Yellow


}


#Send out an error message if nothing is provided
else
{
write-host "
Help: 

Use the following format: 

.\pswinevet.ps1 -switch <path to security.evtx>

Switches available: 

-csv   Use this switch to output your results as a csv file
-txt   Use this switch to output your results as a txt file

" -ForegroundColor Green
}


