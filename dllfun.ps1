[cmdletbinding()]
param([switch]$hashthem,[switch]$fileversion,[switch]$help)
if ($hashthem)
{
#collect the dlls and hashes
$files = @(Get-ChildItem C:\ -Filter *.dll -recurse -erroraction silentlycontinue | get-filehash)    # @() forces a one-item answer to still be an array

# create a blank hashtable
$hashtable = @{}

$dllsofinterest= ""
$cleandlls = ""
#loop through each of the files and store unique values into hashtable, print out dlls that have different hashes

foreach ($file in $files) 
{
    #define variables
    $filename = split-path $file.path -leaf
    $hashes = $file.hashstring

    if ( $hashtable.containskey("$filename"))
    {

        if ( $hashtable.containsvalue("$hashes")) 
        {
        write-host "$filename is clean" -ForegroundColor Green
        $cleandlls += "`n$filename"
        }

        else {
        $dllsofinterest += "`n$filename"
        write-host " $filename contains multiple hash values " -ForegroundColor yellow
        }
        $dllsofinterest | out-file dlls_different_hashes.txt
        }

    else 
    {
    $hashtable.add($filename,$hashes)
    }
}
}
elseif ($fileversion)
{
$files2 = @(Get-ChildItem C:\ -Filter *.dll -recurse -erroraction silentlycontinue)    # @() forces a one-item answer to still be an array

$hashtable2 = @{}

$dllsofinterest2= ""
$cleandlls2 = ""

foreach ($file in $files2) 
{
    #define variables
    $filename = $file.Name
    $version = $file.VersionInfo.FileVersion

    if ( $hashtable2.containskey("$filename"))
    {

        if ( $hashtable2.containsvalue("$version")) 
        {
        write-host "$filename is clean" -ForegroundColor Green
        $cleandlls2 += "`n$filename"
        }

        else {
        $dllsofinterest2 += "`n$filename"
        write-host " $filename has a different file version " -ForegroundColor yellow
        }
        $dllsofinterest2 | out-file dlls_different_versions.txt
        }

    else 
    {
    $hashtable2.add($filename,$version)
    }
}
}


elseif ($help)
{
Write-Host "Use -hashthem to produce a list of dlls that have different hashes. `n`t`t They will be in a variable called dllsofinterest. `n`t`t This will produce a lot of false positives because of the state of the dlls, but it's a start" -ForegroundColor Green -BackgroundColor Black
Write-Host "Use -fileversion to produce a list of dlls with different file versions. `n`t`t They will be stored in a variable called dllsofinterest2." -ForegroundColor Green -BackgroundColor Black

}
else 
{
Write-Host "Use -help for switch options" -ForegroundColor Yellow -BackgroundColor Black
}


#$newdlls = get-content test.txt
#foreach ($newdll in $newdlls)
#{
#get-childitem c:\ -Filter $newdll -Recurse | select name, creationtime, length 
#}