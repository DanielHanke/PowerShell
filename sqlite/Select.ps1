Import-Module SQLite

$sDatabasePath = "C:\temp\db.srd"
$sConnectionString = "Data Source=$sDatabasePath"
$SQLiteConnection = New-Object System.Data.SQLite.SQLiteConnection 
$SQLiteConnection.ConnectionString = $sConnectionString

$SQLiteConnection.Open()

$command = $SQLiteConnection.CreateCommand()
$command.CommandText = "SELECT * FROM Employees LIMIT 10"
$reader = $command.ExecuteReader()
while ($reader.HasRows){
  if ($reader.Read()){
    Write-Host "ID: " $reader["id"] " - " "name: " $reader["name"]
  }
}

$reader.Close()
$SQLiteConnection.Close()
