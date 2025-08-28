


enum TIPO_MEDICION {
    CANAL_INTERNO
    CANAL_EXTERNO
}

Function DownloadLaserSignal{
     param (
        [System.Data.SqlClient.SqlConnection] $conn,
        [int]$IDTubo,
        [int] $TipoMedicion
     )
    
    $tipo = $TipoMedicion.GetHashCode()
    $query = "SELECT TOP 1 SenalLaser FROM HistoricoMedicionesPlano WHERE IdTubo = $IDTubo AND IdTipoMedicion = $Tipo"
    $command = $conn.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()

    $filePath = $PSScriptRoot +'\HistoricoMedicionesPlano_' + $IdTubo +'_SenalLaser_' + $Tipo +'.txt'
    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
    }


    # Leer los datos y convertirlos en un array de floats
    $floatsArray = @()
    while ($reader.Read()) 
    {
    
        $streamArray = $reader["SenalLaser"]
    
        $doubleArray = New-Object double[] ($streamArray.Length / 8)
        [System.Buffer]::BlockCopy($streamArray, 0, $doubleArray, 0, $streamArray.Length)
    
        foreach ($data in $doubleArray)
        {
         #Write-Host $data
         Add-Content -Path $filePath -Value $data
        }
    
    }

    $reader.Close()
}

Function DownloadDiameter{
     param (
        [System.Data.SqlClient.SqlConnection] $conn,
        [int]$IDTubo,
        [int] $TipoMedicion
     )
    
    if ($TipoMedicion -eq [TIPO_MEDICION]::CANAL_INTERNO){
        $columnName = 'DiametroInterno'
    }
    else{
        $columnName = 'DiametroExterno'
    }
    $query = 'SELECT TOP 1 ' + $columnName +" FROM HistoricoResultadosPlano WHERE IdTubo = $IdTubo"
    $command = $conn.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()

    $filePath = $PSScriptRoot +'\HistoricoResultadosPlano' + $IdTubo +'_DiametroTubo_' + $Tipo +'.txt'
    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
    }


    # Leer los datos y convertirlos en un array de floats
    $floatsArray = @()
    while ($reader.Read()) 
    {
    
        $streamArray = $reader[$columnName]
    
        $doubleArray = New-Object double[] ($streamArray.Length / 8)
        [System.Buffer]::BlockCopy($streamArray, 0, $doubleArray, 0, $streamArray.Length)
    
        foreach ($data in $doubleArray)
        {
         #Write-Host $data
         Add-Content -Path $filePath -Value $data
        }
    
    }

    $reader.Close()
}

Function DownloadPatternPipe{
     param (
        [System.Data.SqlClient.SqlConnection] $conn,
        [int]$IDTubo

     )

    $query = "SELECT TOP 1 * FROM [DbLc2fPemaDimex].[dbo].[HistoricoMedicionesTubo] WHERE IdTubo < $Idtubo AND Resultado = 36 ORDER BY IdTubo DESC"
    $command = $conn.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()

    $filePath = $PSScriptRoot +'\HistoricoMedicionesTubo' + $IdTubo +'_PatronTubo' +'.txt'
    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
    }

    $test = $reader.Read()
    #Write-Host $reader.GetSchemaTable()
    $str = 'IDTuboPatron : ' + ($reader["IDTubo"])
    Write-Host $str
    $str = 'DiameterMin = {' + [Math]::Round($reader["DiametroInternoMin"],2) + ', ' + [Math]::Round($reader["DiametroExternoMin"],2) + '}'
    Write-Host $str
    $str = 'DiameterMax = {' + [Math]::Round($reader["DiametroInternoMax"],2) + ', ' + [Math]::Round($reader["DiametroExternoMax"],2) + '}'
    Write-Host $str
    $str = 'ThicknessMin = ' + [Math]::Round($reader["EspesorMin"],2) 
    Write-Host $str
    $str = 'ThicknessMax = ' + [Math]::Round($reader["EspesorMax"],2) 
    Write-Host $str
    $str = 'MaxInternalOvality = ' + [Math]::Round($reader["OvalidadInterna"],2) 
    Write-Host $str
    $str = 'MaxExternalOvality = ' + [Math]::Round($reader["OvalidadExterna"],2) 
    Write-Host $str
    $str = 'MaxExcentricity = ' + [Math]::Round($reader["Excentricidad"],2) 
    Write-Host $str
  
    $reader.Close()
}

