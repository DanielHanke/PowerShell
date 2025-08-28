
# Crear una instancia de Outlook
$outlook = New-Object -ComObject Outlook.Application

$fecha = Get-Date -Format "dd_MM_yyyy"
#$fecha = '24_06_2025'

# Verificar si hice el archivo json del dia de hoy
if (Test-Path "C:\Dev\PowerShell\Mail\$fecha.json"){
    $json = Get-Content -Path "C:\Dev\PowerShell\Mail\$fecha.json" -Raw
    $participants = $json | ConvertFrom-Json
    }
else{
    Write-Output "El archivo no existe"
    exit
}



# Crear un nuevo correo
$mail = $outlook.CreateItem(0)  # 0 representa un MailItem

# Configurar los campos del correo

$rcpt = ""
for ($i = 0; $i -lt $participants.Count; $i++) {
    $rcpt = $rcpt + $participants[$i].Correo + ";"
}

$mail.To = $rcpt
$mail.CC = "jtorresgauto@suppliers.tenaris.com"
$fecha = Get-Date -Format "dd/MM/yyyy"
$mail.Subject = "Minuta de reunion " + $fecha
        
$people = "<ul>"
for ($i = 0; $i -lt $participants.Count; $i++) {
    #if ($participants[$i].Presente -eq 1){
    #    $people = $people + "<li>" + $participants[$i].Nombre + ' &#x270B;'
    #}
    #else{
        $people = $people + "<li>" + $participants[$i].Nombre
    #}
}
$people = $people + "</ul>"

$tasks = ""
for ($i = 0; $i -lt $participants.Count; $i++) {
    $tasks = $tasks + '<hr><h3>Tareas para ' + $participants[$i].Nombre + "</h3><br>"

    if ($participants[$i].tareas.Count -eq 0){
        $tasks = $tasks + '<p style="text-align: center;">No hay tareas a&uacute;n</p>'
    }
    else{
        #$tasks = $tasks + '<p style="text-align: center;">TAREAS INVOLUCRADAS'

        

        for ($j = 0; $j -lt $participants[$i].tareas.Count; $j++) {
            $tasks = $tasks + '<div style="border: 1px solid black; padding: 10px; width: fit-content;"><h3>&#x1F9FE;  CODIGO: ' + ($i+1).ToString() + '.' + ($j+1).ToString() + "</h3>"
            
            $tasks = $tasks + '<p style="text-align: left;width:100%;background-color:#ececf0;color:#0e0e83"><b>PROYECTO</b> ' 
            $tasks = $tasks + '<p style="text-align: center;">' + $participants[$i].tareas[$j].Proyecto             + "</p>"
            
            $tasks = $tasks + '<p style="text-align: left;width:100%;background-color:#ececf0;color:#0e0e83"><b>DESCRIPCION</b>'
            $tasks = $tasks + '<p style="text-align: center;">'    + $participants[$i].tareas[$j].Descripcion          + "</p>"

            if ($participants[$i].tareas[$j].Items.Count -gt 0){
                $items = '<p style="text-align: left;width:100%;background-color:#ececf0;color:#0e0e83"><b>PASOS</b><ul>'

                for ($w = 0; $w -lt $participants[$i].tareas[$j].Items.Count; $w++) {
                    if ($participants[$i].tareas[$j].Items[$w].Terminado -eq 0){
                        $items = $items + '<li style="color:#707371;">' + ' &#x2610; ' + $participants[$i].tareas[$j].Items[$w].Descripcion
                    }
                    else{
                        $items = $items + '<li style="color:#64b979;">' + ' &#x2611; ' + $participants[$i].tareas[$j].Items[$w].Descripcion
                    }
                }
                $items = $items + "</ul>"
                $tasks = $tasks + $items
            }

            
            #$tasks = $tasks + '<p style="text-align: left;width:100%;background-color:#ececf0;color:#0e0e83"><b>ESTADO</b></p><p>'

            # Progreso
            $itemsFinshed = 0
            for ($w = 0; $w -lt $participants[$i].tareas[$j].Items.Count; $w++) {
                if ($participants[$i].tareas[$j].Items[$w].Terminado -eq 1){
                    $itemsFinshed = $itemsFinshed + 1
                }
            }
            if ($participants[$i].tareas[$j].Items.Count -eq 0){
                $progreso = 0
            }
            else{
                $progreso = [math]::Truncate((100 * $itemsFinshed / $participants[$i].tareas[$j].Items.Count) / 10)
                
            }

            $estado = 'EN PROCESO'
            $statusColor = '<p style="color: #14ba19;text-align: center;">'
            if ($itemsFinshed -eq $participants[$i].tareas[$j].Items.Count ){
                $statusColor = '<p style="color: #0d5cd6;text-align: center;">'
                $estado = 'FINALIZADO' 
            }
            if ($itemsFinshed -eq 0 ){
                $statusColor = '<p style="color: #f38d1a;text-align: center;">'
                $estado = 'NO INICIADO' 
            }


            Write-Output $progreso
            $tasks = $tasks + $statusColor + $estado + ' ( ' + ($progreso * 10).ToString() + ' %)' + ' ' + $itemsFinshed.ToString() + ' de ' + $participants[$i].tareas[$j].Items.Count.ToString()

            for ($z = 0; $z -lt $progreso; $z++) {
                $tasks = $tasks + '&#x1F7E9;'
                }
            for ($z = $progreso; $z -lt 10; $z++) {
                $tasks = $tasks + '&#x1F7EB;'
                }
            $tasks = $tasks + "</p>"

            $tasks = $tasks + '<p style="text-align: left;width:100%;background-color:#ececf0;color:#0e0e83"><b>OBJETIVO</b>'
            $tasks = $tasks + '<p style="text-align: center;">'    + $participants[$i].tareas[$j].Objetivo          + "</p>"

            $tasks = $tasks + "</div>"
        }
        $tasks = $tasks + '</p>'
    }
}

