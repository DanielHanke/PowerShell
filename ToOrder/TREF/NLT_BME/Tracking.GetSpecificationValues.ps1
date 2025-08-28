function WriteTable( $reader ) {
    if ($idFormat -eq "html"){
        Write-Host ("<table style=""width: 80%;border-collapse: collapse;margin: 25px 0;font-size: 0.9em;font-family: sans-serif;min-width: 400px;box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);"">");
        Write-Host ("<thead style=""background-color: #009879;color: #ffffff;text-align: left;"">");
        Write-Host ("<tr style=""background-color: #009879;color: #ffffff;text-align: left;"">");
        for ($index = 0; $index -lt $reader.FieldCount; $index++){
            Write-Host("<th style=""padding: 2px 5px;"">" + $reader.GetName($index) + "</th>");
        }
        Write-Host ("</tr>");
        Write-Host ("</thead>");
        Write-Host ("<tbody>"); 
        $RowCount = 0;   
    }

    while($reader.Read()){
        if ($idFormat -eq "html"){
            Write-Host ("<tr style=""border-bottom: 1px solid #dddddd;"">"); 
            for ($index = 0; $index -lt $reader.FieldCount; $index++){
                if (($RowCount % 2) -eq 1 ){
                    Write-Host("<td style=""padding: 2px 5px; background-color: #f3f3f3;"">" + $reader.GetValue( $index ) + "</td>");
                }
                else{
                    Write-Host("<td style=""padding: 2px 5px;"">" + $reader.GetValue( $index ) + "</td>");
                }
            }
            Write-Host ("</tr>");
            $RowCount++;
        }            
        else {
            for ($index = 0; $index -lt $reader.FieldCount; $index++){            
                Write-Host($reader.GetValue( $index ));
            #Write-Host ($reader.GetValue(3).PadRight(30), $reader.GetValue(4).PadRight(30), $reader.GetValue(5).PadLeft(30),"") -Separator  "|"
            }
        }
    }

    if ($idFormat -eq "html"){
        Write-Host ("</tbody>");
    } 
}



try
{
    if ($args.count -lt 1 ){
        Write-Host "Sintaxis del comando incorrecta"
        Write-Host "utilice GetSpecValuesByIdTracking <idtracking> [console|html]" -ForegroundColor Yellow;
        Write-Host "Ejemplo GetSpecValuesByIdTracking 45135"
        return ;
    }
    else {
        $idTracking = $args[0]
        if ($args.count -lt 2 ){
            $idFormat = "console"
        }
        else {
            $idFormat = $args[1]
        }
    }
    
    

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

        $Command3 = New-Object System.Data.SQLClient.SQLCommand
        $Command3.Connection = $conn
        $Command3.CommandText = "SELECT S.idSpecification, SC.idComponent as idOrderKey, CV.idComponentAttributeValue, CT.Description, A.Code, Value "  + 
                                " FROM Specification.Attribute A " +  
                                "INNER JOIN Specification.ComponentAttributeValue CV ON CV.IdAttribute = A.IdAttribute "+
                                "INNER JOIN Specification.Component C ON C.idComponent = CV.idComponent "+
                                "INNER JOIN Specification.ComponentType CT ON CT.idComponentType = C.idComponentType "+
                                "INNER JOIN Specification.SpecificationComponent SC ON SC.idComponent = C.idComponent "+
                                "INNER JOIN Specification.Specification S ON S.idSpecification = SC.idSpecification	"+
                                "WHERE S.idSpecification = " + $idSpecification;
        $Reader1 = $Command3.ExecuteReader()
        WriteTable( $Reader1 );
        
        $Reader1.Close();
        $conn.Close()
    }
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Red;
}