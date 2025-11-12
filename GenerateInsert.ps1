$server = "VM00055.apre.siderca.ot"
$database = "TNALEMSDEVDB"
$table = "Alarm"
$schema = "Alarm"
$user = "lems"
$password = "lems"

# Cadena de conexión
$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;"

# Consulta para obtener columnas y tipos
$query = @"
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '$table' AND TABLE_SCHEMA = '$schema'
ORDER BY ORDINAL_POSITION
"@

# Crear conexión
$connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
$command = $connection.CreateCommand()
$command.CommandText = $query

# Ejecutar consulta
$connection.Open()
$reader = $command.ExecuteReader()

# Construir lista de columnas y valores de ejemplo
$columnList = @()
$valueList = @()

while ($reader.Read()) {
    $col = $reader["COLUMN_NAME"]
    $type = $reader["DATA_TYPE"]

    $columnList += $col

    # Generar valor de ejemplo según tipo
    switch ($type) {
        "int"       { $valueList += "1" }
        "bigint"    { $valueList += "100000" }
        "varchar"   { $valueList += "'Ejemplo_$col'" }
        "nvarchar"  { $valueList += "N'Ejemplo_$col'" }
        "datetime"  { $valueList += "'2025-09-04 13:00:00'" }
        "date"      { $valueList += "'2025-09-04'" }
        "bit"       { $valueList += "1" }
        "float"     { $valueList += "3.14" }
        default     { $valueList += "'VALOR'" }
    }
}

$reader.Close()
$connection.Close()

# Construir comando INSERT
$columns = ($columnList -join ", ")
$values = ($valueList -join ", ")
$insertCommand = "INSERT INTO $table ($columns) VALUES ($values);"

# Mostrar resultado
Write-Host "`nComando generado:`n"
Write-Host $insertCommand