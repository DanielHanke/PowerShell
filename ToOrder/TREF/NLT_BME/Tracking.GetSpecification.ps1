try
{
    if ($args.count -ne 1 ){
        Write-Host "Sintaxis del comando incorrecta"
        Write-Host "utilice GetSpecByIdTracking <idtracking>" -ForegroundColor Yellow;
        Write-Host "Ejemplo GetSpecByIdTracking 45135"
        return ;
    }
    $idTracking = $args[0]


    $connString = Get-Content -Path .\db\TNANLTBPRDLSN.db

    #Create a SQL connection object
    $conn = New-Object System.Data.SqlClient.SqlConnection $connString

    #Attempt to open the connection
    $conn.Open()
    if($conn.State -eq "Open")
    {
        #Write-Host "Base de datos conectada" -ForegroundColor Green;


        $Command1 = New-Object System.Data.SQLClient.SQLCommand
        $Command1.Connection = $conn
        $Command1.CommandText = "select idProductionHistory from Tracking.Tracking where idTracking = " + $idTracking;
        $Reader1 = $Command1.ExecuteReader()
        $result = $Reader1.Read();
        $idProductionHistory = $Reader1.GetValue(0)
        #Write-Host "iProductionHistory es " $idProductionHistory -ForegroundColor Yellow;
        $Reader1.Close();


        $Command2 = New-Object System.Data.SQLClient.SQLCommand
        $Command2.Connection = $conn
        $Command2.CommandText = "select IdSpecification from Production.BatchHistory where idBatchHistory = " + $idProductionHistory;
        $Reader2 = $Command2.ExecuteReader()
        $result = $Reader2.Read();
        $idSpecification = $Reader2.GetValue(0)
        Write-Host "idSpecification es " $idSpecification -ForegroundColor Yellow;
        $Reader2.Close();

        $conn.Close()
    }
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Red;
}