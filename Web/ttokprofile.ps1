# URL del perfil de TikTok (reemplaza con el tuyo)
$perfilTikTok = "https://www.tiktok.com/@kattbby8"

# Ruta para guardar los enlaces
$archivoSalida = "$env:USERPROFILE\Downloads\urls_tiktok.txt"

# Obtener el HTML del perfil
try {
    Write-Host "Accediendo al perfil: $perfilTikTok"
    $respuesta = Invoke-WebRequest -Uri $perfilTikTok -UseBasicParsing

    Write-Output $respuesta.Content | Out-File -FilePath "D:\TEMP\test.html" -Encoding UTF8

    # Buscar URLs de videos
    $urls = ($respuesta.Links | Where-Object { $_.href -like "*video/*" }).href | Sort-Object -Unique

    if ($urls.Count -gt 0) {
        $urls | Out-File -FilePath $archivoSalida -Encoding UTF8
        Write-Host "Se encontraron $($urls.Count) enlaces. Guardados en: $archivoSalida"
    } else {
        Write-Warning "No se encontraron enlaces de video en el perfil."
    }
} catch {
    Write-Error "Error al acceder al perfil: $_"
}
