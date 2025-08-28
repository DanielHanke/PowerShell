try
{
    if ($args.count -ne 1 ){
        Write-Host "Sintaxis del comando incorrecta"
        Write-Host "utilice GetSpecById <idSpecification>" -ForegroundColor Yellow;
        Write-Host "Ejemplo GetSpecById 35125"
        return ;
    }
    #$idSpec = Read-Host "Ingresar el IdSpecification"
    $idSpec = $args[0]
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
        $Command1.CommandText = "SELECT S.idSpecification, SC.idComponent as idOrderKey, CV.idComponentAttributeValue, CT.Description, A.Code, Value "  + 
                                " FROM Specification.Attribute A " +  
                                "INNER JOIN Specification.ComponentAttributeValue CV ON CV.IdAttribute = A.IdAttribute "+
                                "INNER JOIN Specification.Component C ON C.idComponent = CV.idComponent "+
                                "INNER JOIN Specification.ComponentType CT ON CT.idComponentType = C.idComponentType "+
                                "INNER JOIN Specification.SpecificationComponent SC ON SC.idComponent = C.idComponent "+
                                "INNER JOIN Specification.Specification S ON S.idSpecification = SC.idSpecification	"+
                                "WHERE S.idSpecification = " + $idSpec;
        $Reader1 = $Command1.ExecuteReader()
        while($Reader1.Read()){
            Write-Host ($Reader1.GetValue(3), $Reader1.GetValue(4), $Reader1.GetValue(5)) -Separator  "|"
        }

        $Reader1.Close();
        $conn.Close()
    }
}
catch
{
    Write-Host "Error conectando la DB";
}