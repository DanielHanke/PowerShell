 <#
.SYNOPSIS
    Get a list of Teams members specified by criteria
.DESCRIPTION
    Get a list of memebers and, optionally, get his/her photos, if any
.PARAMETER search
    Search for text, may be LastName, or anything
.PARAMETER download
    1 if you want to download, default=0, not to download
.EXAMPLE
    C:\PS>TeamsUserSearch.ps1 -search "Jhon" -download 0 
    
.NOTES
    Author: Daniel Hanke
    Date:   March 31, 2025    
#>
 param (
    [string]$search = "melina",
    [int] $download = 1
 )

Connect-MgGraph -Scopes "User.Read.All" -NoWelcome



$criteria = $search
$search = '"DisplayName:' + $criteria +'"'
#$search = '"Surname:' + $criteria +'"'


$users = Get-MgUser -ConsistencyLevel eventual -Count userCount -Search $search -OrderBy UserPrincipalName | Format-List  ID, DisplayName, Mail, UserPrincipalName
#Write-Output $users

for( $i = 0; $i -lt $users.Count; $i = $i + 1)
{

        Write-Output $users[$i]
    

    if ($download -eq 1)
    {
        $OutputFile = "C:\Dev\PowerShell\trabajo\"+ $users[$i].Mail +".jpg"
        try 
        { 
            Get-MgUserPhotoContent -UserId $users[$i].Id -OutFile $OutputFile
        }
        catch
        {
            Write-Output "No image loaded, cannot download"
        }
    }
}
