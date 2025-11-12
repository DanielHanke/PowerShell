###############################################################################
# SqlServerTabla2MermaidER                                                    #
#   This script convert a sql server table definition into a ER Mermaid       #
#   diagram. This is useful to document a table in Github issue, for example  #
#
#


# Parámetros de conexión
$server = "TNSX00000339\DEV"
$database = "SN.TREND.SGP.QA"
$table = "PersonClass"
$usuario = "sa"
$password = "Tnsx_00000339"

$server = "10.200.120.59"
$database = "GestionApreDB"
$table = "ContratadosCategoria"
$usuario = "admin"
$password = "apre"


# Cadena de conexión
$connectionString = "Server=$server;Database=$database;User Id=$usuario;Password=$password;"

# Consulta SQL para obtener columnas y tipos
$query = @"
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '$table'
ORDER BY ORDINAL_POSITION
"@

# Crear conexión y comando
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$command = $connection.CreateCommand()
$command.CommandText = $query

# Ejecutar consulta
$connection.Open()
$reader = $command.ExecuteReader()

# Mostrar resultados
Write-Host "$table {" #`n
while ($reader.Read()) {
    $columna = $reader["COLUMN_NAME"]
    $tipo = $reader["DATA_TYPE"]
    $dataType = "int"
    switch ($tipo) {
        "nvarchar" { $dataType = "string" }
        "bit"      { $dataType = "bit" }
        "bigbit"   { $dataType = "int" }
        default    { $dataType = "int" }
    }
    Write-Host "   $tipo $columna"
}
Write-Host "}"

# Cerrar conexión
$reader.Close()
$connection.Close()
