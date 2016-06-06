[cmdletbinding()]
param([switch]$pull, [switch]$filter)
if($pull)
{
#Create a variable for the desktop location and create a text document to save information
$location = $env:USERPROFILE\desktop
New-Object $location\emails.txt

Write-Host "Provide your gmail credentials" -ForegroundColor Green
$gmail = New-GmailSession
$inbox = $gmail | Get-Mailbox

Write-Host "Searching through your emails" -ForegroundColor Green 
$emails = $inbox | Get-Message -body "RSVP: Accepted" | Receive-Message
$emails | select body | Format-List | Out-File $location\emails.txt

Write-Host "Download Complete. Emails stored on your desktop. Use the -filter option to display parsed email addresses" -ForegroundColor Green
}

elseif($filter)
{
Select-String "RSVP submitted by" $location\emails.txt | ForEach-Object{$_.Line} | Out-File -FilePath $location\filtered.txt
Get-Content $location\filtered.txt | %{$_ -split " "} | Out-File -FilePath $location\contactlist.txt
Remove-Item $location\emails.txt, $location\filtered.txt
}

else
{
Write-Host "
Use -pull to download email messages
Use -filter to display email addresses that have RSVP'd
"
}
