function dns 

{ 

$a = Get-Content .\ips.txt
foreach($ip in $a)  

{ 

Write-Host "Current DNS Server: " -NoNewline
Write-Host $ip -ForegroundColor DarkCyan
Write-Host "Clearing DNS Cache"
Clear-DnsClientCache
Set-DnsClientServerAddress -ServerAddresses $ip -InterfaceIndex 14
    if (Resolve-DnsName "www.aol.com")
    {
        Write-Host "Server Up" -BackgroundColor Black -ForegroundColor Green
    }
    else
    {
        Write-Host "Error on Server $ip" -BackgroundColor Black -ForegroundColor Red
        Get-Date | Out-File .\errors.txt 
        #$error = New-Object -ComObject wscript.shell
        #$message = $error.popup("Error on server: $ip")
        #$message 
    }



}

}

while ($true)
{
dns
Start-Sleep -Seconds 5
clear
}