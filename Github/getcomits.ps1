$ThePage = 1
Write-Output "" | Out-File -FilePath D:\temp\prueba.html 

while ($ThePage -lt 3)
{

    $url = "/repos/TrendCPRepo/Lems/commits?per_page=100&page=" + $ThePage.ToString()
    Write-Host $url
    $answer = ( & gh api $url | ConvertFrom-Json )

    for ($i = 0; $i -lt $answer.Count; $i++) 
    {
        $line = "<p>" + 
        $answer[$i].commit.author.date.Substring(0,10) + ";" + $answer[$i].commit.author.name + ";" + $answer[$i].commit.message +
        "</p>" 
        Write-Output $line | Out-File -FilePath D:\temp\prueba.html -Append
    }
    $ThePage = $ThePage + 1
}

#$thePage =  "https://api.github.com/repos/TrendCPRepo/Lems/commits"
#$RESPONSE=Invoke-WebRequest -Uri $thePage -Method GET
#if ($RESPONSE.StatusCode -eq 200){
#    Write-Output $response.Content
    #$sLine =  "ID".PadLeft(10," ") + " USER".PadRight(20," ") + " STATE".PadLeft(20," ")
    #Write-Output $sLine
    #$sLine =  "TITLE".PadLeft(80," ")
    #Write-Output $sLine
    #$jsonObj = ConvertFrom-Json $([String]::new($response.Content))
    #for ($i = 0; $i -lt $jsonObj.Count; $i++) {
    #    $sLine =    $jsonObj[$i].number.ToString().PadLeft(10,' ') + " " 
    #                $jsonObj[$i].user.login.PadRight(20,' ') + " "
    #                $jsonObj[$i].state.ToString().PadLeft(20,' ') + " "
    #    Write-Output $sLine        
    #    $sLine =  $jsonObj[$i].title.PadLeft(80,' ')
    #    Write-Output $sLine        
    #    Write-Output "---------------------------------------------------------------"
    #}
#}