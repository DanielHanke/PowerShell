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

        if ($dataset[$row-2][2] -eq 1 )
        {
            $style = "good"
        }
        else
        {
            $style = "warning"
        }

        switch($col)
        {
            1 
            {
                $hAlign = "left"
            }
            2
            {
                $hAlign = "Center"
            }
            default
            {
                $hAlign = "Center"
            }
        }


        $tableRow.cells += [PSCustomObject]@{
            type = "TableCell"
            style = $style
            items = @(
                [PSCustomObject]@{
                    type = "TextBlock"
                    text = $text
                    horizontalAlignment = $hAlign
                    verticalAlignment = "Center"
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


#
# Main menu
#
$servers = [System.Collections.ArrayList]@()

$servers.Add(@("gestion.prem.apre.siderca.ot"))
$servers.Add(@("hcc00172.apre.siderca.ot"))
$servers.Add(@("VM00006.apre.siderca.ot"))
$servers.Add(@("gestion.tref.apre.siderca.ot"))


foreach ($server in $servers)
{


    $columns = @("OBJETO", "VALOR" )
    $arrayList = [System.Collections.ArrayList]@()

    try
    {
        # Usa WMI para obtener la información del uso de CPU
        $cpuUsage = Get-WmiObject -ComputerName $server -Class Win32_Processor 
        # cores 
        $totalLoadPercentage = 0
        $processorCount = 0
        foreach ($cpu in $cpuUsage) {
            $totalLoadPercentage += $cpu.LoadPercentage
            $processorCount++
        }
        $averageLoadPercentage = $totalLoadPercentage / $processorCount
        $label = "PROMEDIO USO CPU"
        $value = $averageLoadPercentage.ToString() + " %"
        # cpu Mayor de 90%, aviso
        $ok = if ($averageLoadPercentage -lt 90) { 1 } else { 0 }
        $arrayList.Add(@($label, $value, $ok))
    }
    catch
    {
        $label = "WMI Win32_Processor"
        $value = $_
        $arrayList.Add(@($label, $value, 0))
    }

    try
    {

        # Usa WMI para obtener la información de la CPU y la memoria
        $wmiObject = Get-WmiObject -ComputerName $server -Class Win32_OperatingSystem
        $totalMemory = $wmiObject.TotalVisibleMemorySize
        $freeMemory = $wmiObject.FreePhysicalMemory
        #memory
        $value = ([Math]::Round(($totalMemory / 1024 / 1024),2)).ToString() + " Gbytes"
        $arrayList.Add(@("MEMORIA TOTAL (GB)", $value, 1))
        $value = ([Math]::Round(($freeMemory / 1024 / 1024),2)).ToString()  + " Gbytes"

        $percentFree = [Math]::Round(($freeMemory * 100) / $totalMemory, 2 )
        $arrayList.Add(@("MEMORIA LIBRE (GB)", $value, 1))
        $value = $percentFree.ToString() + " %"
        # memoria < 10% aviso
        $ok = if ($percentFree -gt 9) { 1 } else { 0 }
        $arrayList.Add(@("MEMORIA LIBRE (%)", $value, $ok))
    }
    catch
    {
        $label = "WMI Win32_OperatingSystem"
        $value = $_
        $arrayList.Add(@($label, $value, 0))
    }


    #discs
    try
    {
        $disks = Get-WmiObject -ComputerName $server -Class Win32_LogicalDisk
        $hardDisks = $disks | Where-Object { $_.DriveType -eq 3 }
        foreach ($disk in $hardDisks) {
            $totalSpace = [math]::Round($disk.Size / 1GB, 2)
            $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)

            $label = "DISCO " + $($disk.DeviceID).ToString() + " ESPACIO TOTAL"
            $value = $totalSpace.ToString() + " GBytes"
            $arrayList.Add(@($label, $value, 1))
            $label = "DISCO " + $($disk.DeviceID).ToString() + " ESPACIO LIBRE"
            $percentfree = [Math]::Round((($freeSpace * 100) / $totalSpace),2)
            $value = $freeSpace.ToString() + " GBytes" + "  (" + $percentFree.ToString() + ")" +" %"
            # espacio libre del disco <= 5%
            $ok = if ($percentFree -gt 5) { 1 } else { 0 }
            $arrayList.Add(@($label, $value, $ok))
        }
    }
    catch
    {
        $label = "WMI Win32_LogicalDisk"
        $value = $_
        $arrayList.Add(@($label, $value, 0))
    }
    $json = GenerateCard -title $server -subtitle "Valores obtenidos:" -columns $columns -dataset $arrayList
    Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $json
}









