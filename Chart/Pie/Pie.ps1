Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

$path = $PSScriptRoot + "\PieChart.png"

$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$points = New-Object System.Collections.Generic.List[PSCustomObject]

$chart.Titles.Add("VALORES POR CUATRIMESTRE")
$chart.Titles[0].Font = "Arial, 24pt"
$chart.Titles[0].ForeColor = [System.Drawing.Color]::DeepPink

$chart.Series.Add("Series1") | Out-Null
$chart.ChartAreas.Add([System.Windows.Forms.DataVisualization.Charting.ChartArea]::new())| Out-Null
$chart.Series['Series1'].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Pie 
$chart.Series['Series1'].LabelForeColor = [System.Drawing.Color]::White
$chart.Series['Series1'].IsValueShownAsLabel = $true
$chart.Legends.Add("Series1") | Out-Null
$chart.Legends['Series1'].Enabled = $true
$chart.Width = 1024
$chart.Height = 768

$chart.ChartAreas[0].Area3DStyle.Enable3D = $true
$chart.ChartAreas[0].Area3DStyle.Inclination = 60
$chart.ChartAreas[0].Area3DStyle.LightStyle = [System.Windows.Forms.DataVisualization.Charting.LightStyle]::Realistic

$points.Add(@{X="1 cuatrimestre"; Y=76.8})
$points.Add(@{X="2 cuatrimestre"; Y=25})
$points.Add(@{X="3 cuatrimestre"; Y=5.78})

For ($i=0; $i -lt $points.Count; $i++) {
    $chart.Series["Series1"].Points.AddXY($points[$i].X, $points[$i].Y) | Out-Null
}

$chart.SaveImage($path, [System.Windows.Forms.DataVisualization.Charting.ChartImageFormat]::Png)
