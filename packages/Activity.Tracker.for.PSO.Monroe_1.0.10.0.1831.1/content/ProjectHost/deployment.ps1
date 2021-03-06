$ErrorActionPreference = "Stop"


function Read-Filters
{
    param($configSection)
	$itemsList = @()
	foreach ($item in $configSection)
	{
	    $itemsList += $item
	}
	return $itemsList
}

function Add-Zip
{
    param(
        [string] $zipFilename,
        [string[]] $fileList
    )

    set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
    (dir $zipfilename).IsReadOnly = $false  
    $zipfilename = resolve-path $zipfilename

    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipfilename)

    foreach($file in $fileList) 
    { 
        $zipPackage.CopyHere($file)
        Start-sleep -milliseconds 500
	echo "File: `"$file`" is added to the deployment." 
    }
}


$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$config = [xml](get-content "$scriptPath\deployment.cfg") 
$includeList = Read-Filters $config.configuration.include.item
$excludeList = Read-Filters $config.configuration.exclude.item
$itemList = Get-ChildItem .\* -Include $includeList -Exclude $excludeList
Add-Zip "deployment.zip" $itemList
echo "Deployment file successfully created."


