# ====================================================
# INSTALADOR COMPLETO DE MINECRAFT 1.20.1
# Repositorio: https://github.com/LuisPuroRush/Minecraft
# Creado por :v Panquesito - TikTok: a.panquesito
# ====================================================

# CONFIGURACIÓN PRINCIPAL
$Config = @{
    UsuarioGitHub = "LuisPuroRush"
    Repositorio   = "Minecraft"
    IP_Servidor   = "PanqueLovers.aternos.me"
}

# RUTAS DEL SISTEMA
$Rutas = @{
    ModsLocal          = "$env:APPDATA\.minecraft\mods"
    ForgeDescarga      = "$env:USERPROFILE\Downloads\forge-installer.jar"
    TLauncherDescarga  = "$env:USERPROFILE\Downloads\TLauncher-Installer.exe"
    CarpetaModsGitHub  = "mods"
    CarpetaForgeGitHub = "forge"
    CarpetaTLauncherGitHub = "minecraft"
}

# ====================================================
# FUNCIONES PRINCIPALES
# ====================================================

function Mostrar-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "    INSTALADOR COMPLETO DE MINECRAFT 1.20.1" -ForegroundColor Cyan
    Write-Host "         $($Config.IP_Servidor)" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Información del creador
    Write-Host "   Creado por :v Panquesito" -ForegroundColor Yellow
    Write-Host "   TikTok: a.panquesito" -ForegroundColor Yellow
    Write-Host ""
    
    # Instrucciones generales
    Write-Host "   INSTRUCCIONES IMPORTANTES:" -ForegroundColor White
    Write-Host "   • TLauncher: Para usuarios NO Premium" -ForegroundColor Gray
    Write-Host "   • Premium: Usar Forge oficial (Opción 2)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   IP DEL SERVIDOR: $($Config.IP_Servidor)" -ForegroundColor Green
    Write-Host ""
    
    # Opciones del menú
    Write-Host "   OPCIONES DISPONIBLES:" -ForegroundColor White
    Write-Host "   1. DESCARGAR E INSTALAR MODS" -ForegroundColor Yellow
    Write-Host "   2. DESCARGAR FORGE 1.20.1 (SOLO PREMIUM)" -ForegroundColor Magenta
    Write-Host "   3. INSTALAR TLAUNCHER (NO PREMIUM)" -ForegroundColor Cyan
    Write-Host "       ⚠  Leer bien al momento de instalar no todo es check" -ForegroundColor Red
    Write-Host "   4. SALIR" -ForegroundColor Yellow
    Write-Host ""
}

