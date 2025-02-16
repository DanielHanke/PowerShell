
    $thePage =  "https://en.wikipedia.org/w/api.php?action=parse&page=PowerShell&prop=text&formatversion=2&format=json"
    $RESPONSE=Invoke-WebRequest -Uri $thePage -Method GET
    if ($RESPONSE.StatusCode -eq 200){
        $jsonObj = ConvertFrom-Json $([String]::new($response.Content))
        Write-Output "Definicion: " $jsonObj.parse.title
        Write-Output "ID Pagina: " $jsonObj.parse.pageid
    }
    