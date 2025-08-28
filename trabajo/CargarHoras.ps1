 param (
    [string]$fecha = '2025-03-12',
    [string]$centroCosto = 'ZAPRE2578.23',
    [string]$DetalleTarea = 'Manager Ikom Pruebas de funcionamiento',
    [double] $horas = 0
 )
 
# centros de costo:
#  PATRONES     ZAPRE0295.23
#  LEMS         ZAPRE2770.23
#  HORAS        ZAPRE1640.23
#  CHINA        ZAPRE2817.23
#  VIRTUAOLIZ   ZAPRE2791.23
#  FERIADO      ZAPRE0023.23
#
# Ejemplo
# C:\dev\PowerShell\trabajo\CargarHoras.ps1 -fecha "2025-06-14" -centroCosto "ZAPRE2770.23" -horas 8.5 -DetalleTarea "Stored procedure para historicos" 
#


# Configuración de la conexión a SQL Server
$serverName = "10.200.120.59"
$databaseName = "GestionApreDB"

#$fecha = '2025-03-12'

$IdTipoMedicion = 1

#$tableName = "HistoricoResultadosPlano"
#$columnName = "DiametroInterno"

# Cadena de conexión
$connectionString = "Server=$serverName;Database=$databaseName;User Id=admin;password=apre"
<#
.SYNOPSIS
    This script add a day in CargaHoras software

.DESCRIPTION
    

.AUTHOR
    Daniel E. Hanke - TREND

.COMPANYNAME
    Trend - GEIN / APRE

.CREATED
    23/07/2025

.LASTUPDATED
    23/07/2025

.VERSION
    1.0

.PARAMETER
    fecha: Date to add the record
    CentroCosto: This is where impute the hours
    DetalleTarea: This a comment to describe the work
    Hours: This is the quantity imputed

.EXAMPLE
    Example to execute this script:
    PS> C:\dev\PowerShell\trabajo\CargarHoras.ps1 -fecha "2025-07-18" -centroCosto "ZAPRE2770.23" -DetalleTarea "Deploy de manager en ambiente DEV" -horas 8.5

#>
# Consulta SQL para obtener los datos del campo
$query = "INSERT INTO [dbo].[ContratadosDetalleDeHoras]" +
         "([Registro],[Fecha],[Codigo_de_tarea],[Descripcion],[Cantidad_de_horas],[Codigo_de_proveedor],[IdProveedor],[IdContratado],[TipoHora],[Aprobacion],[Motivo],[Categoria],[idSession],[TipoHoraEx],[Observacion],[FechaHoraRegistro])" +
         "VALUES ('T61162'" +
         "," +
         "'" +
         $Fecha +
         "'" +
         "," +
         "'" +
         $CentroCosto +
         "'" +
         "," +
         "'" +
         $DetalleTarea +
         "'" +
         ","+ [Math]::Round($horas,1).ToString() + ",'P4A',100050,100432,'N','N',0,'126',null,null,null,null)"



# Crear y abrir la conexión a SQL Server
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# Ejecutar la consulta
$command = $connection.CreateCommand()
$command.CommandText = $query
$command.ExecuteNonQuery()

# Cerrar la conexión
#$reader.Close()
$connection.Close()