function Pausa-Y-Continuar {
    Write-Host ""
    Write-Host "   Presiona ENTER para continuar..." -ForegroundColor Gray -NoNewline
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Descargar-Mods {
    Clear-Host
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host "   DESCARGANDO MODS DE MINECRAFT" -ForegroundColor Green
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host ""
    
    # Paso 1: Preparar carpeta
    Write-Host "   [1/4] PREPARANDO CARPETA..." -ForegroundColor Yellow
    if (-not (Test-Path $Rutas.ModsLocal)) {
        New-Item -ItemType Directory -Path $Rutas.ModsLocal -Force | Out-Null
        Write-Host "   ✓ Carpeta creada: $($Rutas.ModsLocal)" -ForegroundColor Green
    } else {
        Write-Host "   ✓ Carpeta ya existe" -ForegroundColor Green
    }
    
    # Paso 2: Conectar a GitHub
    Write-Host "   [2/4] CONECTANDO CON GITHUB..." -ForegroundColor Yellow
    $UrlApi = "https://api.github.com/repos/$($Config.UsuarioGitHub)/$($Config.Repositorio)/contents/$($Rutas.CarpetaModsGitHub)"
    
    try {
        $Contenido = Invoke-RestMethod -Uri $UrlApi -UseBasicParsing
        $Archivos = $Contenido | Where-Object { $_.type -eq "file" -and $_.name -like "*.jar" }
        $Total = $Archivos.Count
        
        if ($Total -eq 0) {
            Write-Host "   ✗ No se encontraron archivos .jar" -ForegroundColor Red
            Pausa-Y-Continuar
            return $false
        }
        
        Write-Host "   ✓ Encontrados $Total mod(s)" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ Error al conectar con GitHub" -ForegroundColor Red
        Write-Host "   Verifica la conexión o la carpeta 'mods'" -ForegroundColor Yellow
        Pausa-Y-Continuar
        return $false
    }
    
    # Paso 3: Descargar mods
    Write-Host "   [3/4] DESCARGANDO MODS..." -ForegroundColor Yellow
    Write-Host ""
    
    $Descargados = 0
    $Fallidos = 0
    
    for ($i = 0; $i -lt $Archivos.Count; $i++) {
        $Mod = $Archivos[$i]
        $Porcentaje = [math]::Round((($i + 1) / $Total) * 100)
        $RutaDestino = Join-Path $Rutas.ModsLocal $Mod.name
        
        # Barra de progreso
        Write-Progress -Activity "Descargando mods..." -Status "$($Mod.name)" -PercentComplete $Porcentaje -CurrentOperation "Mod $($i+1) de $Total"
        
        try {
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($Mod.download_url, $RutaDestino)
            $Descargados++
            Write-Host "   [$($i+1)/$Total] ✓ $($Mod.name)" -ForegroundColor Green
        } catch {
            try {
                Invoke-WebRequest -Uri $Mod.download_url -OutFile $RutaDestino -UseBasicParsing
                $Descargados++
                Write-Host "   [$($i+1)/$Total] ✓ $($Mod.name)" -ForegroundColor Green
            } catch {
                $Fallidos++
                Write-Host "   [$($i+1)/$Total] ✗ $($Mod.name)" -ForegroundColor Red
            }
        }
    }
    
    Write-Progress -Activity "Descargando mods..." -Completed
    
    # Paso 4: Resultados
    Write-Host ""
    Write-Host "   [4/4] RESULTADOS FINALES" -ForegroundColor Yellow
    Write-Host "   ===========================================" -ForegroundColor Gray
    
    if ($Descargados -eq $Total) {
        Write-Host "   ✅ TODOS LOS MODS DESCARGADOS" -ForegroundColor Green
    } else {
        Write-Host "   ⚠  DESCARGADOS: $Descargados/$Total" -ForegroundColor Yellow
        if ($Fallidos -gt 0) {
            Write-Host "   Algunos mods fallaron, intenta nuevamente" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "   Ubicación: $($Rutas.ModsLocal)" -ForegroundColor White
    Write-Host "   IP: $($Config.IP_Servidor)" -ForegroundColor Cyan
    Write-Host ""
    
    return $true
}

function Descargar-Forge {
    Clear-Host
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Magenta
    Write-Host "   DESCARGAR FORGE 1.20.1 (SOLO PREMIUM)" -ForegroundColor Magenta
    Write-Host "=====================================================" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Host "   ⚠  ATENCIÓN: Solo para Minecraft Premium" -ForegroundColor Yellow
    Write-Host "   TLauncher ya incluye Forge (no usar esta opción)" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "   [1/3] DESCARGANDO INSTALADOR..." -ForegroundColor Yellow
    
    # Generar nombre único si ya existe
    if (Test-Path $Rutas.ForgeDescarga) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $Rutas.ForgeDescarga = "$env:USERPROFILE\Downloads\forge-installer_$timestamp.jar"
    }
    
    # URL del instalador en GitHub
    $ForgeURL = "https://raw.githubusercontent.com/$($Config.UsuarioGitHub)/$($Config.Repositorio)/main/$($Rutas.CarpetaForgeGitHub)/forge-installer.jar"
    
    try {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($ForgeURL, $Rutas.ForgeDescarga)
        Write-Host "   ✓ Instalador descargado" -ForegroundColor Green
        Write-Host "   Ubicación: $($Rutas.ForgeDescarga)" -ForegroundColor Gray
    } catch {
        Write-Host "   ✗ Error al descargar Forge" -ForegroundColor Red
        Write-Host ""
        Write-Host "   SOLUCIÓN: Verifica que el archivo existe en:" -ForegroundColor Yellow
        Write-Host "   https://github.com/$($Config.UsuarioGitHub)/$($Config.Repositorio)/tree/main/forge" -ForegroundColor Cyan
        Pausa-Y-Continuar
        return $false
    }
    
    Write-Host ""
    Write-Host "   [2/3] EJECUTANDO INSTALADOR..." -ForegroundColor Yellow
    Write-Host "   Se abrirá en 3 segundos..." -ForegroundColor Gray
    
    # Cuenta regresiva
    for ($i = 3; $i -gt 0; $i--) {
        Write-Host "   $i..." -ForegroundColor Gray
        Start-Sleep -Seconds 1
    }
    
    # Ejecutar el instalador
    try {
        Start-Process -FilePath "java" -ArgumentList "-jar", "`"$($Rutas.ForgeDescarga)`""
        Write-Host "   ✓ Instalador ejecutado" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ No se pudo abrir automáticamente" -ForegroundColor Red
        Write-Host "   Abre manualmente: $($Rutas.ForgeDescarga)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "   [3/3] INSTRUCCIONES FINALES" -ForegroundColor Yellow
    Write-Host "   ===========================================" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   1. En el instalador de Forge:" -ForegroundColor White
    Write-Host "      • Haz clic en 'Install client'" -ForegroundColor Cyan
    Write-Host "      • Espera a que termine" -ForegroundColor Cyan
    Write-Host "      • Cierra el instalador" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   2. En Minecraft Launcher:" -ForegroundColor White
    Write-Host "      • Selecciona 'Forge 1.20.1'" -ForegroundColor Cyan
    Write-Host "      • Descarga los mods (Opción 1)" -ForegroundColor Cyan
    Write-Host "      • ¡Conéctate y juega!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   IP: $($Config.IP_Servidor)" -ForegroundColor Green
    Write-Host ""
    
    return $true
}

function Instalar-TLauncher {
    Clear-Host
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "   INSTALAR TLAUNCHER (NO PREMIUM)" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "   ⚠  ¡ATENCIÓN IMPORTANTE!" -ForegroundColor Red
    Write-Host "   Leer bien al momento de instalar, no todo es check" -ForegroundColor Red
    Write-Host "   Durante la instalación, DESMARCAR opciones no deseadas" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "   [1/3] DESCARGANDO TLAUNCHER..." -ForegroundColor Yellow
    
    # URL del TLauncher en GitHub
    $TLauncherURL = "https://raw.githubusercontent.com/$($Config.UsuarioGitHub)/$($Config.Repositorio)/main/$($Rutas.CarpetaTLauncherGitHub)/TLauncher-Installer-1.9.5.1.exe"
    
    try {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($TLauncherURL, $Rutas.TLauncherDescarga)
        Write-Host "   ✓ TLauncher descargado" -ForegroundColor Green
        Write-Host "   Ubicación: $($Rutas.TLauncherDescarga)" -ForegroundColor Gray
    } catch {
        Write-Host "   ✗ Error al descargar TLauncher" -ForegroundColor Red
        Write-Host ""
        Write-Host "   SOLUCIÓN: Verifica que el archivo existe en:" -ForegroundColor Yellow
        Write-Host "   https://github.com/$($Config.UsuarioGitHub)/$($Config.Repositorio)/tree/main/minecraft" -ForegroundColor Cyan
        Pausa-Y-Continuar
        return $false
    }
    
    Write-Host ""
    Write-Host "   [2/3] EJECUTANDO INSTALADOR..." -ForegroundColor Yellow
    Write-Host "   Se abrirá en 5 segundos..." -ForegroundColor Gray
    Write-Host ""
    Write-Host "   CONSEJOS PARA LA INSTALACIÓN:" -ForegroundColor White
    Write-Host "   1. Lee cada pantalla cuidadosamente" -ForegroundColor Cyan
    Write-Host "   2. Desmarca 'Instalar software adicional'" -ForegroundColor Cyan
    Write-Host "   3. Desmarca 'Cambiar página de inicio'" -ForegroundColor Cyan
    Write-Host "   4. Elige solo lo necesario" -ForegroundColor Cyan
    Write-Host ""
    
    # Cuenta regresiva
    for ($i = 5; $i -gt 0; $i--) {
        Write-Host "   $i..." -ForegroundColor Gray
        Start-Sleep -Seconds 1
    }
    
    # Ejecutar el instalador
    try {
        Start-Process -FilePath $Rutas.TLauncherDescarga
        Write-Host "   ✓ Instalador ejecutado" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ No se pudo abrir automáticamente" -ForegroundColor Red
        Write-Host "   Abre manualmente: $($Rutas.TLauncherDescarga)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "   [3/3] INSTRUCCIONES FINALES" -ForegroundColor Yellow
    Write-Host "   ===========================================" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   DESPUÉS DE INSTALAR TLAUNCHER:" -ForegroundColor White
    Write-Host "   1. Abre TLauncher" -ForegroundColor Cyan
    Write-Host "   2. En 'Versiones', selecciona 'Forge 1.20.1'" -ForegroundColor Cyan
    Write-Host "   3. Descarga los mods (Opción 1 de este instalador)" -ForegroundColor Cyan
    Write-Host "   4. ¡Conéctate y juega!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   IP: $($Config.IP_Servidor)" -ForegroundColor Green
    Write-Host ""
    
    return $true
}

# ====================================================
# PROGRAMA PRINCIPAL
# ====================================================

# Verificar que se está ejecutando en PowerShell
if ($Host.Name -notmatch "ConsoleHost") {
    Write-Host "ERROR: Este script debe ejecutarse en PowerShell" -ForegroundColor Red
    Write-Host "Usa: irm URL_DEL_SCRIPT | iex" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit
}

# Bucle principal del menú
do {
    Mostrar-Menu
    $opcion = Read-Host "   Selecciona una opción (1-4)"
    
    switch ($opcion) {
        "1" {
            $resultado = Descargar-Mods
            if ($resultado) {
                Pausa-Y-Continuar
            }
        }
        "2" {
            $resultado = Descargar-Forge
            if ($resultado) {
                Pausa-Y-Continuar
            }
        }
        "3" {
            $resultado = Instalar-TLauncher
            if ($resultado) {
                Pausa-Y-Continuar
            }
        }
        "4" {
            Clear-Host
            Write-Host ""
            Write-Host "=====================================================" -ForegroundColor Cyan
            Write-Host "   ¡GRACIAS POR USAR EL INSTALADOR!" -ForegroundColor Cyan
            Write-Host "   Nos vemos en el servidor" -ForegroundColor Cyan
            Write-Host "   $($Config.IP_Servidor)" -ForegroundColor Green
            Write-Host "=====================================================" -ForegroundColor Cyan
            Write-Host ""
            Start-Sleep -Seconds 3
            exit
        }
        default {
            Write-Host "   Opción no válida. Intenta de nuevo." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)