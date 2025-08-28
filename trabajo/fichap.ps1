 #
 # este script, dado una hora, caulcula cuando deberia tener que fichar la salida.
 #
 param (
    [string]$hora = '08:30'
 )
 
 while( 1 -eq 1 ){
    $fecha = Get-Date

    $fechaInicio = $fecha.Year.ToString() + '-' + $fecha.Month.ToString() + '-' + $fecha.Day.ToString() + ' ' + $hora
    $fechaFin = Get-Date $fechaInicio
    $fechaFin = $fechaFin.AddHours(8)
    $fechaFin = $fechaFin.AddMinutes(30)



    $str = 'Fiche ' + $fechaFin.Hour.ToString() + ':' + $fechaFin.Minute.ToString().PadLeft(2,'0')
    $Host.UI.RawUI.WindowTitle = $str
    Write-Output $str
    Start-Sleep -Seconds 300
 }
