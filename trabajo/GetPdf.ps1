    param (
        [string]$codigo,
        [string]$path
    )

# Parámetros de conexión
$server = "VM00006.apre.siderca.ot"
$database = "Patrones"
$user = "patronesadm"
$password = "Tucan"
$query = "select tpr.CertificateFile from testpipeRevision tpr join patron p on p.id = tpr.IdTestPipe where p.codigo='" + $codigo + "'"

# Crear conexión
$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;"
$connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
$command = $connection.CreateCommand()
$command.CommandText = $query

# Ejecutar y leer el binario
$connection.Open()
$reader = $command.ExecuteReader()

$index = 1

while($reader.Read()) {
    $buffer = New-Object byte[] ($reader.GetBytes(0, 0, $null, 0, 0))
    $reader.GetBytes(0, 0, $buffer, 0, $buffer.Length)

    $outputPath = $path +"\\"+ $codigo + "_" + $index.ToString() +".pdf"
    [System.IO.File]::WriteAllBytes($outputPath, $buffer)
    Write-Output $outputPath
    # Abrir el PDF
    #Start-Process $outputPath
    $index = $index + 1
}
$str = "se generaron " + ($index-1).ToString() + " archivos en " + $path
Write-Output $str
$reader.Close()
$connection.Close()
