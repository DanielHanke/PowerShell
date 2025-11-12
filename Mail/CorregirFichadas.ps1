#
# Prepara para enviar un correo en caso de corregir la hora de salida
#
# Ej
# C:\dev\PowerShell\Mail\CorregirFichada.ps1 -fecha "09/10/2025" -hora "16:40"

 param (
    [string]$fecha = '09/10/2025',
    [string]$hora = '17:00'
 )

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
$mail.HTMLBody = $mail.HTMLBody + "Te pido, por favor, corregir la fichada del dia <b>$fecha</b>, deberia tener la hora de salida <b>$hora</b> "
$mail.HTMLBody = $mail.HTMLBody + "<br><br>Saludos!"

$mail.HTMLBody = $mail.HTMLBody + "</BODY></HTML>"

$mail.Display()
