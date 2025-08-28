# Ruta del repositorio local
$repoPath = ".\"
Set-Location $repoPath

# Obtener Ãºltimo commit
$commit = git log -1 --pretty=format:"%h|%ad|%s" --date=short
$parts = $commit -split "\|"
$hash = $parts[0]
$date = $parts[1]
$message = $parts[2]

# Limpiar el mensaje para SVG (evitar caracteres conflictivos)
$cleanMessage = $message -replace '[<>&"]', ''

# Crear SVG
$svgContent = @"
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="20">
  <rect width="400" height="20" fill="#555"/>
  <text x="10" y="15" fill="#fff" font-family="Verdana" font-size="12">
    último commit: $date : $cleanMessage
  </text>
</svg>
"@

# Guardar SVG
$svgPath = "$repoPath\.github\badges\last-commit.svg"
$svgContent | Out-File -Encoding UTF8 -FilePath $svgPath
