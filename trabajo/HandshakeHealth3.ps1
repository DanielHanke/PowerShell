<#
.SYNOPSIS
    This script create a summary for a AUS system implementation

.DESCRIPTION
    This script generate a email item, ready to send, accesing a database, querying hs history,
    making a table with useful information and generating graph to get an idea how the system works.

.AUTHOR
    Daniel E. Hanke - TREND

.COMPANYNAME
    Trend - GEIN / APRE

.CREATED
    23/07/2025

.LASTUPDATED
    23/07/2025

.VERSION
    1.0

.PARAMETER
    UdlFile: Udl that points to the AUS DB
    FechaDesde: Date to start analysis

.EXAMPLE
    Example to execute this script:
    PS> c:\Dev\Powershell\trabajo\HandshakeHealth3.ps1 -UdlFile "c:\Dev\Powershell\trabajo\Lems.udl" -FechaDesde "2025-07-17"

#>
param (
    [string]$UdlFile = "c:\Dev\Powershell\trabajo\Lems.udl",
    [string]$FechaDesde = "2025-07-21"
    )

function Add-Bar {
    param (
        [int]$index,
        [int]$value,
        [int]$graphHeight,
        [string]$color
    )
    $altura = $value * ($graphHeight - 100) / 100
    $posicion = ($graphHeight - 50) - $altura
    $x = $offsetX + ($deltaX*$index)
    return '<rect fill="' + $color + '" x="'+ $x +'"  y="' + $posicion + '" width="30" height="' + $altura + '"/>'
}

Function Add-Svg-Graph {
    param (
        [int[]]$values,
        [string[]]$labels,
        [string]$BarColor
    )

    # position of 1st bar
    $offsetX = 66

    #distance between bars
    $deltaX = 42

    #graph height 
    $graphHeight = 400

    # bar colors
    #$colors = @('indianred', 'salmon', 'dodgerblue', 'tomato', 'forestgreen', 'green', 'chocolate', 'salmon', 'darkred', 'moccasin')
    $colors = @('dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue')

    $str = '<g fill="steelblue">'

    for ($i = 0; $i -lt $values.Length; $i++) {
        $value = 10 * ( $i + 1 )
        $bar = Add-Bar -index $i -Value $values[$i] -graphHeight $graphHeight -color $BarColor
        $str = $str + $bar
    }

    $str = $str + '</g>'
    $svg = '<svg width="1200px" height="' + $graphHeight + 'px" xmlns="http://www.w3.org/2000/svg">'
    $svg = $svg + '<line x1="50" y1="50" x2="50" y2="350" stroke="black"/><line x1="50" y1="350" x2="550" y2="350" stroke="black"/>'
      
    $svg = $svg + '<text x="20" y="355" font-size="12" text-anchor="end">0</text>'
    $svg = $svg + '<text x="20" y="295" font-size="12" text-anchor="end">20</text>'
    $svg = $svg + '<text x="20" y="235" font-size="12" text-anchor="end">40</text>'
    $svg = $svg + '<text x="20" y="175" font-size="12" text-anchor="end">60</text>'
    $svg = $svg + '<text x="20" y="115" font-size="12" text-anchor="end">80</text>'
    $svg = $svg + '<text x="20" y="55" font-size="12" text-anchor="end">100</text>'

    $svg = $svg + $str

    $svg = $svg + '<g font-size="12" text-anchor="middle">'
    for ($i = 0; $i -lt $values.Length; $i++) {
        #if ($values[$i] -gt 0){
        $svg = $svg + '<text x="' + ($offsetX + (30 / 2) + ($i*$deltaX)).ToString() + '"  y="370">' + $i.ToString() + '</text>'
        #}
    }

    for ($i = 0; $i -lt $values.Length; $i++) {
        #if ($values[$i] -gt 0){
            #$svg = $svg + '<text text-anchor="start" fill="' + $colors[$i] + '" x="500" y="' + (50 + 15 * ($i+1)).ToString() + '">' + $i.ToString() + ' = ' + $labels[$i].ToString() + '</text>'
            $svg = $svg + '<text text-anchor="start" fill="black" x="800" y="' + (50 + 15 * ($i+1)).ToString() + '">' + $i.ToString() + ' = ' + $labels[$i].ToString() + '</text>'
        #}
    }

    $svg = $svg + '</g>'
    $svg = $svg + '</svg>'
    return $svg
} 

