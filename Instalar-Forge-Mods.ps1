# INSTALADOR AUTOMÁTICO DE MODS PARA MINECRAFT
# Repositorio: https://github.com/LuisPuroRush/Minecraft

# Configuración
$UsuarioGitHub = "LuisPuroRush"
$NombreRepo    = "Minecraft"
$CarpetaModsGitHub = "mods"

# Ruta local de Minecraft
$RutaModsLocal = "$env:APPDATA\.minecraft\mods"

# =========================================
Clear-Host
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "   DESCARGAR MODS DE MINECRAFT 1.20.1" -ForegroundColor Cyan
Write-Host "          - PanqueLovers.aternos.me" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Menú
Write-Host "   1. DESCARGAR E INSTALAR MODS AUTOMATICAMENTE" -ForegroundColor Yellow
Write-Host "   2. SALIR" -ForegroundColor Yellow
Write-Host ""
$opcion = Read-Host "   Selecciona una opcion (1 o 2)"

if ($opcion -ne "1") { exit }

Write-Host ""
Write-Host "[1/4] Preparando carpeta de Minecraft..." -ForegroundColor Yellow
if (-not (Test-Path $RutaModsLocal)) {
    New-Item -ItemType Directory -Path $RutaModsLocal -Force | Out-Null
    Write-Host "   Carpeta creada: $RutaModsLocal" -ForegroundColor Green
}

Write-Host "[2/4] Conectando con GitHub..." -ForegroundColor Yellow
$UrlApi = "https://api.github.com/repos/$UsuarioGitHub/$NombreRepo/contents/$CarpetaModsGitHub"

try {
    $ContenidoCarpeta = Invoke-RestMethod -Uri $UrlApi -UseBasicParsing
} catch {
    Write-Host "   ERROR: No se pudo acceder a la carpeta 'mods'." -ForegroundColor Red
    Write-Host "   Asegurate de que existe una carpeta llamada 'mods' en tu GitHub." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit
}

$Mods = $ContenidoCarpeta | Where-Object { $_.type -eq "file" -and $_.name -like "*.jar" }
$TotalMods = $Mods.Count
Write-Host "   Encontrados $TotalMods mod(s)." -ForegroundColor Green

Write-Host "[3/4] Descargando mods..." -ForegroundColor Yellow
$Contador = 0
foreach ($Mod in $Mods) {
    $Contador++
    $Porcentaje = [math]::Round(($Contador / $TotalMods) * 100)
    $NombreArchivo = $Mod.name
    $RutaDestino = Join-Path $RutaModsLocal $NombreArchivo
    
    Write-Progress -Activity "Descargando mods..." -Status "$NombreArchivo" -PercentComplete $Porcentaje -CurrentOperation "Mod $Contador de $TotalMods"
    
    Invoke-WebRequest -Uri $Mod.download_url -OutFile $RutaDestino -UseBasicParsing
    Write-Host "    [$Contador/$TotalMods] $NombreArchivo" -ForegroundColor Gray
}
Write-Progress -Activity "Descargando mods..." -Completed

Write-Host "[4/4] Finalizando..." -ForegroundColor Yellow
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "   ¡DESCARGA COMPLETADA!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "   Mods instalados: $TotalMods" -ForegroundColor White
Write-Host "   Ubicacion: $RutaModsLocal" -ForegroundColor White
Write-Host ""
Write-Host "   Abre Minecraft y ¡a jugar!" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
pause