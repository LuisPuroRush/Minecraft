# INSTALADOR AUTOMÁTICO DE MODS Y FORGE PARA MINECRAFT
# Repositorio: https://github.com/LuisPuroRush/Minecraft
# Creado por :v Panquesito - TikTok: a.panquesito

# Configuración
$UsuarioGitHub = "LuisPuroRush"
$NombreRepo    = "Minecraft"

# Rutas locales
$RutaModsLocal = "$env:APPDATA\.minecraft\mods"
$RutaForgeDescarga = "$env:USERPROFILE\Downloads\forge-installer.jar"

# =========================================
Clear-Host
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "   DESCARGAR MODS DE MINECRAFT 1.20.1" -ForegroundColor Cyan
Write-Host "          - PanqueLovers.aternos.me" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Descripción
Write-Host "   Esto fue creado por yo :v Panquesito" -ForegroundColor Yellow
Write-Host "   TikTok: a.panquesito" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Para ingresar al servidor deben descargar los mods." -ForegroundColor White
Write-Host "   En el caso de TLauncher NO instalen Forge porque ya" -ForegroundColor White
Write-Host "   esta incluido. Solo seleccionen 'Forge 1.20.1' y listo." -ForegroundColor White
Write-Host "   En cambio Premium debe instalar Forge mediante aqui." -ForegroundColor White
Write-Host ""
Write-Host "   IP DEL SERVIDOR: PanqueLovers.aternos.me" -ForegroundColor Green
Write-Host ""

# Menú
Write-Host "   1. DESCARGAR E INSTALAR MODS AUTOMATICAMENTE" -ForegroundColor Yellow
Write-Host "   2. DESCARGAR FORGE 1.20.1 MINECRAFT (SOLO PREMIUM)" -ForegroundColor Magenta
Write-Host "   3. SALIR" -ForegroundColor Yellow
Write-Host ""
$opcion = Read-Host "   Selecciona una opcion (1, 2 o 3)"

