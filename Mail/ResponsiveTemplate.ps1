# Crear una instancia de Outlook
$outlook = New-Object -ComObject Outlook.Application


$htmlPath = "C:\Dev\PowerShell\Mail\template.html"


# Crear un nuevo correo
$mail = $outlook.CreateItem(0)  # 0 representa un MailItem

# Configurar los campos del correo
$mail.To = "dehanke@suppliers.tenaris.com"
#$mail.CC = "jtorresgauto@suppliers.tenaris.com"
$mail.Subject = "Test"
#$mail.BodyFormat = olFormatHTML
        
$htmlBody = Get-Content -Path $htmlPath -Raw

$mail.HTMLBody = $htmlBody



$mail.Display()

