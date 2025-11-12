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

# Consulta SQL
$query = "SELECT * FROM $table"

# Crear conexión y comando
$connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
$command = $connection.CreateCommand()
$command.CommandText = $query

# Abrir conexión
$connection.Open()
$reader = $command.ExecuteReader()

# Obtener nombres de columnas
$columns = @()
for ($i = 0; $i -lt $reader.FieldCount; $i++) {
    $columns += $reader.GetName($i)
}

# Construir encabezado Markdown
$header = "| " + ($columns -join " | ") + " |"
$separator = "|" + ($columns | ForEach-Object {":---:|" }) # + " |"

Write-Host "`n### 📋 Contenido de la tabla `$table` en formato Markdown`n"
Write-Host $header
Write-Host $separator

# Leer filas y mostrarlas en formato Markdown
while ($reader.Read()) {
    $row = "| "
    foreach ($col in $columns) {
        $value = $reader[$col].ToString().Replace("`n", " ").Replace("|", "\|")
        $row += "$value | "
    }
    Write-Host $row
}

# Cerrar conexión
$reader.Close()
$connection.Close()
