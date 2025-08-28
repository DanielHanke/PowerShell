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
    FromDate: Date to start analysis

.EXAMPLE
    Example to execute this script:
    PS> c:\Dev\Powershell\trabajo\HandshakeHealth3.ps1 -UdlFile "c:\Dev\Powershell\trabajo\Lems.udl" -FromDate "2025-07-17"

#>
param (
    [string]$UdlFile = "c:\Dev\Powershell\trabajo\Lems.udl",
    [string]$FromDate = "2025-07-21"
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


    $str = '<g fill="steelblue">'
    # add chart bars
    for ($i = 0; $i -lt $values.Length; $i++) {
        $bar = Add-Bar -index $i -Value $values[$i] -graphHeight $graphHeight -color "firebrick"
        $str = $str + $bar
    }
    $str = $str + '</g>'

    $svg = '<svg width="1200px" height="' + $graphHeight + 'px" xmlns="http://www.w3.org/2000/svg">'
    
    # Graph cartesian lines
    $svg = $svg + '<line x1="50" y1="50" x2="50" y2="350" stroke="black"/><line x1="50" y1="350" x2="550" y2="350" stroke="black"/>'
      
    # Y Labels...
    $svg = $svg + '<text x="20" y="355" font-size="12" text-anchor="end">0</text>'
    $svg = $svg + '<text x="20" y="295" font-size="12" text-anchor="end">20</text>'
    $svg = $svg + '<text x="20" y="235" font-size="12" text-anchor="end">40</text>'
    $svg = $svg + '<text x="20" y="175" font-size="12" text-anchor="end">60</text>'
    $svg = $svg + '<text x="20" y="115" font-size="12" text-anchor="end">80</text>'
    $svg = $svg + '<text x="20" y="55" font-size="12" text-anchor="end">100</text>'

    $svg = $svg + $str

    # X labels
    $svg = $svg + '<g font-size="12" text-anchor="middle">'
    for ($i = 0; $i -lt $values.Length; $i++) {
        #if ($values[$i] -gt 0){
        $svg = $svg + '<text x="' + ($offsetX + (30 / 2) + ($i*$deltaX)).ToString() + '"  y="370">' + $i.ToString() + '</text>'
        #}
    }
    $svg = $svg + '</g>'


    # series labels
    for ($i = 0; $i -lt $values.Length; $i++) {
            #$svg = $svg + '<text text-anchor="start" fill="' + $colors[$i] + '" x="500" y="' + (50 + 15 * ($i+1)).ToString() + '">' + $i.ToString() + ' = ' + $labels[$i].ToString() + '</text>'
            $svg = $svg + '<text text-anchor="start" fill="black" x="800" y="' + (50 + 15 * ($i+1)).ToString() + '">' + $i.ToString() + ' = ' + $labels[$i].ToString() + ' ('+$values[$i].ToString() + '%)</text>'
    }

    $svg = $svg + '</svg>'
    return $svg
} 

