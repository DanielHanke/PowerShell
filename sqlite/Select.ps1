Import-Module SQLite

$sDatabasePath = $PSScriptRoot + "\db.srd"
$sConnectionString = "Data Source=$sDatabasePath"
$SQLiteConnection = New-Object System.Data.SQLite.SQLiteConnection 
$SQLiteConnection.ConnectionString = $sConnectionString

$SQLiteConnection.Open()

$command = $SQLiteConnection.CreateCommand()
$command.CommandText = "SELECT * FROM Empleados LIMIT 10"
$reader = $command.ExecuteReader()
while ($reader.HasRows){
  if ($reader.Read()){
    Write-Host "ID: " $reader["id"] " - " "nombre: " $reader["nombre"]
  }
}

$reader.Close()
$SQLiteConnection.Close()