$head = "<head><style>.tarjeta {width: 300px;padding: 20px;margin: 20px auto;border-radius: 15px;box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);font-family: Arial, sans-serif;}</style></head>"

$motivo = '<p style="text-indent: 30px;">Este correo trata sobre el status de las tareas de los participantes del grupo.  Por cada uno, se describen sus tareas.</p>'
$motivo = $motivo + '<p style="text-indent: 30px;">Cada una de ellas posee un c&oacute;digo para referencia, el proyecto al que pertenece y un estado para facilitar el seguimiento de las mismas.</p>'
$motivo = $motivo + '<p style="text-indent: 30px;">Es aconsejable generar o pedir un ticket en el repositorio GitHub correspodiente, a cada tarea. Tambien lo es, seguir los lineamientos de branch y pull request de cada proyecto. Cualquier duda o consulta, ver con <a href=\"mailto:DEHANKE@suppliers.tenaris.com\">Daniel Hanke</a>.</p>'

$footer = '<p style="text-indent: 30px">Este correo se enviará en cada daily, Guardalos para tu seguimiento.</p><br><p style="text-align: center;"><b>Que tengas un buen día laboral!</b> &#x1F44B; </p>'

#$svg = '<svg width="400" height="200"> <rect x="10" y="10" width="50" height="180" fill="blue" /> <rect x="70" y="30" width="50" height="160" fill="green" /> <rect x="130" y="50" width="50" height="140" fill="red" /> </svg>'
$mail.HTMLBody = "<html>$head<body><h2>Daily meeting del d&iacute;a $fecha</h2><br>$motivo<h3>Participantes:</h3><br>$people<br><h3><Tareas></h3>$tasks<br>$footer</body><html>"



$mail.Display()


# mail por participante
#for ($i = 0; $i -lt $participants.Count; $i++) {
#    $mail = $outlook.CreateItem(0)  # 0 representa un MailItem
#    $mail.Display()
#}
