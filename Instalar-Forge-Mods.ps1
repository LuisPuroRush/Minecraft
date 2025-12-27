# =====================================================================
# INSTALADOR DE MODS DE MINECRAFT 1.20.1 - PanqueLovers.aternos.me
# =====================================================================

# ---------- CONFIGURACIÓN (EDITA ESTO CON TUS DATOS) ----------
$UsuarioGitHub = "luispurorush"    # <-- Tu usuario de GitHub (YA ESTÁ BIEN)
$NombreRepo = "Minecraft"          # <-- El nombre de tu repositorio (YA ESTÁ BIEN)

# Ruta donde se guardarán los mods (NO CAMBIAR A MENOS QUE SEPAS)
$RutaMods = "$env:APPDATA\.minecraft\mods"
# ---------------------------------------------------------------

# Función para mostrar título y menú
function Mostrar-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "    Descargar Mods de Minecraft 1.20.1 - PanqueLovers.aternos.me    " -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "         1. DESCARGAR E INSTALAR MODS AUTOMÁTICAMENTE" -ForegroundColor Yellow
    Write-Host "         2. SALIR" -ForegroundColor Yellow
    Write-Host ""
}

# Función principal para descargar mods
function Descargar-Mods {
    Write-Host "`n[+] Preparando para descargar mods..." -ForegroundColor Green

    # Verificar y crear carpeta de mods si no existe
    if (-not (Test-Path $RutaMods)) {
        New-Item -ItemType Directory -Path $RutaMods -Force | Out-Null
        Write-Host "   Carpeta de mods creada en: $RutaMods" -ForegroundColor Green
    } else {
        Write-Host "   Carpeta de mods ya existe." -ForegroundColor Green
    }

    # Obtener lista de archivos desde la API de GitHub
    $urlApi = "https://api.github.com/repos/$UsuarioGitHub/$NombreRepo/contents/mods"
    
    try {
        Write-Host "`n[+] Conectando con GitHub..." -ForegroundColor Green
        $respuesta = Invoke-RestMethod -Uri $urlApi -UseBasicParsing
        Write-Host "   Conexión exitosa." -ForegroundColor Green
        
        # Filtrar solo archivos .jar
        $archivosJar = $respuesta | Where-Object { $_.type -eq "file" -and $_.name -match '\.jar$' }
        $totalMods = $archivosJar.Count
        
        if ($totalMods -eq 0) {
            Write-Host "`n[!] No se encontraron archivos .jar en la carpeta 'mods'." -ForegroundColor Red
            Write-Host "    Asegúrate de que tus mods estén en la carpeta 'mods' de tu repositorio." -ForegroundColor Yellow
            return
        }

        Write-Host "`n[+] Encontrados $totalMods mod(s) para descargar." -ForegroundColor Green
        Write-Host "    Iniciando descarga..." -ForegroundColor Green
        
        $contador = 0
        
        # Descargar cada archivo .jar
        foreach ($archivo in $archivosJar) {
            $contador++
            $porcentaje = [math]::Round(($contador / $totalMods) * 100)
            $nombreArchivo = $archivo.name
            $rutaDestino = Join-Path $RutaMods $nombreArchivo
            
            # Mostrar barra de progreso
            Write-Progress -Activity "Descargando mods..." -Status "$nombreArchivo" -PercentComplete $porcentaje -CurrentOperation "Mod $contador de $totalMods"
            
            # Descargar el archivo
            Invoke-WebRequest -Uri $archivo.download_url -OutFile $rutaDestino -UseBasicParsing -ErrorAction SilentlyContinue
            
            Write-Host "    [$contador/$totalMods] Descargado: $nombreArchivo" -ForegroundColor Gray
        }
        
        Write-Progress -Activity "Descargando mods..." -Completed
        Write-Host "`n========================================================" -ForegroundColor Green
        Write-Host "¡DESCARGA COMPLETADA!" -ForegroundColor Green
        Write-Host "$totalMods mod(s) instalados en:" -ForegroundColor Green
        Write-Host "$RutaMods" -ForegroundColor Green
        Write-Host "========================================================" -ForegroundColor Green
        
    } catch {
        Write-Host "`n[!] ERROR: No se pudieron descargar los mods." -ForegroundColor Red
        Write-Host "    Detalles: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "`nVerifica que:" -ForegroundColor Yellow
        Write-Host "    1. Tu usuario y repositorio sean correctos." -ForegroundColor Yellow
        Write-Host "    2. Exista la carpeta 'mods' en tu repositorio." -ForegroundColor Yellow
        Write-Host "    3. Los archivos .jar estén dentro de esa carpeta." -ForegroundColor Yellow
    }
}

# ---------- INICIO DEL PROGRAMA ----------
Mostrar-Menu
$opcion = Read-Host "`nSelecciona una opción (1 o 2)"

while ($opcion -ne "2") {
    switch ($opcion) {
        "1" {
            Descargar-Mods
            Write-Host "`nPulsa cualquier tecla para volver al menú..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Mostrar-Menu
        }
        default {
            Write-Host "Opción no válida. Inténtalo de nuevo." -ForegroundColor Red
        }
    }
    $opcion = Read-Host "`nSelecciona una opción (1 o 2)"
}

Write-Host "`n¡Gracias por usar el instalador!" -ForegroundColor Cyan