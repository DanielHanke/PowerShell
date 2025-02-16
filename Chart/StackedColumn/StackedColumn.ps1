
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

$path = $PSScriptRoot + "\StackedColumn.png"

$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$points = New-Object System.Collections.Generic.List[PSCustomObject]

$chart.Titles.Add("UN EJEMPLO BASICO") | Out-Null
$chart.Series.Add("Series1") | Out-Null
$chart.ChartAreas.Add([System.Windows.Forms.DataVisualization.Charting.ChartArea]::new()) | Out-Null
$chart.Series['Series1'].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn # 'StackedColumn'

$points.Add(@{X="Valor 1"; Y=0.34})
$points.Add(@{X="Valor 2"; Y=0.56})

For ($i=0; $i -lt $points.Count; $i++) {
    $chart.Series["Series1"].Points.AddXY($points[$i].X, $points[$i].Y) | Out-Null
}
$chart.SaveImage($path, [System.Windows.Forms.DataVisualization.Charting.ChartImageFormat]::Png) | Out-Null 