function HandshakeTable{
    param (
        [string[]]$Handshakes,
        [int[]]$Triggers,
        [int[]]$okCounts,
        [string[]]$Dates,
        [string[]]$LastErrors,
        [double[]]$OkPercent,
        [double[]]$ErrorPercent
     )   

    $result = ''
    $result = $result + '<table cellpadding="10" cellspacing="0" border="1" style="border-collapse: collapse; width: 100%; font-family: Arial, sans-serif; font-size: 12px">'
  
    $result = $result + '<thead>'
    $result = $result + '<tr style="background-color: #4CAF50; color: white;">'
    $result = $result + '<th rowspan="2">HANDSHAKE</th>'
    $result = $result + '<th colspan="3">DISPAROS</th>'
    $result = $result + '<th colspan="2">DURACION<sup>*</sup> (seg)</th>'
    $result = $result + '<th colspan="2">ULTIMO ERROR</th>'
    $result = $result + '</tr>'
    $result = $result + '<tr style="background-color: #4CAF50; color: white;">'
    #$result = $result + '<th>HANDSHAKE</th>'
    $result = $result + '<th>TOTAL</th>'
    $result = $result + '<th>OK</th>'
    $result = $result + '<th>ERROR</th>'
    $result = $result + '<th>MINIMO</th>'
    $result = $result + '<th>MAXIMO</th>'
    $result = $result + '<th>FECHA</th>'
    $result = $result + '<th>TIPO</th>'

    $result = $result + '</tr>'
    $result = $result + '</thead>'
  
    $result = $result + '<tbody>'

    for ($i = 0; $i -lt $Handshakes.Length; $i++) {
    
        $result = $result + '<tr style="background-color: #f2f2f2;">'
    
        $result = $result + '<td style="text-align: center;background-color: #ccccff">' + $Handshakes[$i] +'</td>'
        
        # TOTAL
        $x = $Triggers[$i].ToString()
        if ($Triggers[$i] -gt 1024){
          $x = ([Math]::Round($Triggers[$i] / 1024,2)).ToString() + ' K'
        }
        if ($Triggers[$i] -gt 1048576){
          $x = ([Math]::Round($Triggers[$i] / 1048576,2)).ToString() + ' M'
        }
        $result = $result + '<td style="text-align: center;">' + $x +'</td>'

        # OK
        $x = $okCount[$i].ToString()
        if ($okCount[$i] -gt 1024){
          $x = ([Math]::Round($okCount[$i] / 1024,2)).ToString() + ' K'
        }
        if ($okCount[$i] -gt 1048576){
          $x = ([Math]::Round($okCount[$i] / 1048576,2)).ToString() + ' M'
        }
        $result = $result + '<td style="text-align: center;">' + $x.ToString() + ' (' + $okPercent[$i] + '%) ' + '</td>'
        
        
        #ERR
        $x = ($Triggers[$i] - $okCount[$i]).ToString()
        if (($Triggers[$i] - $okCount[$i]) -gt 1024){
          $x = ([Math]::Round(($Triggers[$i] - $okCount[$i]) / 1024,2)).ToString() + ' K'
        }
        if (($Triggers[$i] - $okCount[$i]) -gt 1048576){
          $x = ([Math]::Round(($Triggers[$i] - $okCount[$i]) / 1048576,2)).ToString() + ' M'
        }
        $cellColor = "green"
        if ($ErrorPercent[$i] -gt 20 ){
            $cellColor = "yellow"
        }
        if ($ErrorPercent[$i] -gt 50 ){
            $cellColor = "red"
        }
        $result = $result + '<td style="text-align: center; color: ' + $cellColor +'">' + $x + ' (' + $ErrorPercent[$i] + '%) ' + '</td>'
        
        $result = $result + '<td style="text-align: center;">' + $MinOkDuration[$i].ToString()
        $result = $result + '<td style="text-align: center;">' + $MaxOkDuration[$i].ToString()

        $result = $result + '<td style="text-align: center;background-color: #d6eaf8">' + $Dates[$i].ToString()
        $result = $result + '<td style="text-align: center;background-color: #d6eaf8">' + $LastErrors[$i].ToString()
        $result = $result + '</tr>'

    }



    $result = $result + '</tbody>'
    $result = $result + '</table>'
    $result = $result + '<p><sup>*</sup><small>La duración es solo de disparos que dieron OK</small></p>'


    return $result
}

# read ConnectionString from UDL File
$udlContent = Get-Content $udlFile
$connectionString = $udlContent | Where-Object { $_ -like "Provider=*" }
$connection = New-Object System.Data.OleDb.OleDbConnection($connectionString) #New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

