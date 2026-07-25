# Sirve la carpeta de la app en http://localhost:8080 para evitar las
# restricciones de seguridad de Chrome al abrir el archivo directo (file://).
# No necesita instalar nada: usa PowerShell, que ya viene en Windows.

$root = $PSScriptRoot
$port = 8080
$prefix = "http://localhost:$port/"

$lanIp = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
  Where-Object { $_.IPAddress -notlike '169.254*' -and $_.IPAddress -ne '127.0.0.1' -and $_.PrefixOrigin -ne 'WellKnown' } |
  Select-Object -First 1 -ExpandProperty IPAddress)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

$lanEnabled = $false
if ($lanIp) {
  $lanPrefix = "http://" + $lanIp + ":$port/"
  $listener.Prefixes.Add($lanPrefix)
  $lanEnabled = $true
}

try {
  $listener.Start()
} catch {
  if ($lanEnabled) {
    # Sin permisos para escuchar en la IP de red (hace falta ser administrador).
    # Reintentamos con un listener nuevo que solo escuche en localhost.
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($prefix)
    $listener.Start()
    $lanEnabled = $false
  } else {
    throw
  }
}

if ($lanEnabled) {
  $lanOrigin = "http://" + $lanIp + ":$port"
  Set-Content -Path (Join-Path $root "runtime-info.js") -Value "window.LAN_ORIGIN = `"$lanOrigin`";" -Encoding utf8
} else {
  Set-Content -Path (Join-Path $root "runtime-info.js") -Value "window.LAN_ORIGIN = null;" -Encoding utf8
}

Write-Host "================================================="
Write-Host " Gil Muffler - Panel interno"
Write-Host " Corriendo en $prefix"
if ($lanEnabled) {
  Write-Host " El codigo QR de las facturas va a usar: http://$lanIp`:$port/"
  Write-Host " (para que funcione desde un celular en el mismo WiFi)"
} else {
  Write-Host " Aviso: el codigo QR de las facturas solo va a funcionar en esta compu."
  Write-Host " Para que funcione desde un celular en el mismo WiFi, cierra esta ventana"
  Write-Host " y vuelve a abrir Iniciar-Gil-Muffler.bat con clic derecho > 'Ejecutar como administrador'."
}
Write-Host " No cierres esta ventana mientras uses la app."
Write-Host " Para apagarlo, cierra esta ventana."
Write-Host "================================================="

Start-Process ($prefix + "index.html")

$mimeTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".js"   = "application/javascript; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".sql"  = "text/plain; charset=utf-8"
  ".webp" = "image/webp"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".svg"  = "image/svg+xml"
  ".json" = "application/json; charset=utf-8"
  ".ico"  = "image/x-icon"
}

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $request = $context.Request
  $response = $context.Response
  try {
    $localPath = $request.Url.LocalPath.TrimStart("/")
    if ([string]::IsNullOrEmpty($localPath)) { $localPath = "index.html" }
    $filePath = Join-Path $root $localPath

    if (Test-Path $filePath -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($filePath)
      $contentType = $mimeTypes[$ext]
      if (-not $contentType) { $contentType = "application/octet-stream" }
      $bytes = [System.IO.File]::ReadAllBytes($filePath)
      $response.ContentType = $contentType
      $response.ContentLength64 = $bytes.Length
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $response.StatusCode = 404
      $notFound = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $localPath")
      $response.OutputStream.Write($notFound, 0, $notFound.Length)
    }
  } catch {
    try { $response.StatusCode = 500 } catch {}
  } finally {
    $response.OutputStream.Close()
  }
}
