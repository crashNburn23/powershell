# Powershell Baseline Script
This is a work in progress. The goal is to create a script that will take a snapshot of interesting data (processes, services, etc) of a machine and have the ability to do a comparison of the snapshot in the future. 

```powershell
[cmdletbinding()]
param([switch]$baseline,[switch]$compare,[switch]$h,[switch]$adcomputer)
if($baseline) {
    Get-Service | Export-Clixml c:\tools\services.xml
    Get-Process | Export-Clixml c:\tools\process.xml
    Write-Host `r`n "    Output is located at c:\tools\process.xml and c:\tools\services.xml" -ForegroundColor Green
    }
elseif($compare) {
    Write-Host `r`n "    Differences are listed below:" -ForegroundColor Cyan
    Compare-Object -ReferenceObject(Import-Clixml C:\tools\services.xml) -DifferenceObject(Get-Service) -Property name, status | Tee-Object -FilePath C:\tools\servicelog.txt
    Compare-Object -ReferenceObject(Import-Clixml C:\tools\process.xml) -DifferenceObject(Get-Process) -Property name | Tee-Object -FilePath C:\tools\processlog.txt
    Write-Host `r`n "    Output is stored at c:\tools\servicelog.txt and c:\tools\processlog.txt" -ForegroundColor Green
    }
elseif($h) {
    Write-Host " Options:" -ForegroundColor Yellow
    Write-Host " -baseline:" `t "Conducts Service and Process List Baseline" -ForegroundColor Yellow
    Write-Host " -compare:" `t`t "Conducts a baseline comparison" -ForegroundColor Yellow
    Write-Host " -adcomputer:" `t "Creates an .xml file of all computers in AD (Requires ActiveDirectory Modules!)" -ForegroundColor Yellow} 
elseif($adcomputer) {
    Get-ADComputer -filter * | Select-Object -property name | ft -HideTableHeaders | Export-Clixml c:\tools\computers.xml
    Write-Host "    Output is located at c:\tools\computers.xml" -ForegroundColor Green
    }
else{
    Write-Host "use -h for switch options" -ForegroundColor Yellow
    }
```
