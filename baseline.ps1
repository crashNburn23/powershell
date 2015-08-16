[cmdletbinding()]
param([switch]$baseline,[switch]$compare,[switch]$h,[switch]$adcomputer)
if($baseline) {
    Get-Service | Export-Clixml c:\tools\services.xml
    Get-Process | Export-Clixml c:\tools\process.xml
    Write-Host "    Output is located at c:\tools\process.xml and c:\tools\services.xml" -ForegroundColor Green}
elseif($compare) {
    Compare-Object -ReferenceObject(Import-Clixml C:\tools\services.xml) -DifferenceObject(Get-Service) -Property name, status | Out-File C:\tools\servicelog.txt
    Compare-Object -ReferenceObject(Import-Clixml C:\tools\process.xml) -DifferenceObject(Get-Process) -Property name | Out-File C:\tools\processlog.txt
    $a= Compare-Object -ReferenceObject(Import-Clixml C:\tools\services.xml) -DifferenceObject(Get-Service) -Property name, status 
    $b= Compare-Object -ReferenceObject(Import-Clixml C:\tools\process.xml) -DifferenceObject(Get-Process) -Property name
    Write-Host "    Output is located at c:\tools\servicelog.txt and c:\tools\processlog.txt" -ForegroundColor Green
    Write-Host "Service changes are below:" -ForegroundColor Cyan
    Write-Output $a 
    Write-Host "Process changes are below:" -ForegroundColor Cyan
    Write-Output $b 
   }
elseif($h) {
    Write-Host " "
    Write-Host "    Options:" 
    Write-Host "        -baseline:     Conducts Service and Process List Baseline"
    Write-Host "        -compare:      Conducts a baseline comparison" 
    Write-Host "        -adcomputer    Creates an .xml file of all computers in AD (Requires ActiveDirectory Modules!)"}
elseif($adcomputer) {
    Get-ADComputer -filter * | Select-Object -property name | ft -HideTableHeaders | Export-Clixml c:\tools\computers.xml
    Write-Host "    Output is located at c:\tools\computers.xml" -ForegroundColor Green}
else{
    Write-Host "use -h for switch options" -ForegroundColor Yellow}

   