Function DownloadPipeParameters{
     param (
        [System.Data.SqlClient.SqlConnection] $conn,
        [int]$IDTubo

     )

    $query = "SELECT TOP 1 * FROM [dbo].[HistoricoParametrosMedicion] WHERE idParametrosMedicion = (SELECT idParametrosMedicion FROM [dbo].[HistoricoMedicionesTubo] WHERE IDTubo = $IDTubo )"
    $command = $conn.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()

    $filePath = $PSScriptRoot +'\ParametrosTubo' + $IdTubo +'_ParametrosTubo' +'.txt'
    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
    }

    $test = $reader.Read()
    #Write-Host $reader.GetSchemaTable()
    $str = 'IDTubo : ' + $IdTubo + ' Parámetros:'
    Write-Host $str
    $str = 'DiameterMin = {' + [Math]::Round($reader["DiametroInternoMinimo"],2) + ', ' + [Math]::Round($reader["DiametroExternoMinimo"],2) + '}'
    Write-Host $str
    $str = 'DiameterMax = {' + [Math]::Round($reader["DiametroInternoMaximo"],2) + ', ' + [Math]::Round($reader["DiametroExternoMaximo"],2) + '}'
    Write-Host $str
    $str = 'ThicknessMin = ' + [Math]::Round($reader["EspesorMinimo"],2) 
    Write-Host $str
    $str = 'ThicknessMax = ' + [Math]::Round($reader["EspesorMaximo"],2) 
    Write-Host $str
    $str = 'MaxInternalOvality = ' + [Math]::Round($reader["OvalidadIntMaxima"],2) 
    Write-Host $str
    $str = 'MaxExternalOvality = ' + [Math]::Round($reader["OvalidadExtMaxima"],2) 
    Write-Host $str
    $str = 'MaxExcentricity = ' + [Math]::Round($reader["ExcentricidadMaxima"],2) 
    Write-Host $str
    $str = 'InternalRadialGyrus = ' + [Math]::Round($reader["RadioGiroInterno"],12) 
    Write-Host $str
    $str = 'ExternalRadialGyrus = ' + [Math]::Round($reader["RadioGiroExterno"],12) 
    Write-Host $str
  
    $reader.Close()
}

# Configuración de la conexión a SQL Server
$serverName = "hcc00172.apre.siderca.ot"
$databaseName = "DbLc2fPemaDimex"

#$tableName = "HistoricoMedicionesPlano"
#$columnName = "SenalLaser"
$IdTubo = 2851546
$IdTipoMedicion = 1



# Cadena de conexión
$connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=True;"


# Crear y abrir la conexión a SQL Server
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

$str = "Procesando el tubo " + $IdTubo.ToString()
Write-Host $str -ForegroundColor Yellow

$str = "Bajando señal interna..."
Write-Host $str -ForegroundColor White
DownloadLaserSignal -conn $connection -IDTubo $IdTubo -TipoMedicion 0

$str = "Bajando señal externa..."
Write-Host $str -ForegroundColor White
DownloadLaserSignal -conn $connection -IDTubo $IdTubo -TipoMedicion 1

$str = "Bajando diametro interno calculado..."
Write-Host $str -ForegroundColor White
DownloadDiameter -conn $connection -IDTubo $IdTubo -TipoMedicion 0

$str = "Bajando diametro externo calculado..."
Write-Host $str -ForegroundColor White
DownloadDiameter -conn $connection -IDTubo $IdTubo -TipoMedicion 1

$str = "Bajando parametros de medicion ( radios de giro )..."
Write-Host $str -ForegroundColor White
DownloadPipeParameters -conn $connection -IDTubo $IdTubo

$str = "----------------------------------------------------------"
Write-Host $str -ForegroundColor White

$str = "Bajando datos del patron ... " + $IdTubo.ToString()
Write-Host $str -ForegroundColor White
DownloadPatternPipe -conn $connection -IDTubo $IdTubo

$str = "----------------------------------------------------------"
Write-Host $str -ForegroundColor White

$connection.Close()

$str = "Proceso terminado"
Write-Host $str -ForegroundColor Yellow
