## This script should be modified for use on multiple computers (i.e. define a variable ($computers with all computer names), foreach($computer in $computers), Invoke-Command -computername $computer script-block{ }
## Additionally baselining should not be limited to what I put in here, it should be tailored and intel driven

[cmdletbinding()]
param([switch]$help,[switch]$baseline,[switch]$compare,[switch]$adcomputer)
if($baseline) {
    Get-Service | Export-Clixml c:\services.xml
    Get-Process | Export-Clixml c:\process.xml
    Write-Host "      Output is located at c:\services.xml and c:\process.xml" -ForegroundColor Green}
Elseif($compare) {
    Compare-Object -ReferenceObject(Import-Clixml c:\services.xml) -DifferenceObject(get-service) -Property name, status | Out-File c:\servicelog.txt
    Compare-Object -ReferenceObject(import-clixml c:\process.xml) -DifferenceObject(get-process) -Property name | Out-file c:\processlog.txt
    Write-Host "      Output is located at c:\servicelog.txt and c:\processlog.txt" -ForegroundColor Green}
Elseif($adcomputer) {
    Get-Adcomputer -filter * | Select-Object -Property name | ft -HideTableHeaders | Export-Clixml c:\computers.xml
    Write-Host "      Output is located at c:\computers.xml" -ForegroundColor Green}
Else{
    Write-Host "use -h for switch options" -ForegroundColor yellow }