Import-Module SQLPS -DisableNameChecking

$SQLInstanceName = "TNSX00000339\DEV"
$SourceDBName   = "FCI"

$Server  = New-Object -TypeName 'Microsoft.SqlServer.Management.Smo.Server' -ArgumentList $SQLInstanceName
$SourceDB = $Server.Databases[$SourceDBName]
