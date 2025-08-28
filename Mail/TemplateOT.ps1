# Crear una instancia de Outlook
$outlook = New-Object -ComObject Outlook.Application


$rutaArchivo = "C:\Dev\PowerShell\Mail\OT.txt"


Get-Content $rutaArchivo | ForEach-Object {


    $campos = $_ -split ","


    if ($campos[0].Trim() -eq "1"){

        $nombre = $campos[3].Trim() #"Mauro"
        $trabajo = $campos[4].Trim() # "Análisis de replicación de variables SPC para Quindao"
        $tipoPedido = $campos[1].Trim()

        # Crear un nuevo correo
        $mail = $outlook.CreateItem(0)  # 0 representa un MailItem

        # Configurar los campos del correo
        $mail.To = $campos[2].Trim() #"mdcianchetta@tenaris.com"
        $mail.CC = "jtorresgauto@suppliers.tenaris.com"
        $mail.Subject = "Pedido de OT"
        #$mail.BodyFormat = olFormatHTML
        $mail.HTMLBody = "<HTML><BODY>"
        $mail.HTMLBody = $mail.HTMLBody + "Hola, $nombre, cómo estas?"
        $mail.HTMLBody = $mail.HTMLBody + "<br><br>" 
        $mail.HTMLBody = $mail.HTMLBody + "Te $tipoPedido la OT por el siguiente tema: "
        $mail.HTMLBody = $mail.HTMLBody + "<b>$trabajo</b> <br><br>Saludos!"

        $mail.HTMLBody = $mail.HTMLBody + "</BODY></HTML>"

        $mail.Display()
    }
}
