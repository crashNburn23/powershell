[cmdletbinding()]
param([switch]$baseline,[switch]$compare,[switch]$h,[switch]$adcomputer)
if($baseline) {
    Get-Service | Export-Clixml c:\services.xml
    Get-Process | Export-Clixml c:\process.xml
    Write-Host "    Output is located at c:\process.xml and c:\services.xml" -ForegroundColor Green}
elseif($compare) {
    Compare-Object -ReferenceObject(Import-Clixml C:\services.xml) -DifferenceObject(Get-Service) -Property name, status | Out-File C:\servicelog.txt
    Compare-Object -ReferenceObject(Import-Clixml C:\process.xml) -DifferenceObject(Get-Process) -Property name | Out-File C:\processlog.txt
    Write-Host "    Output is located at c:\servicelog.txt and c:\processlog.txt" -ForegroundColor Green}
elseif($h) {
    Write-Host " "
    Write-Host "    Options:" 
    Write-Host "        -baseline:     Conducts Service and Process List Baseline"
    Write-Host "        -compare:      Conducts a baseline comparison" 
    Write-Host "        -adcomputer    Creates an .xml file of all computers in AD (Requires ActiveDirectory Modules!)"}
elseif($adcomputer) {
    Get-ADComputer -filter * | Select-Object -property name | ft -HideTableHeaders | Export-Clixml c:\computers.xml
    Write-Host "    Output is located at c:\computers.xml" -ForegroundColor Green}
else{
    Write-Host "use -h for switch options" -ForegroundColor Yellow}