Connect-MgGraph -Scopes "User.Read.All" -NoWelcome
# Reemplaza 'userPrincipalName' con el correo electrónico del usuario
$userPrincipalName = "MDCIANCHETTA@tenaris.com"

# Obtener el userId del usuario
$user = Get-MgUser -UserId $userPrincipalName
Write-Output $user

$userId = $user.Id

# Obtener el estado de presencia del usuario
#$presence = Get-MgUserPresence -UserId $userId
#$users = Get-MgUser

# Mostrar los usuarios
#$users | ForEach-Object {
#    Write-Output "Nombre: $($_.DisplayName), Correo: $($_.Mail)"
#}

# Mostrar el estado de presencia
#Write-Output "El estado de presencia de $($user.DisplayName) es $($presence.Availability)"

# Obtener la foto de perfil del usuario
Get-MgUserPhotoContent -UserId $userId -OutFile "C:\Dev\PowerShell\trabajo\$userPrincipalName.jpg"
