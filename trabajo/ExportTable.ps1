
 # Copy data
 # permite copiar datos de una base de datos de una tabla a un archivo, quedando listo para ejecutarlo tipo script


 $cnStrOrigen = "Server=VM00006.apre.siderca.ot;Database=patrones;User Id=patronesadm;Password=tucan"
 #$cnStrDestino = "Server=TNSX00000339\\DEV;Database=patrones;User ID=sa;Password=Tnsx_00000339;Persist Security Info=True;"

$tableName = "dbo.Pedidos"
$FileName = "d:\temp\" + $tableName + ".sql"



$sqlOrigen = "SELECT * FROM " + $tablename

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $cnStrOrigen
$connection.Open()

# Ejecutar la consulta
$command = $connection.CreateCommand()
$command.CommandText = $sqlOrigen


$dataReader = $command.ExecuteReader()
$schemaTable = $dataReader.GetSchemaTable()


if (Test-Path $fileName) {
    Remove-Item $FileName
}



while ($dataReader.Read()) 
    {
    
    $str = "INSERT INTO " + $tablename + " Values ("    
    
    for ($row = 1; $row -le $schemaTable.Rows.Count -1; $row++) 
    {
        #Write-Output $schemaTable.Rows[$row].ColumnName
        if ($dataReader.IsDBNull($dataReader.GetOrdinal($schemaTable.Rows[$row].ColumnName))) 
        {
            $str = $str + "null"
            #Write-Output "null,"
        }
        else{
            #Write-Output $schemaTable.Rows[$row].DataType.Name


            switch ($schemaTable.Rows[$row].DataType.Name) {
                "Int32" { 
                    $str = $str + $dataReader[$schemaTable.Rows[$row].ColumnName].ToString() 
                }
                "Boolean" {
                    if ($dataReader[$schemaTable.Rows[$row].ColumnName]){
                        $str = $str + "1"
                    }
                    else {
                        $str = $str + "0"
                    }
                }

                "DateTime" { 
                    $str = $str + "'"
                    $str = $str + $dataReader[$schemaTable.Rows[$row].ColumnName].ToString() + "'" 

                }
                "String" { 
                    $str = $str + "'"
                    $str = $str + $dataReader[$schemaTable.Rows[$row].ColumnName].ToString().Replace("'", " ") + "'" 

                }
                default { 
                    #Write-Output "La variable no es A, B ni C" 
                    $str = $str + $dataReader[$schemaTable.Rows[$row].ColumnName].ToString()  
                }
            }

        }
            if ($row -le $schemaTable.Rows.Count -2)
            {
                $str = $str + ','
            }
    }
    $str = $str + ');'
    Write-Output $str >> $FileName
}

$dataReader.Close()
$connection.Close()
