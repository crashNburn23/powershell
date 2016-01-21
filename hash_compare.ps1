#Define the Get-Filename function

Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} 

# Create a variable of unknown hashes
Write-Host "Select the file of the uknown hashes" -ForegroundColor Green
$hashes = get-content (Get-FileName -initialDirectory "c:\")

# Create a variable of bad hashes
Write-Host "Select the file of the bad hashes" -ForegroundColor Green
$bad = get-content (Get-FileName -initialDirectory "c:\" )

# Create a counter that will be used to print the number of bad hashes found
$num = 0

# Create a text file that will contain all of the bad hashes found
New-Item -ItemType File -Name bad_hashes.txt | Out-Null

# Loop through each of the hashes and check if it is present in bad hashes
foreach ($hash in $hashes) 
{
    if ($bad -contains $hash) 
    {
        $hash | Tee-Object -Append bad_hashes.txt
        $num = $num + 1
    };
 }

Write-Host "$num bad hashes found" -ForegroundColor Green