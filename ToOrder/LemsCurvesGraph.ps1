# Ruta del archivo
$IdTubo = 2903459
$tipo = 0

$rutaArchivo1 = $filePath = $PSScriptRoot +'\HistoricoResultadosPlano' + $IdTubo +'_DiametroTubo_' + $Tipo +'.txt'
$rutaArchivo2 = $filePath = $PSScriptRoot +'\'+ $IdTubo +'_' + $tipo +'.txt'

# Leer líneas y convertirlas a números decimales
$numeros1 = Get-Content $rutaArchivo1 #| ForEach-Object { [double]$_ }

$numeros2 = Get-Content $rutaArchivo2 #| ForEach-Object { [double]$_ }

$svg = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><polyline fill="none" stroke="blue" stroke-width="2" points="'

$index = 1
$numeros1 | ForEach-Object { 
    $y = $_
    $svg = $svg + ' ' + $index + ',' + $y.ToString()
    $index = $index + 1
}

$svg = $svg + '"/><polyline fill="none" stroke="green" stroke-width="2" points="'
$index = 1
$numeros2 | ForEach-Object { 
    $y = $_ 
    $svg = $svg + ' ' + $index + ',' + $y.ToString()
    $index = $index + 1
}

$svg = $svg + '"/></svg>'

# Ejemplo de procesamiento: calcular promedio
$promedio = ($numeros | Measure-Object -Average).Average
#Write-Host "Promedio: $promedio" -ForegroundColor Green
$ruta = $PSScriptRoot + '\DiametroInterno.svg'
Set-Content -Path $ruta -Value $svg
