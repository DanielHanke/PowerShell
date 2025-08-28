
 # bajar los datos de todas las roscas

$cnString = "Integrated Security=SSPI;Persist Security Info=False;User ID=patronesadm;Initial Catalog=DbLc1fTeliPmc2;Data Source=HCC00564.apre.siderca.ot"

Function ReadExtremos()
{
    param (
        [string]$idparent
    )
   # Por cada Modelo, leer el extremo
    $cnExtremo = New-Object System.Data.SqlClient.SqlConnection
    $cnExtremo.ConnectionString = $cnString
    $cnExtremo.Open()

    $cmdExtremo = $cnExtremo.CreateCommand()
    $sExtremo = "SELECT * FROM NodoArbol where IDParent = " + $idParent.ToString()
    $cmdExtremo.CommandText = $sExtremo

    $drExtremo = $cmdExtremo.ExecuteReader()
    while ($drExtremo.Read()) {
        $str = "," + $drExtremo["Descripcion"].ToString() + "," + "," + ","
        Write-Output $str

        ReadDiametros $drExtremo["idNodo"].ToString() 
        }
    $drExtremo.Close()
    $cnExtremo.Close()

}

Function ReadDiametros()
{
    param (
        [string]$idparent
    )
   # Por cada Modelo, leer el extremo
    $cnDiametro = New-Object System.Data.SqlClient.SqlConnection
    $cnDiametro.ConnectionString = $cnString
    $cnDiametro.Open()

    $cmdDiametro = $cnDiametro.CreateCommand()
    $sDiametro = "SELECT * FROM NodoArbol where IDParent = " + $idParent.ToString()
    $cmdDiametro.CommandText = $sDiametro

    $drDiametro = $cmdDiametro.ExecuteReader()
    while ($drDiametro.Read()) {
        $str =  "," + "," + $drDiametro["Descripcion"].ToString() + "," + ","
        Write-Output $str
        ReadEspesors $drDiametro["idNodo"].ToString() 
        }
    $drDiametro.Close()
    $cnDiametro.Close()

}

Function ReadEspesors()
{
    param (
        [string]$idparent
    )
   # Por cada Modelo, leer el extremo
    $cnEspesor = New-Object System.Data.SqlClient.SqlConnection
    $cnEspesor.ConnectionString = $cnString
    $cnEspesor.Open()

    $cmdEspesor = $cnEspesor.CreateCommand()
    $sEspesor = "SELECT * FROM NodoArbol where IDParent = " + $idParent.ToString()
    $cmdEspesor.CommandText = $sEspesor

    $drEspesor = $cmdEspesor.ExecuteReader()
    while ($drEspesor.Read()) {
        $str = "," + "," + "," + $drEspesor["Descripcion"].ToString() + ","
        Write-Output $str
        ReadPresets $drEspesor["IdNodo"].ToString()
        }
    $drEspesor.Close()
    $cnEspesor.Close()

}

Function ReadFase()
{
    param (
        [string]$idPreset,
        [string]$idNodo,
        [string]$TipoDato
    )
    $cnFase = New-Object System.Data.SqlClient.SqlConnection
    $cnFase.ConnectionString = $cnString
    $cnFase.Open()

    $cmdFase = $cnFase.CreateCommand()
    $sFase = "Select * from ValorPreset vp join Valor v on v.IdValor = vp.Idvalor where vp.IdPreset = " + $idPreset + " and vp.IdDato = " + $TipoDato + " and vp.IdNodo = " + $idNodo
    $cmdFase.CommandText = $sFase

    $drFase = $cmdFase.ExecuteReader()
    while ($drFase.Read()) {
        $str = "," + "," + "," + "Fase: " + $drFase["VInteger"].ToString()
        Write-Output $str
        }
    $drFase.Close()
    $cnFase.Close()

}

Function ReadFrecuencia()
{
    param (
        [string]$idPreset,
        [string]$idNodo,
        [string]$TipoDato
    )
    $cnFrecuencia = New-Object System.Data.SqlClient.SqlConnection
    $cnFrecuencia.ConnectionString = $cnString
    $cnFrecuencia.Open()

    $cmdFrecuencia = $cnFrecuencia.CreateCommand()
    $sFrecuencia = "Select * from ValorPreset vp join Valor v on v.IdValor = vp.Idvalor where vp.IdPreset = " + $idPreset + " and vp.IdDato = " + $TipoDato + " and vp.IdNodo = " + $idNodo
    $cmdFrecuencia.CommandText = $sFrecuencia

    $drFrecuencia = $cmdFrecuencia.ExecuteReader()
    while ($drFrecuencia.Read()) {
        $str = "," + "," + "," + "Frecuencia: " + $drFrecuencia["VInteger"].ToString()
        Write-Output $str
        }
    $drFrecuencia.Close()
    $cnFrecuencia.Close()

}

Function ReadPresets()
{
    param (
        [string]$idparent
    )
   # Por cada Modelo, leer el extremo
    $cnPreset = New-Object System.Data.SqlClient.SqlConnection
    $cnPreset.ConnectionString = $cnString
    $cnPreset.Open()

    $cmdPreset = $cnPreset.CreateCommand()
    $sPreset = "Select p.Descripcion as Nombre,vp.IdPreset as IdPreset, vp.IdNodo as IdNodo, * from ValorPreset vp join Presets p on p.IdPreset = vp.IdPreset where IdNodo = " + $idParent.ToString() + "and vp.IdDato = 600"
    $cmdPreset.CommandText = $sPreset

    $drPreset = $cmdPreset.ExecuteReader()
    while ($drPreset.Read()) {
        $str = "," + "," + "," + "," + $drPreset["Descripcion"].ToString()
        Write-Output $str
        ReadFase -idPreset $drPreset["idPreset"].ToString() -idNodo $drPreset["IdNodo"].ToString() -TipoDato 601
        ReadFrecuencia -idPreset $drPreset["idPreset"].ToString() -idNodo $drPreset["IdNodo"].ToString() -TipoDato 602
        }
    $drPreset.Close()
    $cnPreset.Close()

}


$sqlModelos = "Select * from NodoArbol where IdParent = 301000 and Descripcion like '%Modelo%'"

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $cnString
$connection.Open()

# Ejecutar la consulta
$cmdModelo = $connection.CreateCommand()
$cmdModelo.CommandText = $sqlModelos
$drModelo = $cmdModelo.ExecuteReader()

Write-Output "Los modelos son:"

while ($drModelo.Read()) {
    
    $str = $drModelo["Descripcion"].ToString() + "," + "," + "," + ","
    Write-Output $str

    ReadExtremos $drModelo["idNodo"].ToString()
 
    }

# Cerrar el DataReader y la conexión
$drModelo.Close()

$connection.Close()
