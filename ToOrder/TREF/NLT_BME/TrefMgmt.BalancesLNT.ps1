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
    if ($args.count -ne 0 ){
        Write-Host "Sintaxis del comando incorrecta"
        Write-Host "utilice BalancesGestion" -ForegroundColor Yellow;
        return ;
    }

    $idFormat = "html"

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
        $Command1.CommandText = "select b.BalanceID, wo.WorkOrder, " +
        "	( " +
        "	select ItemValue from [GESTION.TREF].[DbTrefMgmt].balances.balance b1 " +
        "		join [GESTION.TREF].[DbTrefMgmt].product.Product p on b1.ProductID = p.ProductID " +
        "		join [GESTION.TREF].[DbTrefMgmt].[product].[ProductProductComponent] ppc on ppc.ProductID = p.ProductID " +
        "		join [GESTION.TREF].[DbTrefMgmt].[product].[ProductComponent] pc on pc.ProductComponentID = ppc.ProductComponentID " +
        "		where b1.BalanceID = b.BalanceID and pc.ReferenceCode = 100 " +
        "	) as OP, " +
        "	( " +
        "	select ItemValue from [GESTION.TREF].[DbTrefMgmt].balances.balance b1 " +
        "		join [GESTION.TREF].[DbTrefMgmt].product.Product p on b1.ProductID = p.ProductID " +
        "		join [GESTION.TREF].[DbTrefMgmt].[product].[ProductProductComponent] ppc on ppc.ProductID = p.ProductID " +
        "		join [GESTION.TREF].[DbTrefMgmt].[product].[ProductComponent] pc on pc.ProductComponentID = ppc.ProductComponentID " +
        "		where b1.BalanceID = b.BalanceID and pc.ReferenceCode = 200 " +
        "	) as Lingada, " +
        "	( " +
        "	select ItemValue from [GESTION.TREF].[DbTrefMgmt].balances.balance b1 " +
        "		join [GESTION.TREF].[DbTrefMgmt].product.Product p on b1.ProductID = p.ProductID " +
        "		join [GESTION.TREF].[DbTrefMgmt].[product].[ProductProductComponent] ppc on ppc.ProductID = p.ProductID " +
        "		join [GESTION.TREF].[DbTrefMgmt].[product].[ProductComponent] pc on pc.ProductComponentID = ppc.ProductComponentID " +
        "		where b1.BalanceID = b.BalanceID and pc.ReferenceCode = 300 " +
        "	) as Secuencia, " +
        "	b.InputPieces, " +
        "	b.AcceptedPieces, " +
        "	b.RejectedPieces, " +
        "	b.ModifiedDate " +
        "	from [GESTION.TREF].[DbTrefMgmt].balances.balance b " +
        "	left join [GESTION.TREF].[DbTrefMgmt].wms.WorkOrdersByBalance wo on wo.BalanceID = b.BalanceID  " +
        "	where b.StationID in (50106002) and b.status not in (4,5)  "
        $Reader1 = $Command1.ExecuteReader()
        WriteTable( $Reader1 );
        $Reader1.Close();


        $conn.Close()
    }
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Red;
}