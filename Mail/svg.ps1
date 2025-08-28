
function Add-Bar {
    param (
        [int]$index,
        [int]$value,
        [int]$graphHeight,
        [string]$color
    )
    $altura = $value * ($graphHeight - 100) / 100
    $posicion = ($graphHeight - 50) - $altura
    $x = $offsetX + ($deltaX*$index)
    return '<rect fill="' + $color + '" x="'+ $x +'"  y="' + $posicion + '" width="30" height="' + $altura + '"/>'
}

Function Add-Svg-Graph {
    param (
        [int[]]$values,
        [string[]]$labels
    )

    # position of 1st bar
    $offsetX = 66

    #distance between bars
    $deltaX = 42

    #graph height 
    $graphHeight = 400

    # bar colors
    #$colors = @('indianred', 'salmon', 'dodgerblue', 'tomato', 'forestgreen', 'green', 'chocolate', 'salmon', 'darkred', 'moccasin')
    $colors = @('dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue', 'dodgerblue')

    $str = '<g fill="steelblue">'

    for ($i = 0; $i -lt $values.Length; $i++) {
        $value = 10 * ( $i + 1 )
        $bar = Add-Bar -index $i -Value $values[$i] -graphHeight $graphHeight -color $colors[$i]
        $str = $str + $bar
    }

    $str = $str + '</g>'
    $svg = '<svg width="600px" height="' + $graphHeight + 'px" xmlns="http://www.w3.org/2000/svg">'
    $svg = $svg + '<line x1="50" y1="50" x2="50" y2="350" stroke="black"/><line x1="50" y1="350" x2="550" y2="350" stroke="black"/>'
      
    $svg = $svg + '<text x="20" y="355" font-size="12" text-anchor="end">0</text>'
    $svg = $svg + '<text x="20" y="295" font-size="12" text-anchor="end">20</text>'
    $svg = $svg + '<text x="20" y="235" font-size="12" text-anchor="end">40</text>'
    $svg = $svg + '<text x="20" y="175" font-size="12" text-anchor="end">60</text>'
    $svg = $svg + '<text x="20" y="115" font-size="12" text-anchor="end">80</text>'
    $svg = $svg + '<text x="20" y="55" font-size="12" text-anchor="end">100</text>'

    $svg = $svg + $str

    $svg = $svg + '<g font-size="12" text-anchor="middle">'
    for ($i = 0; $i -lt $values.Length; $i++) {
        if ($values[$i] -gt 0){
        $svg = $svg + '<text x="' + ($offsetX + (30 / 2) + ($i*$deltaX)).ToString() + '"  y="370">' + $i.ToString() + '</text>'
        }
    }

    for ($i = 0; $i -lt $values.Length; $i++) {
        if ($values[$i] -gt 0){
            #$svg = $svg + '<text text-anchor="start" fill="' + $colors[$i] + '" x="500" y="' + (50 + 15 * ($i+1)).ToString() + '">' + $i.ToString() + ' = ' + $labels[$i].ToString() + '</text>'
            $svg = $svg + '<text text-anchor="start" fill="black" x="500" y="' + (50 + 15 * ($i+1)).ToString() + '">' + $i.ToString() + ' = ' + $labels[$i].ToString() + '</text>'
        }
    }

    $svg = $svg + '</g>'
    $svg = $svg + '</svg>'
    return $svg
}


# Valores
$values = @(10, 89, 30, 50, 50, 50, 50, 50, 50, 50)

#leyendas
$labels = @('ASME', 'AFIP', 'ARCA', 'ARGON', 'SECHS', 'MIKE', 'SOCK', 'PAMP', 'MUKE', 'OIL')


#
# Agregar el graph 
#
$svg = Add-Svg-Graph -values $values -labels $labels

# Guardar SVG temporalmente, invocar a InkScape y convertirlo a base64
$tempSvgPath = "$env:TEMP\temp_image.svg"
$tempPngPath = "$env:TEMP\temp_image.png"
[System.IO.File]::WriteAllText($tempSvgPath, $svg)
& "C:\Program Files\Inkscape\bin\inkscape" $tempSvgPath --export-type=png --export-filename=$tempPngPath
$bytes = [System.IO.File]::ReadAllBytes($tempPngPath)
$base64 = [Convert]::ToBase64String($bytes)


# Crear HTML con imagen embebida
$htmlBody = @"
<html>
  <body>
    <h2>Imagen PNG convertida desde SVG</h2>
    <img src='data:image/png;base64,$base64' />
    <p>Esta imagen fue generada a partir de un SVG.</p>
  </body>
</html>
"@

# Crear y mostrar el correo
$outlook = New-Object -ComObject Outlook.Application
$mail = $outlook.CreateItem(0)
$mail.To = "destinatario@ejemplo.com"
$mail.Subject = "Correo con imagen PNG desde SVG"
$mail.HTMLBody = $htmlBody
$mail.Display()
