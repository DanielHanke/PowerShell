# Save chart to image
#
# basic.ps1 -Output "c:\temp\chart.png"
#
#param([String] $Output="c:\temp\chart.png")

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization




$path = "c:\temp\chart.png"

$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$points = New-Object System.Collections.Generic.List[PSCustomObject]

# Set the chart title
$chart.Titles.Add("Demo")

# Set the chart type to column
$chart.Series.Add("Series1") | Out-Null
$chart.ChartAreas.Add([System.Windows.Forms.DataVisualization.Charting.ChartArea]::new())
$chart.Series['Series1'].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn # 'StackedColumn'
$chart.Series['Series1'].LabelForeColor = [System.Drawing.Color]::White
$chart.Series['Series1'].LegendText = "Horas"
$chart.Series['Series1'].Color = [System.Drawing.Color]::Bisque
$chart.Series['Series1'].Label = "hs"
#$chart.BackGradientStyle = 2
#$chart.BackColor = [System.Drawing.Color]::AliceBlue 
#$chart.BackSecondaryColor = [System.Drawing.Color]::White 
$chart.Width = 640
$chart.Height = 480


$points.Add(@{X="Enero"; Y=0.34})
$points.Add(@{X="Febrero"; Y=0.56})

# Add data to the chart
For ($i=0; $i -lt $points.Count; $i++) {
         $chart.Series["Series1"].Points.AddXY($points[$i].X, $points[$i].Y)
}

$chart.SaveImage($path, [System.Windows.Forms.DataVisualization.Charting.ChartImageFormat]::Png) 