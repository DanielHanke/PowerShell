Add-Type -AssemblyName System.Windows.Forms 
Add-Type -AssemblyName System.Windows.Forms.DataVisualization


$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
#$Series2 = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
$ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]

$Series.ChartType = $ChartTypes::Line

$Chart.Series.Add($Series)
#$Chart.Series.Add($Series2)
$Chart.ChartAreas.Add($ChartArea)

      
$Chart.Series['Series1'].Points.AddXY('Obj1', 12)
$Chart.Series['Series1'].Points.AddXY('Obj2', 14)

#$Chart.Series['Series2'].Points.AddXY('Obj2', 14)


$Chart.Width = 700
$Chart.Height = 400
$Chart.Left = 10
$Chart.Top = 10
$Chart.BackColor = [System.Drawing.Color]::White
$Chart.BorderColor = 'Black'
$Chart.BorderDashStyle = 'Solid'

$ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
$ChartTitle.Text = 'Top 5 Processes by Working Set Memory'
$Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
$ChartTitle.Font =$Font
$Chart.Titles.Add($ChartTitle)

$Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
$Legend.IsEquallySpacedItems = $True
$Legend.BorderColor = 'Black'
$Chart.Legends.Add($Legend)
$chart.Series["Series1"].LegendText = "#VALX (#VALY)"



$Chart.SaveImage('D:\temp\chart.png', 'png')

