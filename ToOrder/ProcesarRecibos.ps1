function Obtener-NetoACobrar {
    param (
        [string]$texto
    )

    try {
        if ($texto -match '(?s)NETO A COBRAR(.*?)FIRMA DEL EMPLEADOR') {
            $subcadena = $matches[1].Trim()
            if ($subcadena -match '\d{1,3}(?:\.\d{3})*,\d{2}') {
                return $matches[0]
            } else {
                return $null
            }
        } else {
            return $null
        }
    }
    catch {
        Write-Output "Error inesperado: $_"
        return $null
    }
}


$precioDolar = @{}

$precioDolar[2021] = @{
    9 = 98.12; 10 = 99.34; 11 = 100.56; 12 = 102.68
}

$precioDolar[2022] = @{
    1 = 103.12; 2 = 106.45; 3 = 110.78; 4 = 115.34
    5 = 120.67; 6 = 125.89; 7 = 132.45; 8 = 138.76
    9 = 145.12; 10 = 151.34; 11 = 160.45; 12 = 177.13
}

$precioDolar[2023] = @{
    1 = 178.38; 2 = 185.67; 3 = 192.45; 4 = 210.34
    5 = 235.67; 6 = 260.89; 7 = 285.34; 8 = 310.45
    9 = 345.67; 10 = 380.12; 11 = 420.45; 12 = 808.51
}

$precioDolar[2024] = @{
    1 = 810.46; 2 = 825.34; 3 = 840.12; 4 = 860.45
    5 = 880.78; 6 = 900.34; 7 = 920.56; 8 = 945.12
    9 = 980.45; 10 = 1010.34; 11 = 1020.56; 12 = 1030.99
}

$precioDolar[2025] = @{
    1 = 1031.01; 2 = 1050.34; 3 = 1080.45; 4 = 1120.78
    5 = 1160.34; 6 = 1200.56; 7 = 1240.12; 8 = 1290.45
    9 = 1355.00; 10 = 1460.00
}



# Ruta al archivo PDF
$pdfPath = "C:\Users\t61162\Downloads\Recibo 2025-05 - Normales.pdf"
$ruta = "C:\Users\t61162\Downloads"

# Obtener todos los archivos que coincidan con el patrón
$archivos = Get-ChildItem -Path $ruta -Filter "Recibo *.pdf" | Sort-Object Name

$archivoSalida =  $ruta + "\" + "salarios.csv"
Write-Output "ANIO;MES;SALARIO;PRECIO DEL DOLAR;DOLARES;DIFERENCIA;PORCENTAJE" | Out-File -Encoding UTF8 -FilePath $archivoSalida

$numeroAnterior = 0.0

foreach ($archivo in $archivos) {

    if ($archivo.Name -match 'Recibo\s(\d{4})-(\d{2})\s-\sNormales\.pdf') {
        $anio = $matches[1]
        $mes = $matches[2]

        Write-Output "Procesando archivo: $($archivo.Name)"
        Write-Output "Año: $anio, Mes: $mes"

        try {

            # Ruta al ejecutable de Poppler
            $popplerPath = "D:\Appls\poppler-25.07.0\Library\bin\pdftotext.exe"

            $pdfPath = $ruta + "\" + $archivo.Name
            # Ejecutar pdftotext con Poppler
            & $popplerPath -layout $pdfPath

        }
        catch{
            
        }


    # Leer el archivo de texto generado
    $textPath = [System.IO.Path]::ChangeExtension($pdfPath, ".txt")
    $content = Get-Content $textPath -Raw

    $numero = Obtener-NetoACobrar -texto $content
    $numero = $numero.Replace(".", "").Replace(",", ".")

    try
    {
    $x = [int]$anio
    $y = [int]$mes
    $precio = $precioDolar[$x][$y]
    $dolares = [Math]::Round([decimal]$numero / $precio,2)
    }
    catch{
        Write-Host "Error en $anio, $mes, $_.Exception.Message"
        $dolares = 0
    }
    
    if ($numeroAnterior -eq 0)
    {
        Write-Output "$anio;$mes;$numero;$precio;$dolares" | Out-File -Encoding UTF8 -FilePath $archivoSalida -Append
        
    }
    else
    {
     $diferencia = [decimal]$numero - $numeroAnterior
     $porcentaje = ( $diferencia * 100 ) / $numero
     $porcentaje = [Math]::Round($porcentaje, 1)
     Write-Output "$anio;$mes;$numero;$precio;$dolares;$diferencia;$porcentaje" | Out-File -Encoding UTF8 -FilePath $archivoSalida -Append
    }
    $numeroAnterior = $numero
    }
}