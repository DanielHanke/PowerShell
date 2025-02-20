$URIOficial = "https://dolarapi.com/v1/dolares/oficial"
$URIBlue = "https://dolarapi.com/v1/dolares/blue"

$dolarOficial = Invoke-RestMethod -Method get -Uri $URIOficial
$dolarBlue = Invoke-RestMethod -Method get -Uri $URIBlue
 
$promedioOficial = ( $dolarOficial.compra + $dolarOficial.venta ) / 2 
$promedioBlue = ( $dolarBlue.compra + $dolarBlue.venta ) / 2 
$diferenciaCambiaria = $promedioBlue - $promedioOficial
$brechaCambiaria = [math]::Round(($diferenciaCambiaria / $promedioOficial) * 100,2)

$line = "`r`nDia " + $dolarOficial.fechaActualizacion + "`r`n Dolar blue (pesos x dolar):    " + $promedioBlue + "`r`n Dolar oficial (pesos x dolar): " +
        $promedioOficial + "`r`n Brecha cambiaria (%): " + $brechaCambiaria

Write-Output $line 
