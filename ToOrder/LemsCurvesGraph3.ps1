# Ruta del archivo
$IdTubo = 2903459
$tipo = 1

$rutaArchivo1 = $filePath = $PSScriptRoot +'\HistoricoResultadosPlano' + $IdTubo +'_DiametroTubo_' + $Tipo +'.txt'
$signal1 = Get-Content $rutaArchivo1 #| ForEach-Object { [double]$_ }
$rutaArchivo2 = $filePath = $PSScriptRoot +'\'+ $IdTubo +'_' + $tipo +'.txt'
$signal2 = Get-Content $rutaArchivo2 #| ForEach-Object { [double]$_ }


# Calcular la media
$mean1 = ($signal1 | Measure-Object -Average).Average
$mean2 = ($signal2 | Measure-Object -Average).Average

$amplificationFactor = 1e7

# Amplificar la señal centrada en la media

$amplified1 = $signal1 | ForEach-Object { ($_ - $mean1) * $amplificationFactor }
$amplified2 = $signal2 | ForEach-Object { ($_ - $mean2) * $amplificationFactor }


$combined = $amplified1 + $amplified2


# Calcular mínimo y máximo
$min = ($combined | Measure-Object -Minimum).Minimum
$max = ($combined | Measure-Object -Maximum).Maximum
Write-Output $min
Write-Output $max

# Calcular mínimo y máximo
#$min2 = ($amplified2 | Measure-Object -Minimum).Minimum - 0.01
#$max2 = ($amplified2 | Measure-Object -Maximum).Maximum + 0.01
#Write-Output $min2
#Write-Output $max2

# Normalizar la señal al rango de 0 a 500
$normalized1 = $amplified1 | ForEach-Object { ($_ - $min) / ($max - $min) * 500 }

# Normalizar la señal al rango de 0 a 500
$normalized2 = $amplified2 | ForEach-Object { ($_ - $min) / ($max - $min) * 500 }


# Parámetros del SVG
$svgWidth = 500
$svgHeight = 500
$step1 = $svgWidth / ($normalized1.Count - 1)
$step2 = $svgWidth / ($normalized2.Count - 1)

# Generar puntos para la polyline
$points1 = for ($i = 0; $i -lt $normalized1.Count; $i++) {
    $x1 = [math]::Round($i * $step1, 2)
    $y1 = [math]::Round($svgHeight - $normalized1[$i], 2)
    "$x1,$y1"
}

# Generar puntos para la polyline
$points2 = for ($i = 0; $i -lt $normalized2.Count; $i++) {
    $x2 = [math]::Round($i * $step2, 2)
    $y2 = [math]::Round($svgHeight - $normalized2[$i], 2)
    "$x2,$y2"
}

# Generar puntos para la polyline
$points3 = for ($i = 0; $i -lt $normalized2.Count; $i++) {
    $x3 = [math]::Round($i * $step2, 2)
    $y3 = [math]::Round($svgHeight - ($normalized2[$i] - $normalized1[$i]), 2)
    Write-Host $y3
    "$x3,$y3"
}

$polylinePoints1 = $points1 -join " "
$polylinePoints2 = $points2 -join " "
$polylinePoints3 = $points3 -join " "

# Crear contenido SVG
#$svgContent = @"
#<svg width="$svgWidth" height="$svgHeight" xmlns="http://www.w3.org/2000/svg">
#  <polyline points="$polylinePoints1" fill="none" stroke="blue" stroke-width="1"/>
#  <polyline points="$polylinePoints2" fill="none" stroke="green" stroke-width="1"/>
#</svg>
#"@

$svgContent = @"
<svg width="$svgWidth" height="$svgHeight" xmlns="http://www.w3.org/2000/svg">
  <polyline points="$polylinePoints3" fill="none" stroke="blue" stroke-width="1"/>
</svg>
"@


# Guardar el archivo
$svgContent | Out-File -Encoding UTF8 -FilePath "signal_plot.svg"

Write-Host "SVG generado y guardado como 'signal_plot.svg'"