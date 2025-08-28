#
# This scripts connets with an AUS database and get the last 10 HS errors
#
#

# URL del webhook
$webhookUrl = "https://tenaris.webhook.office.com/webhookb2/fa9cf46d-2762-4cb7-99dd-979dab2bcbd8@a054342c-6f8c-4378-ad61-a8ad00f2b736/IncomingWebhook/bab57062400641edb2870ce1dfe1fbc6/fdec8433-5417-4800-ae95-1deeb1a062c5/V2OJriElkru7HDwhl4nRq82y0_AF_7QKASn1tv9j9uZnI1"

Function GenerateCard{

    param (
        [string]$title,
        [string]$subtitle,
        [array]$columns,
        [System.Collections.ArrayList]$dataset
    )


#Write-Host $dataset.Count 

# Inicializar el JSON de la tarjeta adaptable
$adaptiveCard = [PSCustomObject]@{
    type = "AdaptiveCard"
    version = "1.4"
    body = @()
}

# Agregar un detalle
$adaptiveCard.body += [PSCustomObject]@{
    type = "TextBlock"
    text = $title
    weight = "bolder"
    size = "medium"
    horizontalAlignment = "center"
}

$adaptiveCard.body += [PSCustomObject]@{
    type = "TextBlock"
    text = $subtitle
    isSubtle = "true"
    size = "default"
    wrap = "true"
}

# Inicializar la tabla
$table = [PSCustomObject]@{
    type = "Table"
    columns = @()
    rows = @()
}

# Agregar columnas
for ($i = 1; $i -le $columns.Count; $i++) {
    $table.columns += [PSCustomObject]@{
        width = "auto"
    }
}

# Agregar filas y celdas
for ($row = 1; $row -le $dataset.Count +1; $row++) {
    $tableRow = [PSCustomObject]@{
        type = "TableRow"
        cells = @()
    }
    for ($col = 1; $col -le $columns.Count; $col++) {
        if ($row -eq 1 )
        {
            $text = $columns[$col-1]
        }
        else
        {
            $text = $dataset[$row-2][$col-1].ToString()
        }
        $tableRow.cells += [PSCustomObject]@{
            type = "TableCell"
            style = "good"
            items = @(
                [PSCustomObject]@{
                    type = "TextBlock"
                    text = $text
                }
            )
        }
    }
    $table.rows += $tableRow
}

# Agregar la tabla al cuerpo de la tarjeta
$adaptiveCard.body += $table

# Crear el mensaje con el attachment
$message = [PSCustomObject]@{
    type = "message"
    attachments = @(
        [PSCustomObject]@{
            contentType = "application/vnd.microsoft.card.adaptive"
            contentUrl = $null
            content = $adaptiveCard
        }
    )
}

# Convertir el objeto a JSON
$jsonString = $message | ConvertTo-Json -Depth 15

return $jsonString
}

# Cadena de conexión
$connectionString = "Data Source=VM00055.apre.siderca.ot;Initial Catalog=TNALEMSDEVDB;Integrated Security=True;Persist Security Info=True;"

# Crear y abrir la conexión a SQL Server
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()


$command = $connection.CreateCommand()
$command.CommandText = "Custom.GetLastHSErrors"
$command.CommandType = [System.Data.CommandType]::StoredProcedure


# Agregar los parámetros al comando
#$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@param1", $param1)))
#$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@param2", $param2)))


$reader = $command.ExecuteReader()

$columns = @( "COMPOSICION", "FECHA" )
$arrayList = [System.Collections.ArrayList]@()

$handshake = ""
while ($reader.Read()) 
{
    if ($handshake -ne $reader["HandShakeName"])
    {
        $arrayList.Add(@($reader["HandShakeName"], $reader["Callback"]))
        $handshake = $reader["HandShakeName"]
    }
    else
    {
       $arrayList.Add(@("", $reader["Callback"]))
    }
}


$json = GenerateCard -title "Reporte de Handshakes" -subtitle "Estos son los ultimos handshakes que dieron error:" -columns $columns -dataset $arrayList
#Write-Host $json
Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $json
