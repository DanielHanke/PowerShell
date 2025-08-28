# Ruta del archivo
$IdTubo = 2903459
$tipo = 1

$rutaArchivo1 = $filePath = $PSScriptRoot +'\HistoricoResultadosPlano' + $IdTubo +'_DiametroTubo_' + $Tipo +'.txt'
$signal1 = Get-Content $rutaArchivo1 #| ForEach-Object { [double]$_ }
$rutaArchivo2 = $filePath = $PSScriptRoot +'\'+ $IdTubo +'_' + $tipo +'.txt'
$signal2 = Get-Content $rutaArchivo2 #| ForEach-Object { [double]$_ }


$min1 = [float]1000000
$max1 = 0.00
Write-Host $signal1.Count
for ($i = 0; $i -lt $signal1.Count; $i++) {
    if ( [float]($signal1[$i]) -lt $min1 ){
       $min1 = [math]::Round($signal1[$i],6)
    }
    if ( [float]($signal1[$i]) -gt $max1 ){
       $max1 = [math]::Round($signal1[$i],6)
    }
}

$min2 = [float]1000000
$max2 = 0.00
Write-Host $signal2.Count
for ($i = 0; $i -lt $signal2.Count; $i++) {
    if ( [float]($signal2[$i]) -lt $min2 ){
       $min2 = [math]::Round($signal2[$i],6)
    }
    if ( [float]($signal2[$i]) -gt $max2 ){
       $max2 = [math]::Round($signal2[$i],6)
    }
}


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
$svgWidth = 800
$svgHeight = 700
$chartHeight = 550
$step1 = $svgWidth / ($normalized1.Count - 1)
$step2 = $svgWidth / ($normalized2.Count - 1)

$OffsetX = 20

# Generar puntos para la polyline
$points1 = for ($i = 0; $i -lt $normalized1.Count; $i++) {
    $x1 = [math]::Round($i * $step1, 2) + $OffsetX
    $y1 = [math]::Round($chartHeight - $normalized1[$i], 2) + 50
    "$x1,$y1"
}

# Generar puntos para la polyline
$points2 = for ($i = 0; $i -lt $normalized2.Count; $i++) {
    $x2 = [math]::Round($i * $step2, 2) + $OffsetX
    $y2 = [math]::Round($chartHeight - $normalized2[$i], 2) + 50
    "$x2,$y2"
}

$polylinePoints1 = $points1 -join " "
$polylinePoints2 = $points2 -join " "


$difMin =  [math]::Round($min2 - $min1,4)
$difMax =  [math]::Round($max2 - $max1,4)

# Crear contenido SVG
$svgContent = @"
<svg width="$svgWidth" height="$svgHeight" xmlns="http://www.w3.org/2000/svg">

    <style> 
        .box {fill:#0000aa;fill-rule:evenodd;stroke:#FFFFFF;stroke-width:0.600001;stroke-linejoin:round;stroke-miterlimit:0;stroke-opacity:0.82735;paint-order:stroke fill markers;stop-color:#000000} 
        .text {font-size:16px;font-family:Arial;-inkscape-font-specification:'Arial, Normal';text-align:left;fill:#CECECE;fill-rule:evenodd;stroke:#0000FF;stroke-width:0.600001;stroke-linejoin:round;stroke-miterlimit:0;stroke-opacity:0.82735;paint-order:stroke fill markers;stop-color:#000000}
        .axis { stroke: green; stroke-width: 1; } 
        .point { fill: red; r: 1; } 
    </style>


  <line x1="15" y1="100" x2="15" y2="650" stroke="black" stroke-width="2" />  
  <polygon points="10,105 15,100 20,105" fill="black" />     <!-- Flecha eje Y -->
  <line x1="5" y1="630" x2="750" y2="630" stroke="black" stroke-width="2" />
  <polygon points="745,625 750,630 745,635" fill="black" /> <!-- Flecha eje X -->
  
  <text x="2" y="150" font-size="14" fill="black">Y</text>
  <text x="675" y="645" font-size="14" fill="black">X</text>



    <rect class="box" id="r1" width="650" height="60" x="10" y="10" ry="5.0" />

    <rect class="box" id="r2" width="80" height="20" x="15" y="30" ry="3" />
    <text xml:space="preserve" class="text" x="25" y="45" id="t1">DELPHI</text>
    
    <rect class="box" id="r3" width="100" height="20" x="100" y="15" ry="3" />
    <text xml:space="preserve" class="text" x="100" y="30" id="t2">$min1</text>

    <rect class="box" id="r4" width="100" height="20" x="100" y="45" ry="3" />
    <text xml:space="preserve" class="text" x="100" y="60" id="text236">$max1</text>

    <rect class="box" id="rect454-2" width="80" height="20" x="215" y="30" ry="3" />
    <text xml:space="preserve" class="text" x="225" y="45" id="text236">AUS</text>
    
    <rect class="box" id="rect454-2-5" width="100" height="20" x="300" y="15" ry="3" />
    <text xml:space="preserve" class="text" x="300" y="30" id="text236">$min2</text>

    <rect class="box" id="rect454-2-5-5" width="100" height="20" x="300" y="45" ry="3" />
    <text xml:space="preserve" class="text" x="300" y="60" id="text236">$max2</text>
    

    <rect class="box" id="rect454-2" width="80" height="20" x="415" y="30" ry="3" />
    <text xml:space="preserve" class="text" x="425" y="45" id="text236">DIF</text>
    
    <rect class="box" id="rect454-2-5" width="100" height="20" x="500" y="15" ry="3" />
    <text xml:space="preserve" class="text" x="500" y="30" id="text236">$difMin</text>

    <rect class="box" id="rect454-2-5-5" width="100" height="20" x="500" y="45" ry="3" />
    <text xml:space="preserve" class="text" x="500" y="60" id="text236">$difMax</text>


    

  <polyline points="$polylinePoints1" fill="none" stroke="blue" stroke-width="1"/>
  <polyline points="$polylinePoints2" fill="none" stroke="green" stroke-width="1"/>
</svg>
"@


# Guardar el archivo
$svgPath = $PSScriptRoot + '\signal_plot.svg'
$svgContent | Out-File -Encoding UTF8 -FilePath $svgPath

Write-Host "SVG generado y guardado como 'signal_plot.svg'"