function HandshakeTable{
    param (
        [System.Collections.ArrayList]$data
     )
    #param (
    #    [string[]]$Handshakes,
    #    [int[]]$Triggers,
    #    [int[]]$okCounts,
    #    [string[]]$Dates,
    #    [string[]]$LastErrors,
    #    [double[]]$OkPercent,
    #    [double[]]$ErrorPercent
    # )   

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
    $result = $result + '<th>TOTAL</th>'
    $result = $result + '<th>OK</th>'
    $result = $result + '<th>ERROR</th>'
    #$result = $result + '<th></th>'
    $result = $result + '<th>MINIMO</th>'
    $result = $result + '<th>MAXIMO</th>'
    $result = $result + '<th>FECHA</th>'
    $result = $result + '<th>TIPO</th>'

    $result = $result + '</tr>'
    $result = $result + '</thead>'
  
    $result = $result + '<tbody>'

    for ($i = 0; $i -lt $data.Count; $i++) {
    
        $result = $result + '<tr style="background-color: #f2f2f2;">'
    
        $result = $result + '<td style="text-align: center;background-color: #ccccff">' + $data[$i].HandshakeName +'</td>'
        
        # TOTAL
        $x = $data[$i].TotalTriggered.ToString()
        if ($data[$i].TotalTriggered -gt 1024){
          $x = ([Math]::Round($data[$i].TotalTriggered / 1024,2)).ToString() + ' K'
        }
        if ($data[$i].TotalTriggered -gt 1048576){
          $x = ([Math]::Round($data[$i].TotalTriggered / 1048576,2)).ToString() + ' M'
        }
        $result = $result + '<td style="text-align: center;">' + $x +'</td>'

        # OK
        $x = $data[$i].TotalTriggeredOk.ToString()
        if ($data[$i].TotalTriggeredOk -gt 1024){
          $x = ([Math]::Round($data[$i].TotalTriggeredOk / 1024,2)).ToString() + ' K'
        }
        if ($data[$i].TotalTriggeredOk -gt 1048576){
          $x = ([Math]::Round($data[$i].TotalTriggeredOk / 1048576,2)).ToString() + ' M'
        }
        $result = $result + '<td style="text-align: center;">' + $x.ToString() + ' (' + $data[$i].PercentTriggeredok + '%) ' + '</td>'
  

        
        
        #ERR
        $x = $data[$i].TotalTriggeredError.ToString()
        if ($data[$i].TotalTriggeredError -gt 1024){
          $x = ([Math]::Round($data[$i].TotalTriggeredError / 1024,2)).ToString() + ' K'
        }
        if ($data[$i].TotalTriggeredOk -gt 1048576){
          $x = ([Math]::Round($data[$i].TotalTriggeredError / 1048576,2)).ToString() + ' M'
        }
        $cellColor = "green"
        if ($data[$i].PercentTriggeredError -gt 20 ){
            $cellColor = "yellow"
        }
        if ($data[$i].PercentTriggeredError -gt 50 ){
            $cellColor = "red"
        }
        $result = $result + '<td style="text-align: center; color: ' + $cellColor +'">' + $x + ' (' + $data[$i].PercentTriggeredError + '%) ' + '</td>'
        
        
        #$result = $result + '<td>'
        #$result = $result + '<div style="position: relative; width: 100%;">'
        #$result = $result + '<svg style="width: 100%" viewBox="0 0 100 30">'
        #$result = $result + '<text x="50" y="0" font-size="12" text-anchor="end">000</text>'
        #$result = $result + '<rect x="0" y="0" width="100" height="30" fill="#00FF00" stroke="black"/>'
        #$result = $result + '</svg>'
        #$result = $result + '</div>'
        #$result = $result + '</td>'
        

        $result = $result + '<td style="text-align: center;">' + $data[$i].MinTriggerDuration.ToString()  + '</td>'
        $result = $result + '<td style="text-align: center;">' + $data[$i].MaxTriggerDuration.ToString() + '</td>'

        $result = $result + '<td style="text-align: center;background-color: #d6eaf8">' + $data[$i].LastDateTriggered.ToString() + '</td>'
        $result = $result + '<td style="text-align: center;background-color: #d6eaf8">' + $data[$i].LasterrorCode.ToString() + '</td>'
        $result = $result + '</tr>'

    }



    $result = $result + '</tbody>'
    $result = $result + '</table>'
    $result = $result + '<p><sup>*</sup><small>La duración es solo de disparos que dieron OK</small></p>'


    return $result
}


Function LogData{
    param (
        [System.Collections.ArrayList]$data
     )

    for ($i = 0; $i -lt $data.Count; $i++) {
        Write-Output $data[$i]
    }

}

