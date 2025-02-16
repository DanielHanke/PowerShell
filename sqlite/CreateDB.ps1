Import-Module SQLite


$sDatabasePath = $PSScriptRoot + "\db.srd"

$sConnectionString = "Data Source=$sDatabasePath"
$SQLiteConnection = New-Object System.Data.SQLite.SQLiteConnection 
$SQLiteConnection.ConnectionString = $sConnectionString
$SQLiteConnection.Open()

$command = $SQLiteConnection.CreateCommand()
$command.CommandText = "CREATE TABLE Empleados (id INT, nombre VARCHAR(100), edad INT)"
$command.ExecuteNonQuery() | Out-Null

For ($i=0; $i -lt 1000; $i++) {
    $command.CommandText = "INSERT INTO Empleados (id, nombre) VALUES (@id, @nombre)"
    $command.Parameters.AddWithValue("@id", $i) | Out-Null
    $nombreFantasia = "Sr numero " + $i.ToString() 
    $command.Parameters.AddWithValue("@nombre", $nombreFantasia) | Out-Null
    $command.ExecuteNonQuery() | Out-Null
}

$SQLiteConnection.Close()
