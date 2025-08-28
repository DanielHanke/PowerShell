# Configuración de las conexiones
$sourceServer = "VM00006.apre.siderca.ot"
$sourceDatabase = "patrones"
$sourceUser = "patronesadm"
$sourcePassword = "tucan"

$destinationServer = "TNSX00000339\\DEV"
$destinationDatabase = "patrones2"
$destinationUser = "sa"
$destinationPassword = "Tnsx_00000339"


# Obtener la lista de tablas desde la base de datos fuente
$tablesQuery = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
$tables = Invoke-Sqlcmd -ServerInstance $sourceServer -Database $sourceDatabase -Username $sourceUser -Password $sourcePassword -Query $tablesQuery

foreach ($table in $tables) {
    $tableName = $table.TABLE_NAME

    # Generar el script de creación de la tabla
    $createTableScript = Invoke-Sqlcmd -ServerInstance $sourceServer -Database $sourceDatabase -Username $sourceUser -Password $sourcePassword -Query "EXEC sp_helptext 'dbo.$tableName'"

    # Ejecutar el script de creación en la base de datos de destino
    Invoke-Sqlcmd -ServerInstance $destinationServer -Database $destinationDatabase -Username $destinationUser -Password $destinationPassword -Query $createTableScript

    # Exportar datos de la tabla desde la base de datos fuente
    $exportCommand = "bcp $sourceDatabase.dbo.$tableName out $tableName.dat -S $sourceServer -U $sourceUser -P $sourcePassword -c"
    Invoke-Expression $exportCommand

    # Importar datos de la tabla a la base de datos destino
    $importCommand = "bcp $destinationDatabase.dbo.$tableName in $tableName.dat -S $destinationServer -U $destinationUser -P $destinationPassword -c"
    Invoke-Expression $importCommand

    # Eliminar el archivo temporal
    Remove-Item "$tableName.dat"
}

Write-Host "Copiado de tablas completado."

