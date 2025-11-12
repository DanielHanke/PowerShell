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


# Parámetros
$EmailFrom = "dhanke@trendingenieria.com.ar"
#$EmailTo =  "danieleduardohanke@gmail.com" , "danielhanke@outlook.es"
$EmailTo =  "rtejerina@tenaris.com" , "JTORRESGAUTO@suppliers.tenaris.com" ,"jtorres@trendingenieria.com.ar"
$Subject = "Control Fichap" # "Control Fichap"
$Body = "<HTML><BODY>Hola, Ricardo, c&oacute;mo estas?<br><br>Te pido, por favor, corregir la fichada del d&iacute;a <b>$fecha</b>, deber&iacute;a tener la hora de salida <b>$hora</b><br><br>Saludos!</BODY></HTML>"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = 587

# Leer contraseña de aplicación desde archivo
$PasswordFile = "C:\Dev\PowerShell\Mail\gmail_app_password.txt"
$AppPassword = Get-Content $PasswordFile | Out-String
$SecurePassword = ConvertTo-SecureString $AppPassword -AsPlainText -Force

# Crear credenciales
$Cred = New-Object System.Management.Automation.PSCredential ($EmailFrom, $SecurePassword)

# Enviar correo
Send-MailMessage -From $EmailFrom -To $EmailTo -BodyAsHtml -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $Cred
Write-Host "Listo, se envió desde el correo de Trend"
