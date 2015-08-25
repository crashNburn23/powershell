# Powershell Baseline Script
This is a work in progress. The goal is to create a script that will take a snapshot of interesting data (processes, services, etc) of a machine and have the ability to do a comparison of the snapshot in the future. 

```powershell
[cmdletbinding()]
param([switch]$baseline_local,[switch]$compare_local,[switch]$h,[switch]$adcomputer,[switch]$baseline_all,[switch]$compare_all,[switch]$run)
if($baseline_local) {
    Get-Service | Export-Clixml c:\tools\services.xml;
    Get-Process | Export-Clixml c:\tools\process.xml;
    Write-Host `r`n "    Output is located at c:\tools\process.xml and c:\tools\services.xml" -ForegroundColor Green;
    }
elseif($compare_local) {
    Write-Host `r`n "    Differences are listed below:" -ForegroundColor Cyan;
    Compare-Object -ReferenceObject(Import-Clixml C:\tools\services.xml) -DifferenceObject(Get-Service) -Property name, status | Tee-Object -FilePath C:\tools\servicelog.txt;
    Compare-Object -ReferenceObject(Import-Clixml C:\tools\process.xml) -DifferenceObject(Get-Process) -Property name | Tee-Object -FilePath C:\tools\processlog.txt;
    Write-Host `r`n "    Output is stored at c:\tools\servicelog.txt and c:\tools\processlog.txt" -ForegroundColor Green;
    }
elseif($adcomputer) {
    Get-ADComputer -filter * | Select-Object -property name | ft -HideTableHeaders | Export-Clixml c:\tools\computers.xml;
    Write-Host "    Output is located at c:\tools\computers.xml" -ForegroundColor Green;
    }
elseif($baseline_all) {

}
elseif($compare_all) {

}
elseif($run) {
Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run | Tee-Object -FilePath C:\Tools\run.txt
Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce | Tee-Object -FilePath C:\Tools\runonce.txt
}
elseif($h) {
    Write-Host " Options:" -ForegroundColor Green
    Write-Host " -baseline_local:" `t "Conducts Service and Process List Baseline" -ForegroundColor Green
    Write-Host " -compare_local:" `t "Conducts a baseline comparison" -ForegroundColor Green
    Write-Host " -adcomputer:" `t`t "Creates an .xml file of all computers in AD (Requires ActiveDirectory Modules!)" -ForegroundColor Green
    Write-Host " -baseline_all:" `t "Conducts Service and Proces List Baseline for all AD Computers (or whatever is in C:\Tools\computers.xml" -ForegroundColor Green    
    Write-Host " -compare_all:" `t`t "Conducts a baseline for all AD Computers" -ForegroundColor Green
    Write-Host " -run:" `t`t`t`t "Stores the run and runonce keys into a text file" -ForegroundColor Green
} 
else{
    Write-Host "use -h for switch options" -ForegroundColor Yellow
    }
```