#$Data = [PSCustomObject]@{
#    HandshakeName = "Daniel"
#}
$DataList = New-Object System.Collections.ArrayList
#$DataList.Add($Data)

#Write-Output $data.HandshakeName
#Write-Output $DataList[0].HandshakeName

$handshakes = New-Object System.Collections.ArrayList
$handshakesIds= New-Object System.Collections.ArrayList
$triggers = New-Object System.Collections.ArrayList
$okPercent = New-Object System.Collections.ArrayList
$ErrorPercent = New-Object System.Collections.ArrayList
$OkCount = New-Object System.Collections.ArrayList
$Dates = New-Object System.Collections.ArrayList
$LastErrors = New-Object System.Collections.ArrayList


$MaxOkDuration = New-Object System.Collections.ArrayList
$MinOkDuration = New-Object System.Collections.ArrayList


$str = 'Obteniendo handshakes...'
Write-Host $str

$query = 'SELECT * FROM [Handshake].[Handshake] WHERE [Active] = 1'

$command = $connection.CreateCommand()
$command.CommandText = $query
$reader = $command.ExecuteReader()
while ($reader.Read()) 
{

    $Data = [PSCustomObject]@{
        HandshakeName = $reader["Code"].ToString()
        HandshakeId = $reader["idHandshake"]
        TotalTriggered = 0
        TotalTriggeredOk = 0
        PercentTriggeredOk = 0.0
        PercentTriggeredError = 0.0
        LastDateTriggered = ""
        LasterrorCode = ""
        MinTriggerDuration = 0.0
        MaxTriggerDuration = 0.0
    }
    $DataList.Add($Data)



    $x = $handshakes.Add($reader["Code"].ToString())
    $x = $handshakesIds.Add($reader["idHandshake"])
    $x = $triggers.Add(0)
    $x = $OkCount.Add(0)
    $x = $okPercent.Add(0)
    $x = $ErrorPercent.Add(0)
    $x = $Dates.Add('')
    $x = $LastErrors.Add('')
    $x = $MaxOkDuration.Add(0)
    $x = $MinOkDuration.Add(0)
}
$reader.Close()
for ($i = 0; $i -lt $DataList.Count; $i++) {
    $DataList[$i].TotalTriggered = 100    
    Write-Output $DataList[$i]
}


$str = 'Obteniendo ultimos errores...'
Write-Host $str