# =========================================
# FUNCIÓN PARA DESCARGAR MODS
# =========================================
function Descargar-Mods {
    Write-Host ""
    Write-Host "[1/4] Preparando carpeta de Minecraft..." -ForegroundColor Yellow
    if (-not (Test-Path $RutaModsLocal)) {
        New-Item -ItemType Directory -Path $RutaModsLocal -Force | Out-Null
        Write-Host "   Carpeta creada: $RutaModsLocal" -ForegroundColor Green
    }

    Write-Host "[2/4] Conectando con GitHub..." -ForegroundColor Yellow
    $UrlApi = "https://api.github.com/repos/$UsuarioGitHub/$NombreRepo/contents/mods"

    try {
        $ContenidoCarpeta = Invoke-RestMethod -Uri $UrlApi -UseBasicParsing
    } catch {
        Write-Host "   ERROR: No se pudo acceder a la carpeta 'mods'." -ForegroundColor Red
        Write-Host "   Asegurate de que existe una carpeta 'mods' en tu GitHub." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   Presiona cualquier tecla para salir..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }

    $Mods = $ContenidoCarpeta | Where-Object { $_.type -eq "file" -and $_.name -like "*.jar" }
    $TotalMods = $Mods.Count
    
    if ($TotalMods -eq 0) {
        Write-Host "   No se encontraron mods en la carpeta." -ForegroundColor Red
        Write-Host "   Presiona cualquier tecla para salir..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
    
    Write-Host "   Encontrados $TotalMods mod(s)." -ForegroundColor Green

    Write-Host "[3/4] Descargando mods..." -ForegroundColor Yellow
    $Contador = 0
    $Descargados = @()
    $Fallidos = @()

    foreach ($Mod in $Mods) {
        $Contador++
        $Porcentaje = [math]::Round(($Contador / $TotalMods) * 100)
        $NombreArchivo = $Mod.name
        $RutaDestino = Join-Path $RutaModsLocal $NombreArchivo
        
        Write-Progress -Activity "Descargando mods..." -Status "$NombreArchivo" -PercentComplete $Porcentaje -CurrentOperation "Mod $Contador de $TotalMods"
        
        # Método robusto de descarga
        try {
            Invoke-WebRequest -Uri $Mod.download_url -OutFile $RutaDestino -UseBasicParsing -ErrorAction Stop
            $Descargados += $NombreArchivo
            Write-Host "    [$Contador/$TotalMods] ✓ $NombreArchivo" -ForegroundColor Green
        } catch {
            try {
                $WebClient = New-Object System.Net.WebClient
                $WebClient.DownloadFile($Mod.download_url, $RutaDestino)
                $Descargados += $NombreArchivo
                Write-Host "    [$Contador/$TotalMods] ✓ $NombreArchivo (método alternativo)" -ForegroundColor Green
            } catch {
                $Fallidos += $NombreArchivo
                Write-Host "    [$Contador/$TotalMods] ✗ Error con: $NombreArchivo" -ForegroundColor Red
            }
        }
    }
    Write-Progress -Activity "Descargando mods..." -Completed

    Write-Host "[4/4] Finalizando..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host "   ¡DESCARGA DE MODS COMPLETADA!" -ForegroundColor Green
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host "   Mods instalados: $($Descargados.Count)/$TotalMods" -ForegroundColor White
    Write-Host "   Ubicacion: $RutaModsLocal" -ForegroundColor White

    if ($Fallidos.Count -gt 0) {
        Write-Host ""
        Write-Host "   ⚠ Algunos mods fallaron:" -ForegroundColor Yellow
        foreach ($fallo in $Fallidos) {
            Write-Host "      - $fallo" -ForegroundColor Yellow
        }
    }
    Write-Host ""
    Write-Host "   Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# =========================================
# FUNCIÓN PARA DESCARGAR FORGE
# =========================================
function Descargar-Forge {
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Magenta
Write-Host "   DESCARGAR FORGE 1.20.1 MINECRAFT (SOLO PREMIUM)" -ForegroundColor Magenta
    Write-Host "=====================================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "   Importante: Solo para Minecraft Premium" -ForegroundColor Yellow
    Write-Host "   Usuarios de TLauncher NO necesitan esto" -ForegroundColor Yellow
    Write-Host "   El instalador se guardará en tu carpeta 'Descargas'" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[1/3] Descargando instalador de Forge..." -ForegroundColor Yellow
    
    # Descargar desde tu repositorio (carpeta forge)
    $ForgeURL = "https://raw.githubusercontent.com/$UsuarioGitHub/$NombreRepo/main/forge/forge-installer.jar"
    
    try {
        # Verificar si ya existe el archivo en Descargas
        if (Test-Path $RutaForgeDescarga) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $RutaForgeDescarga = "$env:USERPROFILE\Downloads\forge-installer_$timestamp.jar"
            Write-Host "   Archivo existente, se renombrará a: $(Split-Path $RutaForgeDescarga -Leaf)" -ForegroundColor Yellow
        }
        
        Invoke-WebRequest -Uri $ForgeURL -OutFile $RutaForgeDescarga -UseBasicParsing -ErrorAction Stop
        Write-Host "   ✓ Instalador descargado" -ForegroundColor Green
        Write-Host "   Ubicación: $RutaForgeDescarga" -ForegroundColor Gray
    } catch {
        Write-Host "   ✗ Error al descargar Forge" -ForegroundColor Red
        Write-Host ""
        Write-Host "   SOLUCIÓN: Asegurate de subir 'forge-installer.jar'" -ForegroundColor Yellow
        Write-Host "   a la carpeta 'forge/' de tu GitHub" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   Presiona cualquier tecla para salir..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
    
    Write-Host "[2/3] Abriendo instalador..." -ForegroundColor Yellow
    Write-Host "   Se abrirá la ventana de instalación de Forge" -ForegroundColor White
    Write-Host "   Sigue estos pasos:" -ForegroundColor White
    Write-Host "   1. Haz clic en 'Install client'" -ForegroundColor Cyan
    Write-Host "   2. Espera a que termine" -ForegroundColor Cyan
    Write-Host "   3. Cierra el instalador cuando finalice" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   El instalador se abrirá en 5 segundos..." -ForegroundColor Gray
    
    # Contador regresivo
    for ($i = 5; $i -gt 0; $i--) {
        Write-Host "   $i..." -ForegroundColor Gray
        Start-Sleep -Seconds 1
    }
    
    # Ejecutar el instalador
    try {
        Start-Process -FilePath "java" -ArgumentList "-jar", "`"$RutaForgeDescarga`"" -Wait
        Write-Host "   ✓ Instalación completada" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ No se pudo abrir el instalador automáticamente" -ForegroundColor Red
        Write-Host "   Abre manualmente el archivo: $RutaForgeDescarga" -ForegroundColor Yellow
    }
    
    Write-Host "[3/3] Finalizando..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host "   ¡FORGE DESCARGADO CORRECTAMENTE!" -ForegroundColor Green
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host "   Instalación manual:" -ForegroundColor White
    Write-Host "   1. Abre el archivo descargado en tu carpeta 'Descargas'" -ForegroundColor Cyan
    Write-Host "   2. Haz clic en 'Install client'" -ForegroundColor Cyan
    Write-Host "   3. Espera y cierra el instalador" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Después en el launcher de Minecraft:" -ForegroundColor White
    Write-Host "   1. Selecciona 'Forge 1.20.1'" -ForegroundColor Cyan
    Write-Host "   2. Descarga los mods (Opción 1 de este instalador)" -ForegroundColor Cyan
    Write-Host "   3. ¡Conéctate al servidor y a jugar!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   IP DEL SERVIDOR: PanqueLovers.aternos.me" -ForegroundColor Green
    Write-Host ""
    Write-Host "   Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# =========================================
# EJECUCIÓN PRINCIPAL (NO REGRESA AL MENÚ)
# =========================================
switch ($opcion) {
    "1" { 
        Descargar-Mods  # Después de terminar, se cierra
    }
    "2" { 
        Descargar-Forge  # Después de terminar, se cierra
    }
    "3" { 
        Write-Host ""
        Write-Host "   ¡Gracias por usar el instalador!" -ForegroundColor Cyan
        Write-Host "   IP: PanqueLovers.aternos.me" -ForegroundColor Green
        Write-Host ""
        Start-Sleep -Seconds 2
        exit
    }
    default {
        Write-Host "   Opción no válida. El script se cerrará." -ForegroundColor Red
        Start-Sleep -Seconds 2
        exit
    }
}