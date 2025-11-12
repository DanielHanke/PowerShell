#
# Prepara para enviar un correo en caso de corregir la hora de salida
#
# Ej
# C:\dev\PowerShell\Mail\CorregirFichada.ps1 -fecha "09/10/2025" -hora "16:40"

 param (
    [string]$fecha,
    [string]$hora
 )

Write-Host "Este script arma un correo para corregir el maldito fichap al responsable, en este caso Richard"

if (-not $fecha) {
    $fecha = Read-Host "Por favor ingresá la fecha en este formato (09/10/2025): "
}

if (-not $hora) {
    $hora = Read-Host "Por favor ingresá la hora en este formato (16:45): "
}


# Crear una instancia de Outlook
$outlook = New-Object -ComObject Outlook.Application

# Crear un nuevo correo
$mail = $outlook.CreateItem(0)  # 0 representa un MailItem

# Configurar los campos del correo
$mail.To = "rtejerina@tenaris.com;JTORRESGAUTO@suppliers.tenaris.com"
#$mail.CC = "jtorresgauto@suppliers.tenaris.com"
$mail.Subject = "Control Fichap"
#$mail.BodyFormat = olFormatHTML
$mail.HTMLBody = "<HTML><BODY>"
$mail.HTMLBody = $mail.HTMLBody + "Hola, Ricardo, cómo estas?"
$mail.HTMLBody = $mail.HTMLBody + "<br><br>" 
$mail.HTMLBody = $mail.HTMLBody + "Te pido, por favor, corregir la fichada del día <b>$fecha</b>, debería tener la hora de salida <b>$hora</b> "
$mail.HTMLBody = $mail.HTMLBody + "<br><br>Saludos!"

$mail.HTMLBody = $mail.HTMLBody + "</BODY></HTML>"

$mail.Display()
