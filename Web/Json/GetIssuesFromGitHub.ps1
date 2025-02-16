
$thePage =  "https://api.github.com/repos/PowerShell/PowerShell/issues"
$RESPONSE=Invoke-WebRequest -Uri $thePage -Method GET
if ($RESPONSE.StatusCode -eq 200){
    # Write-Output $response.Content
    $sLine =  "ID".PadLeft(10," ") + " USER".PadRight(20," ") + " STATE".PadLeft(20," ")
    Write-Output $sLine
    $sLine =  "TITLE".PadLeft(80," ")
    Write-Output $sLine
    $jsonObj = ConvertFrom-Json $([String]::new($response.Content))
    for ($i = 0; $i -lt $jsonObj.Count; $i++) {
        $sLine =    $jsonObj[$i].number.ToString().PadLeft(10,' ') + " " 
                    $jsonObj[$i].user.login.PadRight(20,' ') + " "
                    $jsonObj[$i].state.ToString().PadLeft(20,' ') + " "
        Write-Output $sLine        
        $sLine =  $jsonObj[$i].title.PadLeft(80,' ')
        Write-Output $sLine        
        Write-Output "---------------------------------------------------------------"
    }
}
