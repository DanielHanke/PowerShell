function DisplayScreen{
    param (
        [string[]]$Handshakes,
        [int[]]$Triggers,
        [int[]]$okCounts,
        [string[]]$Dates,
        [string[]]$LastErrors
     )    

    Clear

    Write-Host '┌──────────────────────────────────────────────────────────────────────────────┐'
    #Write-Output '│ HANDSHAKES                                                                   │'
    #Write-Output '├──────────────────────────────────────────────────────────────────────────────┤'
    # for every HS
    for ($i = 0; $i -lt $Handshakes.Length; $i++) {
    
        $str = '│ ' + $Handshakes[$i].PadRight(40,' ') + '│'
        Write-Host $str -NoNewline
        $str = 'TOTAL ' + $Triggers[$i].ToString().PadRight(6,' ') + '│'
        Write-Host $str -NoNewline
        $str = 'OK ' + $okCount[$i].ToString().PadRight(6,' ') + '│'
        Write-Host $str -NoNewline
        $str = 'ERROR ' + ($Triggers[$i] - $okCount[$i]).ToString().PadRight(6,' ') + ' │'
        Write-Host $str -NoNewline



        #$str = '│ ' + '                                DISPAROS'.PadRight(77,' ') + '│'
        #Write-Output $str

        #$str = '│ TOTAL:' + $Triggers[$i].ToString().PadRight(8,' ') + '  ' + 
        #       'OK:' + $okCount[$i].ToString().PadRight(8,' ') + '  ' + 
        #       'ERRORES:' + ($Triggers[$i] - $okCount[$i]).ToString().PadRight(8,' ') + '  ' #+ 
               #'ULTIMO: ' + $Dates[$i].ToString().PadLeft(22,' ') + '│'
        #Write-Output $str

        $str = '│'
        Write-Host $str -NoNewline
        $str = ' FECHA DEL ULTIMO ERROR: ' + $Dates[$i].ToString().PadRight(53,' ') 
        Write-Host $str -ForegroundColor Red -NoNewline
        $str = '│'
        Write-Host $str 

        $str = '│'
        Write-Host $str -NoNewline
        $str = ' TIPO DEL ULTIMO ERROR: ' + $LastErrors[$i].ToString().PadRight(54,' ')
        Write-Host $str -ForegroundColor Red -NoNewline
        $str = '│'
        Write-Host $str 


        Write-Output '├──────────────────────────────────────────────────────────────────────────────┤'

    }

    Write-Output '│                                                                              │'
    Write-Output '└──────────────────────────────────────────────────────────────────────────────┘'
}




function HandshakeTable{
    param (
        [string[]]$Handshakes,
        [int[]]$Triggers,
        [int[]]$okCounts,
        [string[]]$Dates,
        [string[]]$LastErrors
     )   

    $result = ''
    $result = $result + '<h2>HANDSHAKES</h2><br>'
    $result = $result + '<table cellpadding="10" cellspacing="0" border="1" style="border-collapse: collapse; width: 100%; font-family: Arial, sans-serif; font-size: 10px">'
  
    $result = $result + '<thead>'
    $result = $result + '<tr style="background-color: #4CAF50; color: white;">'
    $result = $result + '<th rowspan="2">HANDSHAKE</th>'
    $result = $result + '<th colspan="3">DISPAROS</th>'
    $result = $result + '<th colspan="2">ULTIMO ERROR</th>'
    $result = $result + '</tr>'
    $result = $result + '<tr style="background-color: #4CAF50; color: white;">'
    #$result = $result + '<th>HANDSHAKE</th>'
    $result = $result + '<th>TOTAL</th>'
    $result = $result + '<th>OK</th>'
    $result = $result + '<th>ERROR</th>'
    $result = $result + '<th>FECHA</th>'
    $result = $result + '<th>TIPO</th>'

    $result = $result + '</tr>'
    $result = $result + '</thead>'
  
    $result = $result + '<tbody>'

    for ($i = 0; $i -lt $Handshakes.Length; $i++) {
    
        $result = $result + '<tr style="background-color: #f2f2f2;">'
    
        $result = $result + '<td>' + $Handshakes[$i] +'</td>'
        $result = $result + '<td style="text-align: center;">' + $Triggers[$i].ToString() +'</td>'

        $okPercent = [Math]::Round(100 * $okCount[$i] / $Triggers[$i],2)
        $result = $result + '<td style="text-align: right;">' + $okCount[$i].ToString() + ' (' + $okPercent + '%) ' + '</td>'
        
        $errPercent = [Math]::Round(100 * (($Triggers[$i] - $okCount[$i])) / $Triggers[$i],2)
        
        $cellColor = "green"
        if ($errPercent -gt 20 ){
            $cellColor = "yellow"
        }
        if ($errPercent -gt 50 ){
            $cellColor = "red"
        }

        $result = $result + '<td style="text-align: right; color: ' + $cellColor +'">' + ($Triggers[$i] - $okCount[$i]).ToString() + ' (' + $errPercent + '%) ' + '</td>'
        $result = $result + '<td>' + $Dates[$i].ToString()
        $result = $result + '<td>' + $LastErrors[$i].ToString()
        $result = $result + '</tr>'

    }



    $result = $result + '</tbody>'
    $result = $result + '</table>'


    return $result
}


