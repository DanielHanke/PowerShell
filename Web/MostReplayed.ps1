param (
  [string]$VideoId = "wwT9Ua6pRjE",
  [string]$InputFile = "d:\appls\video.webm",
  [string]$OutputDir = ".\clips",
  [int]$ClipDuration = 30
)

$endpoint = "https://yt.lemnoslife.com/videos?part=mostReplayed&id=$VideoId"

# Crear carpeta de salida si no existe
if (-not (Test-Path $OutputDir)) {
  New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

try {
  $response = Invoke-RestMethod -Uri $endpoint -Method Get
  $markers = $response.items[0].mostReplayed.markers

  Write-Host "🎬 Generando clips desde los segmentos más reproducidos..."

  $topMarkers = $markers | Sort-Object intensityScoreNormalized -Descending | Select-Object -First 3

  $i = 0
  foreach ($marker in $topMarkers) {
    $startSec = [math]::Round($marker.startMillis / 1000)
    $clipName = "$OutputDir\clip_$i.mp4"

    $cmd = "d:\appls\ffmpeg -y -ss $startSec -i `"$InputFile`" -t $ClipDuration -c copy `"$clipName`""
    Write-Host "▶️ Ejecutando: $cmd"
    Invoke-Expression $cmd

    $i++
  }

  Write-Host "`n✅ Clips generados en: $OutputDir"
}
catch {
  Write-Warning "❌ No se pudo obtener datos para el video $VideoId. Verificá el ID o la conexión."
}
