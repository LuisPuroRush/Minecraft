# INSTALADOR AUTOMÁTICO DE MODS Y FORGE PARA MINECRAFT
# Repositorio: https://github.com/LuisPuroRush/Minecraft
# Creado por :v Panquesito - TikTok: a.panquesito

# Configuración
$UsuarioGitHub = "LuisPuroRush"
$NombreRepo    = "Minecraft"

# Rutas locales
$RutaModsLocal = "$env:APPDATA\.minecraft\mods"
$RutaForgeLocal = "$env:TEMP\forge-installer.jar"

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
        pause
        return
    }

    $Mods = $ContenidoCarpeta | Where-Object { $_.type -eq "file" -and $_.name -like "*.jar" }
    $TotalMods = $Mods.Count
    
    if ($TotalMods -eq 0) {
        Write-Host "   No se encontraron mods en la carpeta." -ForegroundColor Red
        pause
        return
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
    pause
}

# =========================================
# FUNCIÓN PARA INSTALAR FORGE
# =========================================
function Instalar-Forge {
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Magenta
    Write-Host "   INSTALADOR DE FORGE 1.20.1 (SOLO PREMIUM)" -ForegroundColor Magenta
    Write-Host "=====================================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "   Importante: Solo para Minecraft Premium" -ForegroundColor Yellow
    Write-Host "   Usuarios de TLauncher NO necesitan esto" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "[1/4] Verificando requisitos..." -ForegroundColor Yellow
    
    # Verificar si Java está instalado
    try {
        $javaCheck = java -version 2>&1
        Write-Host "   ✓ Java encontrado" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ Java NO encontrado" -ForegroundColor Red
        Write-Host "   Para usuarios Premium: Necesitas instalar Java" -ForegroundColor Yellow
        Write-Host "   Descargar desde: https://www.java.com/es/download/" -ForegroundColor Cyan
        Write-Host ""
        pause
        return
    }
    
    Write-Host "[2/4] Descargando instalador de Forge..." -ForegroundColor Yellow
    
    # Descargar desde tu repositorio (más confiable)
    $ForgeURL = "https://raw.githubusercontent.com/$UsuarioGitHub/$NombreRepo/main/forge/forge-installer.jar"
    
    try {
        Invoke-WebRequest -Uri $ForgeURL -OutFile $RutaForgeLocal -UseBasicParsing -ErrorAction Stop
        Write-Host "   ✓ Instalador descargado" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ Error al descargar Forge" -ForegroundColor Red
        Write-Host "   Asegurate de subir 'forge-installer.jar' a la carpeta 'forge/' de tu GitHub" -ForegroundColor Yellow
        Write-Host ""
        pause
        return
    }
    
    Write-Host "[3/4] Ejecutando instalador..." -ForegroundColor Yellow
    Write-Host "   Se abrirá la ventana de instalación de Forge" -ForegroundColor White
    Write-Host "   Sigue estos pasos:" -ForegroundColor White
    Write-Host "   1. Haz clic en 'Install client'" -ForegroundColor Cyan
    Write-Host "   2. Espera a que termine" -ForegroundColor Cyan
    Write-Host "   3. Cierra el instalador cuando finalice" -ForegroundColor Cyan
    Write-Host ""
    
    # Dar tiempo para leer
    Start-Sleep -Seconds 3
    
    # Ejecutar el instalador
    try {
        Start-Process java -ArgumentList "-jar", "`"$RutaForgeLocal`"" -Wait
        Write-Host "   ✓ Instalación completada" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ Error al ejecutar el instalador" -ForegroundColor Red
        Write-Host ""
        pause
        return
    }
    
    Write-Host "[4/4] Finalizando..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host "   ¡FORGE INSTALADO CORRECTAMENTE!" -ForegroundColor Green
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host "   Ahora en el launcher de Minecraft:" -ForegroundColor White
    Write-Host "   1. Crea un nuevo perfil o selecciona 'Forge 1.20.1'" -ForegroundColor Cyan
    Write-Host "   2. Asegúrate de descargar los mods (Opción 1)" -ForegroundColor Cyan
    Write-Host "   3. ¡Conéctate al servidor y a jugar!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   IP DEL SERVIDOR: PanqueLovers.aternos.me" -ForegroundColor Green
    Write-Host ""
    pause
}

# =========================================
# EJECUCIÓN PRINCIPAL
# =========================================
switch ($opcion) {
    "1" { 
        Descargar-Mods
        # Volver al menú principal
        & $MyInvocation.MyCommand.Path
    }
    "2" { 
        Instalar-Forge
        # Volver al menú principal
        & $MyInvocation.MyCommand.Path
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
        Write-Host "   Opción no válida. Inténtalo de nuevo." -ForegroundColor Red
        Start-Sleep -Seconds 2
        & $MyInvocation.MyCommand.Path
    }
}