# Ultimo error de cada HS
for ($i = 0; $i -lt $handshakes.Count; $i++) {
    #Write-Output  $handshakesids[$i]
    $query = 'select TOP 1 * from [Handshake].[HandshakeHistory] WHERE idHandshake = '+ $handshakesIds[$i].ToString() + ' and CallbackDateTime > ''' + $FechaDesde + '''' + ' and Result < 0  order by InsDateTime desc'
    #Write-Output $query
    # Ejecutar la consulta
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()
    while ($reader.Read()) 
    {
        $Dates[$i] = $reader["CallbackDateTime"].ToString()
        $LastErrors[$i] = $reader["Result"].ToString()
    }
    $reader.Close()
}

$str = 'Obteniendo cantidades de triggers...'
Write-Host $str
# Cantidad de disparos
for ($i = 0; $i -lt $handshakes.Count; $i++) {
    #Write-Output  $handshakesids[$i]
    $query = 'select count(*) as qty from [Handshake].[HandshakeHistory] WHERE idHandshake = ' + $handshakesIds[$i].ToString() + ' and CallbackDateTime > ''' + $FechaDesde + '''' 
    # Ejecutar la consulta
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()
    while ($reader.Read()) 
    {
        $triggers[$i] = $reader["qty"]
    }
    $reader.Close()
}


# Cantidad de disparos OK
for ($i = 0; $i -lt $handshakes.Count; $i++) {
    #Write-Output  $handshakesids[$i]
    $query = 'select count(*) as qty from [Handshake].[HandshakeHistory] WHERE Result = 1 and idHandshake = ' + $handshakesIds[$i].ToString() + ' and CallbackDateTime > ''' + $FechaDesde + '''' 
    
    # Ejecutar la consulta
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()
    while ($reader.Read()) 
    {
        $OkCount[$i] = $reader["qty"]
    }
    $reader.Close()
}

# Maxima duracion de los triggers
#  [Handshake].[HandshakeHistory] WHERE Result = 1 and idHandshake = 1 
for ($i = 0; $i -lt $handshakes.Count; $i++) {
    #Write-Output  $handshakesids[$i]
    $query = 'select MAX(CAST(DATEDIFF_BIG(MICROSECOND, CallBackDateTime, ResponseDateTime) AS FLOAT) / 1000000) AS Duration  from [Handshake].[HandshakeHistory] WHERE Result = 1 and idHandshake = ' + $handshakesIds[$i].ToString() + ' and CallbackDateTime > ''' + $FechaDesde + '''' 
    
    # Ejecutar la consulta
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()
    while ($reader.Read()) 
    {
        $MaxOkDuration[$i] = $reader["duration"]
    }
    $reader.Close()
}

# Minima duracion de los triggers
#  [Handshake].[HandshakeHistory] WHERE Result = 1 and idHandshake = 1 
for ($i = 0; $i -lt $handshakes.Count; $i++) {
    #Write-Output  $handshakesids[$i]
    $query = 'select MIN(CAST(DATEDIFF_BIG(MICROSECOND, CallBackDateTime, ResponseDateTime) AS FLOAT) / 1000000) AS Duration  from [Handshake].[HandshakeHistory] WHERE Result = 1 and idHandshake = ' + $handshakesIds[$i].ToString() + ' and CallbackDateTime > ''' + $FechaDesde + '''' 
    
    # Ejecutar la consulta
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()
    while ($reader.Read()) 
    {
        $MinOkDuration[$i] = $reader["duration"]
    }
    $reader.Close()
}


# calcular los porcentajes
for ($i = 0; $i -lt $handshakes.Count; $i++) {
    if ($Triggers[$i] -eq 0){
        $okPercent[$i] = 0
    }
    else{
        $okPercent[$i] = [Math]::Round(100 * $okCount[$i] / $Triggers[$i],2)
    }
    
    if ($Triggers[$i] -eq 0){
        $errorPercent[$i] = 0
    }
    else{
        $errorPercent[$i] = [Math]::Round(100 * (($Triggers[$i] - $okCount[$i])) / $Triggers[$i],2)
    }
    
}


$str = 'Armando el correo...'
Write-Host $str

#
# Agregar el graph HS Errores
#
$svg = Add-Svg-Graph -values $ErrorPercent -labels $handshakes -BarColor "firebrick"

# Guardar SVG temporalmente, invocar a InkScape y convertirlo a base64
$tempSvgPath = "$env:TEMP\temp_image.svg"
$tempPngPath = "$env:TEMP\temp_image.png"
[System.IO.File]::WriteAllText($tempSvgPath, $svg)
& "C:\Program Files\Inkscape\bin\inkscape" $tempSvgPath --export-type=png --export-filename=$tempPngPath
$bytes = [System.IO.File]::ReadAllBytes($tempPngPath)
$GraficoHSErrores = [Convert]::ToBase64String($bytes)


#
# Agregar el graph HS OK
#
$svg = Add-Svg-Graph -values $OkPercent -labels $handshakes -BarColor "forestgreen"

# Guardar SVG temporalmente, invocar a InkScape y convertirlo a base64
$tempSvgPath = "$env:TEMP\temp_image.svg"
$tempPngPath = "$env:TEMP\temp_image.png"
[System.IO.File]::WriteAllText($tempSvgPath, $svg)
& "C:\Program Files\Inkscape\bin\inkscape" $tempSvgPath --export-type=png --export-filename=$tempPngPath
$bytes = [System.IO.File]::ReadAllBytes($tempPngPath)
$GraficoHSOk = [Convert]::ToBase64String($bytes)




$mail = $outlook.CreateItem(0)  # 0 representa un MailItem
$mail.To = 'dehanke@suppliers.tenaris.com'
#$mail.CC = "jtorresgauto@suppliers.tenaris.com"
$fecha = Get-Date -Format "dd/MM/yyyy"
$mail.Subject = "Reporte Handshakes: " + $connection.Database + "@" + $connection.DataSource    +  " a la fecha " + $fecha

$HandshakeTable = HandshakeTable -Handshakes $handshakes -Triggers $triggers -okCounts $okCounts -Dates $Dates -LastErrors $LastErrors -OkPercent $okPercent -ErrorPercent $ErrorPercent

$HandshakeTable = '<h2>HANDSHAKES A PARTIR DE ' + $FechaDesde + '</h2><br>' + $HandshakeTable



$mail.HTMLBody = "<html>$head<body>$HandshakeTable<br><h3>Pocentaje de errores en HS</h3><img src='data:image/png;base64,$GraficoHSErrores'/><br><h3>Pocentaje de HS OK</h3><img src='data:image/png;base64,$GraficoHSOk'/></body><html>"
$mail.Display()
$str = 'Listo!'
Write-Host $str
