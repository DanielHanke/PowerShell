# Parámetros
$EmailFrom = "dhanke@trendingenieria.com.ar"
$EmailTo = "danieleduardohanke@gmail.com"
$Subject = "Correo automatico"
$Body = "<p>Correo autom&aacute;tico desde <b>PowerShell</b></p><p>Correo autom&aacute;tico desde <b>PowerShell</b></p>"
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

