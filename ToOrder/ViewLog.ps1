$prevlines = Get-Content D:\temp\Logs\Tenaris.Lems.Manager.lemsManager\Tenaris.Lems.Manager.lemsManager.log 
while (1 -eq 1)
{
    $lines = Get-Content D:\temp\Logs\Tenaris.Lems.Manager.lemsManager\Tenaris.Lems.Manager.lemsManager.log 
    
    $differences = Compare-Object -ReferenceObject $prevlines -DifferenceObject $lines

    foreach ($line in $differences)
    {
        $HeaderFields = $line.InputObject.Split("|")

        #$logObject = [PSCustomObject]@{
        #"Header" = $HeaderFields[0]
        #"Data" = $HeaderFields[1]
        #}
        
        # Check for errors
        $date = $HeaderFields[0].SubString(1,24)
        $line = $date + " =>  " +$HeaderFields[1].Substring(3)
        if ($HeaderFields[1].Substring(1,1) -eq "@")
        {
            Write-Host $line -ForegroundColor red
        }
        else
        {
            Write-Host $line -ForegroundColor green
        }
        


    }
   $prevlines = $lines
    Start-Sleep -Seconds 1
}
