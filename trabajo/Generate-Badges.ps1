# Ruta de salida
$badgePath = "docs/badges"
New-Item -ItemType Directory -Force -Path $badgePath | Out-Null

function New-Badge {
    param (
        [string]$label,
        [string]$message,
        [string]$color = "blue",
        [string]$filename
    )

    $svg = @"
<svg xmlns="http://www.w3.org/2000/svg" width="150" height="20">
  <rect width="150" height="20" fill="$color"/>
  <text x="10" y="14" fill="white" font-family="Verdana" font-size="12">${label}: $message</text>
</svg>
"@

    $file = Join-Path $badgePath "$filename.svg"
    $svg | Out-File -Encoding utf8 $file
}

# Ejemplos dinámicos
New-Badge -label "Build" -message "OK" -color "green" -filename "build"
New-Badge -label "Version" -message "v1.2.3" -color "orange" -filename "version"
New-Badge -label "Visibilidad" -message "Privado" -color "gray" -filename "visibility"
New-Badge -label "Automatización" -message "Activa" -color "purple" -filename "custom"