# This is the HS health monitor. It  takes a snapshot of the HS and give information about 
# working status, send info by mail


$serverName = "vm00055.apre.siderca.ot"
$databaseName = "TNALEMSDEVDB"
#$connectionString = "Server=$serverName;Database=$databaseName;User Id=admin;password=apre"
$connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

$handshakes = New-Object System.Collections.ArrayList
$handshakesIds= New-Object System.Collections.ArrayList
$triggers = New-Object System.Collections.ArrayList
$OkCount = New-Object System.Collections.ArrayList
$Dates = New-Object System.Collections.ArrayList
$LastErrors = New-Object System.Collections.ArrayList


$str = 'Obteniendo handshakes...'
Write-Host $str

$query = 'SELECT * FROM [Handshake].[Handshake] WHERE [Active] = 1'
# Ejecutar la consulta
$command = $connection.CreateCommand()
$command.CommandText = $query
$reader = $command.ExecuteReader()
while ($reader.Read()) 
{
    $x = $handshakes.Add($reader["Code"].ToString())
    $x = $handshakesIds.Add($reader["idHandshake"])
    $x = $triggers.Add(0)
    $x = $OkCount.Add(0)
    #$fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $x = $Dates.Add('')
    $x = $LastErrors.Add('')
}
$reader.Close()


$str = 'Obteniendo ultimos errores...'
Write-Host $str

# Ultimo error de cada HS
for ($i = 0; $i -lt $handshakes.Count; $i++) {
    #Write-Output  $handshakesids[$i]
    $query = 'select TOP 1 * from [Handshake].[HandshakeHistory] WHERE idHandshake = '+ $handshakesIds[$i].ToString() + ' and Result < 0  order by InsDateTime desc'
#    Write-Output $query
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
    $query = 'select count(*) as qty from [Handshake].[HandshakeHistory] WHERE idHandshake = ' + $handshakesIds[$i].ToString() 
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
    $query = 'select count(*) as qty from [Handshake].[HandshakeHistory] WHERE Result = 1 and idHandshake = ' + $handshakesIds[$i].ToString() 
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



$str = 'Armando el correo...'
Write-Host $str

#DisplayScreen -Handshakes $handshakes -Triggers $triggers -okCounts $okCounts -Dates $Dates -LastErrors $LastErrors

$mail = $outlook.CreateItem(0)  # 0 representa un MailItem
$mail.To = 'dehanke@suppliers.tenaris.com'
#$mail.CC = "jtorresgauto@suppliers.tenaris.com"
$fecha = Get-Date -Format "dd/MM/yyyy"
$mail.Subject = "Análisis de Estado LEMS " + $fecha

$HandshakeTable = HandshakeTable -Handshakes $handshakes -Triggers $triggers -okCounts $okCounts -Dates $Dates -LastErrors $LastErrors

$mail.HTMLBody = "<html>$head<body>$HandshakeTable</body><html>"
$mail.Display()
$str = 'Listo!'
Write-Host $str
