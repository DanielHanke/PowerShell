Import-Module SQLite

$sDatabasePath = "C:\temp\db.srd"

$sConnectionString = "Data Source=$sDatabasePath"

$SQLiteConnection = New-Object System.Data.SQLite.SQLiteConnection 

$SQLiteConnection.ConnectionString = $sConnectionString

$SQLiteConnection.Open()


# Create table employees
$command = $SQLiteConnection.CreateCommand()
$command.CommandText = "CREATE TABLE Employees (id INT, name VARCHAR(100), age INT)"
$command.ExecuteNonQuery() | Out-Null

For ($i=0; $i -lt 1000; $i++) {
    $command.CommandText = "INSERT INTO Employees (id, name) VALUES (@id, @name)"
    $command.Parameters.AddWithValue("@id", $i) | Out-Null
    $feakName = "Sr nbr " + $i.ToString() 
    $command.Parameters.AddWithValue("@name", $feakName) | Out-Null
    $command.ExecuteNonQuery() | Out-Null
}

$SQLiteConnection.Close()
