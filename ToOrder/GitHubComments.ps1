# poner el usuario como parametro
# poner un rango de fechas
#hacerlo full html
$user = "DanielHanke"

$comments = get-content -raw -Path "D:\temp\comments.json" | ConvertFrom-Json 

foreach($comment in $comments) 
{
    if ($comment.user.login -eq $user)
    {
        #Write-Host $comment.user.login
        
        Write-Host ([DateTime]($comment.created_at))
        Write-Host $comment.issue_url
        $line = '<i>' + $comment.body + '</i>'
        Write-Host $line
        Write-Host "<hr>"
    }


}