Function ReadMaxTriggerDuration{
    param (
        [System.Data.OleDb.OleDbConnection] $conn,
        [System.Collections.ArrayList]$data,
        [string]$FromDate
     )
    for ($i = 0; $i -lt $data.Count; $i++) {

        $query = 'select MAX(CAST(DATEDIFF_BIG(MICROSECOND, CallBackDateTime, ResponseDateTime) AS FLOAT) / 1000000) AS Duration  from [Handshake].[HandshakeHistory] WHERE Result = 1 and idHandshake = ' + $data.HandshakeId[$i].ToString() + ' and CallbackDateTime > ''' + $FromDate + '''' 
        $command = $conn.CreateCommand()
        $command.CommandText = $query
        $reader = $command.ExecuteReader()
        if ( $reader.HasRows -eq $true){

            while ($reader.Read()) 
            {
                $data[$i].MaxTriggerDuration = $reader["duration"]
            }
        }
        else{
            $data[$i].LastDateTriggered = ""
            $data[$i].LastErrorCode = ""
        }
        $reader.Close()      
    }
}

Function ReadMinTriggerDuration{
    param (
        [System.Data.OleDb.OleDbConnection] $conn,
        [System.Collections.ArrayList]$data,
        [string]$FromDate
     )
    for ($i = 0; $i -lt $data.Count; $i++) {

        $query = 'select MIN(CAST(DATEDIFF_BIG(MICROSECOND, CallBackDateTime, ResponseDateTime) AS FLOAT) / 1000000) AS Duration  from [Handshake].[HandshakeHistory] WHERE Result = 1 and idHandshake = ' + $data.HandshakeId[$i].ToString() + ' and CallbackDateTime > ''' + $FromDate + '''' 
        $command = $conn.CreateCommand()
        $command.CommandText = $query
        $reader = $command.ExecuteReader()
        if ( $reader.HasRows -eq $true){

            while ($reader.Read()) 
            {
                $data[$i].MinTriggerDuration = $reader["duration"]
            }
        }
        else{
            $data[$i].LastDateTriggered = ""
            $data[$i].LastErrorCode = ""
        }
        $reader.Close()      
    }
}



Function ReadOKTriggerQuantity{
    param (
        [System.Data.OleDb.OleDbConnection] $conn,
        [System.Collections.ArrayList]$data,
        [string]$FromDate
     )
    for ($i = 0; $i -lt $data.Count; $i++) {

        $query = 'select count(*) as qty from [Handshake].[HandshakeHistory] WHERE Result = 1 and idHandshake = ' + $data.HandshakeId[$i].ToString() + ' and CallbackDateTime > ''' + $FromDate + '''' 
        $command = $conn.CreateCommand()
        $command.CommandText = $query
        $reader = $command.ExecuteReader()
        if ( $reader.HasRows -eq $true){

            while ($reader.Read()) 
            {
                $data[$i].TotalTriggeredOk = $reader["qty"]
                $data[$i].TotalTriggeredError = $data[$i].TotalTriggered - $data[$i].TotalTriggeredOk
            }
        }
        else{
            $data[$i].LastDateTriggered = ""
            $data[$i].LastErrorCode = ""
        }
        $reader.Close()      
    }
}


Function ReadTriggerQuantity{
    param (
        [System.Data.OleDb.OleDbConnection] $conn,
        [System.Collections.ArrayList]$data,
        [string]$FromDate
     )
    for ($i = 0; $i -lt $data.Count; $i++) {

        $query = 'select count(*) as qty from [Handshake].[HandshakeHistory] WHERE idHandshake = ' + $data[$i].HandshakeId.ToString() + ' and CallbackDateTime > ''' + $FromDate + '''' 
        $command = $conn.CreateCommand()
        $command.CommandText = $query
        $reader = $command.ExecuteReader()
        if ( $reader.HasRows -eq $true){

            while ($reader.Read()) 
            {
                $data[$i].TotalTriggered = $reader["qty"]
                
            }
        }
        else{
            $data[$i].LastDateTriggered = ""
            $data[$i].LastErrorCode = ""
        }

        $reader.Close()      
    }
}

Function ReadLastErrors{
    param (
        [System.Data.OleDb.OleDbConnection] $conn,
        [System.Collections.ArrayList]$data,
        [string]$FromDate
     )
    for ($i = 0; $i -lt $data.Count; $i++) {
        $query = 'select TOP 1 * from [Handshake].[HandshakeHistory] WHERE idHandshake = '+ $data[$i].HandshakeId.ToString() + ' and CallbackDateTime > ''' + $FromDate + '''' + ' and Result < 0  order by InsDateTime desc'
        $command = $conn.CreateCommand()
        $command.CommandText = $query
        $reader = $command.ExecuteReader()
        if ( $reader.HasRows -eq $true){
            while ($reader.Read()) 
            {
                $data[$i].LastDateTriggered = $reader["CallbackDateTime"].ToString()
                $data[$i].LastErrorCode = $reader["Result"].ToString()
            }
        }
        else{
            $data[$i].LastDateTriggered = ""
            $data[$i].LastErrorCode = ""
        }
        $reader.Close()      
    }
}



Function ReadHandshakes{
    param (
        [System.Data.OleDb.OleDbConnection] $conn,
        [System.Collections.ArrayList]$data
     )
    $query = 'SELECT * FROM [Handshake].[Handshake] WHERE [Active] = 1'
    $command = $conn.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()
    while ($reader.Read()) 
    {

        $obj = [PSCustomObject]@{
            HandshakeName = $reader["Code"].ToString()
            HandshakeId = $reader["idHandshake"]
            TotalTriggered = 0
            TotalTriggeredOk = 0
            TotalTriggeredError = 0
            PercentTriggeredOk = 0.0
            PercentTriggeredError = 0.0
            LastDateTriggered = ""
            LastErrorCode = ""
            MinTriggerDuration = 0.0
            MaxTriggerDuration = 0.0
        }
        $x = $data.Add($obj)
    }
    $reader.Close()      
}

Function CalcArrayValues{
    param (
        [System.Collections.ArrayList]$data
     )

    for ($i = 0; $i -lt $data.Count; $i++) {
        if ($data.TotalTriggered[$i] -eq 0){
            $data[$i].PercentTriggeredOk = 0
            $data[$i].PercentTriggeredError = 0
        }
        else{
            $data[$i].PercentTriggeredOk =  [Math]::Round(100 * $data[$i].TotalTriggeredOk / $data[$i].TotalTriggered,2)
            $data[$i].PercentTriggeredError = [Math]::Round(100 * $data[$i].TotalTriggeredError / $data[$i].TotalTriggered,2)
        }
    }
}

# read ConnectionString from UDL File
$udlContent = Get-Content $udlFile
$connectionString = $udlContent | Where-Object { $_ -like "Provider=*" }
$connection = New-Object System.Data.OleDb.OleDbConnection($connectionString) #New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()


$DataList = New-Object System.Collections.ArrayList



Write-Host 'DB Get all active handshakes...'
ReadHandshakes -conn $connection -data $DataList

Write-Host 'DB Get all last handshakes errors...'
ReadLastErrors -conn $connection -data $DataList -FromDate $FromDate

Write-Host 'DB Get all handshake trigger count...'
ReadTriggerQuantity -conn $connection -data $DataList -FromDate $FromDate

Write-Host 'DB Get all OK handshake trigger count...'
ReadOkTriggerQuantity -conn $connection -data $DataList -FromDate $FromDate

ReadMinTriggerDuration -conn $connection -data $DataList -FromDate $FromDate
ReadMaxTriggerDuration -conn $connection -data $DataList -FromDate $FromDate

#LogData -data $DataList

CalcArrayValues -data $DataList 

$str = 'Armando el correo...'
Write-Host $str

#
# Agregar el graph HS Errores
#

$Values = @()
for ($i = 0; $i -lt $DataList.Count; $i++) {
    $Values += ([Math]::Truncate($DataList[$i].PercentTriggeredError))
}
$labels = @()
for ($i = 0; $i -lt $DataList.Count; $i++) {
    $labels += $DataList[$i].HandshakeName
}

Write-Output $Values
$svg = Add-Svg-Graph -values $values -labels $labels -BarColor "firebrick"

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
#$Values = @()
#for ($i = 0; $i -lt $data.Count; $i++) {
#    $Values.Add([Math]::Trunc($Data[$i].PercentTriggeredOk))
#}
#Write-Output $Values
#$svg = Add-Svg-Graph -values $Values -labels $handshakes -BarColor "forestgreen"

# Guardar SVG temporalmente, invocar a InkScape y convertirlo a base64
#$tempSvgPath = "$env:TEMP\temp_image.svg"
#$tempPngPath = "$env:TEMP\temp_image.png"
#[System.IO.File]::WriteAllText($tempSvgPath, $svg)
#& "C:\Program Files\Inkscape\bin\inkscape" $tempSvgPath --export-type=png --export-filename=$tempPngPath
#$bytes = [System.IO.File]::ReadAllBytes($tempPngPath)
#$GraficoHSOk = [Convert]::ToBase64String($bytes)



# Crear una instancia de Outlook
$outlook = New-Object -ComObject Outlook.Application
$mail = $outlook.CreateItem(0)  # 0 representa un MailItem
$mail.To = 'dehanke@suppliers.tenaris.com'
#$mail.CC = "jtorresgauto@suppliers.tenaris.com"
$fecha = Get-Date -Format "dd/MM/yyyy"
$mail.Subject = "Reporte Handshakes: " + $connection.Database + "@" + $connection.DataSource    +  " a la fecha " + $fecha

#$HandshakeTable = HandshakeTable -Handshakes $handshakes -Triggers $triggers -okCounts $okCounts -Dates $Dates -LastErrors $LastErrors -OkPercent $okPercent -ErrorPercent $ErrorPercent
$HandshakeTable = HandshakeTable -data $DataList

$HandshakeTable = '<h2>HANDSHAKES A PARTIR DE ' + $FromDate + '</h2><br>' + $HandshakeTable



$mail.HTMLBody = "<html>$head<body>$HandshakeTable<br><h3>Pocentaje de errores en HS</h3><img src='data:image/png;base64,$GraficoHSErrores'/></body><html>"
$mail.Display()
$str = 'Listo!'
Write-Host $str
