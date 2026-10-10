<#
.SYNOPSIS
    Revisa si hay que actualizar algo del setup de Claude Code de Martín.

.DESCRIPTION
    Por defecto solo mira: no instala ni cambia nada.
    - Tus skills: si la instalada es igual a la de GitHub y si su carpeta del Escritorio tiene cambios sin subir.
    - Skills de terceros sueltas: si su repo original cambió.
    - agent-browser: la versión instalada contra la última, y si ya cerraron los bugs que esquiva navegador-visible.
    - Plugins: cuándo se actualizó cada uno por última vez.
    - CLAUDE.md: si la copia de este repo está al día.
    - Este repo: si quedó público y si tiene cambios sin subir.

.PARAMETER ActualizarPlugins
    Además actualiza los catálogos y los plugins (claude plugin update). Después hay que reiniciar Claude Code.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\revisar.ps1
#>
param(
    [switch]$ActualizarPlugins
)

$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
. (Join-Path $PSScriptRoot 'inventario.ps1')

$pendientes = New-Object System.Collections.Generic.List[string]
$diasPlugin = 30

function Titulo([string]$texto) { Write-Host "`n== $texto ==" -ForegroundColor Cyan }
function Bien([string]$texto) { Write-Host "  OK  $texto" -ForegroundColor Green }
function Info([string]$texto) { Write-Host "      $texto" -ForegroundColor DarkGray }
function Ojo([string]$texto, [string]$queHacer) {
    Write-Host "  !!  $texto" -ForegroundColor Yellow
    if ($queHacer) { Write-Host "      -> $queHacer" -ForegroundColor Gray }
    $pendientes.Add($texto)
}

# Huella de un archivo que no cambia por los saltos de línea (CRLF/LF) ni por el BOM.
function HuellaArchivo([string]$ruta) {
    $texto = [IO.File]::ReadAllText($ruta).Replace("`r", '')
    $sha = [Security.Cryptography.SHA256]::Create()
    return [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($texto)))
}

function Huellas([string]$carpeta) {
    $tabla = @{}
    if (-not (Test-Path $carpeta)) { return $tabla }
    $base = (Resolve-Path $carpeta).Path.TrimEnd('\')
    Get-ChildItem $base -Recurse -File -Force |
        Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -notmatch '^LICEN[CS]E' } |
        ForEach-Object { $tabla[$_.FullName.Substring($base.Length + 1).Replace('\', '/')] = HuellaArchivo $_.FullName }
    return $tabla
}

# Lista de diferencias entre la carpeta local y la de referencia: ~ distinto, + solo acá, - solo allá.
function Diferencias([string]$local, [string]$referencia) {
    $a = Huellas $local
    $b = Huellas $referencia
    $difs = @()
    foreach ($k in (@($a.Keys) + @($b.Keys) | Sort-Object -Unique)) {
        if (-not $b.ContainsKey($k)) { $difs += "+ $k" }
        elseif (-not $a.ContainsKey($k)) { $difs += "- $k" }
        elseif ($a[$k] -ne $b[$k]) { $difs += "~ $k" }
    }
    return $difs
}

function EstadoGit([string]$carpeta, [string]$nombre) {
    if (-not (Test-Path (Join-Path $carpeta '.git'))) { return }
    $sucio = @(git -C $carpeta status --porcelain 2>$null)
    if ($sucio.Count -gt 0) {
        Ojo "$nombre tiene $($sucio.Count) archivo(s) cambiados sin commit" "En esa carpeta: git add -A, git commit y git push"
    }
    $adelante = (git -C $carpeta rev-list --count '@{u}..HEAD' 2>$null)
    if ($adelante -and [int]$adelante -gt 0) {
        Ojo "$nombre tiene $adelante commit(s) sin push" "En esa carpeta: git push"
    }
}

function ApiGitHub([string]$ruta) {
    # Devuelve el objeto, o el código de error (404, etc.) como número.
    try { return Invoke-RestMethod "https://api.github.com/$ruta" -TimeoutSec 20 }
    catch {
        if ($_.Exception.Response) { return [int]$_.Exception.Response.StatusCode }
        return 0
    }
}

$claude = $null
$enPath = Get-Command claude -ErrorAction SilentlyContinue
if ($enPath) { $claude = $enPath.Source }
elseif (Test-Path (Join-Path $env:USERPROFILE '.local\bin\claude.exe')) { $claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe' }

# ------------------------- Bajar los repos de las skills -------------------------
$temporal = Join-Path $env:TEMP ('revisar-skills-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force -Path $temporal | Out-Null
$clones = @{}
foreach ($repo in ($skillsSueltas | ForEach-Object { $_.Repo } | Sort-Object -Unique)) {
    $destino = Join-Path $temporal ($repo -replace '/', '__')
    git clone --quiet --depth 1 "https://github.com/$repo.git" $destino 2>$null
    if ($LASTEXITCODE -eq 0) { $clones[$repo] = $destino }
}
$dirSkills = Join-Path $env:USERPROFILE '.claude\skills'

# ------------------------------- Tus skills -------------------------------
Titulo 'Tus skills'
foreach ($s in ($skillsSueltas | Where-Object { $_.Propia })) {
    $instalada = Join-Path $dirSkills $s.Nombre
    if (-not (Test-Path $instalada)) { Ojo "$($s.Nombre) no está instalada" 'Corré instalar.ps1'; continue }

    if ($clones.ContainsKey($s.Repo)) {
        $difs = @(Diferencias $instalada (Join-Path $clones[$s.Repo] $s.Carpeta))
        if ($difs.Count -eq 0) { Bien "$($s.Nombre): igual a GitHub" }
        else {
            Ojo "$($s.Nombre): distinta de GitHub ($($difs.Count) archivo(s))" "Si la cambiaste en esta PC: copiala a su carpeta del Escritorio y subila. Si la cambiaste en otra PC: corré instalar.ps1."
            $difs | ForEach-Object { Info $_ }
        }
    } else { Info "$($s.Nombre): no pude bajar $($s.Repo) para comparar" }

    $repoLocal = Join-Path $env:USERPROFILE ('Desktop\' + $s.RepoLocal)
    if ($s.RepoLocal -and (Test-Path $repoLocal)) {
        $copia = Join-Path $repoLocal ($s.Carpeta -replace '/', '\')
        $difsCopia = @(Diferencias $instalada $copia)
        if ($difsCopia.Count -gt 0) {
            Ojo "$($s.Nombre): la carpeta Desktop\$($s.RepoLocal) no tiene la última versión" "Copiá ~\.claude\skills\$($s.Nombre) a Desktop\$($s.RepoLocal)\$($s.Carpeta -replace '/', '\')"
        }
        EstadoGit $repoLocal "Desktop\$($s.RepoLocal)"
    }
}

# ------------------------- Skills de terceros sueltas -------------------------
Titulo 'Skills de terceros sueltas'
foreach ($s in ($skillsSueltas | Where-Object { -not $_.Propia })) {
    $instalada = Join-Path $dirSkills $s.Nombre
    if (-not (Test-Path $instalada)) { Ojo "$($s.Nombre) no está instalada" 'Corré instalar.ps1'; continue }
    if (-not $clones.ContainsKey($s.Repo)) { Info "$($s.Nombre): no pude bajar $($s.Repo) para comparar"; continue }
    $difs = @(Diferencias $instalada (Join-Path $clones[$s.Repo] $s.Carpeta))
    if ($difs.Count -eq 0) { Bien "$($s.Nombre): igual a su repo original" }
    else {
        Ojo "$($s.Nombre): cambió en su repo original ($($difs.Count) archivo(s))" 'Pedile a Claude, en el chat de skills, que revise los cambios; después corré instalar.ps1'
    }
}

# ------------------------------- agent-browser -------------------------------
Titulo 'agent-browser'
if (-not (Get-Command agent-browser -ErrorAction SilentlyContinue)) {
    Ojo 'agent-browser no está instalado' 'Corré instalar.ps1'
} else {
    # --version no abre el navegador, así que capturar su salida es seguro.
    $local = ((agent-browser --version 2>$null | Out-String) -replace 'agent-browser', '').Trim()
    $ultima = (npm view agent-browser version 2>$null | Out-String).Trim()
    if (-not $ultima) { Info "Instalada: $local (no pude consultar npm)" }
    elseif ($local -eq $ultima) { Bien "agent-browser $local (la última)" }
    else { Ojo "agent-browser $local; salió la $ultima" 'Con las ventanas de prueba cerradas: npm install -g agent-browser@latest' }
}

# ------------------------------ Bugs vigilados ------------------------------
Titulo 'Bugs de terceros que esquivamos'
foreach ($b in $bugsVigilados) {
    $issue = ApiGitHub "repos/$($b.Repo)/issues/$($b.Numero)"
    if ($issue -is [int]) { Info "No pude consultar $($b.Repo)#$($b.Numero)"; continue }
    if ($issue.state -eq 'closed') {
        Ojo "Cerraron $($b.Repo)#$($b.Numero): $($b.Que)" $b.QueHacer
    } else { Bien "$($b.Repo)#$($b.Numero) sigue abierto ($($b.Que))" }
}

# --------------------------------- Plugins ---------------------------------
Titulo 'Plugins'
if (-not $claude) {
    Info 'No encuentro Claude Code: salteo los plugins'
} elseif ($ActualizarPlugins) {
    Write-Host '  Actualizando los catálogos…'
    & $claude plugin marketplace update 2>&1 | Out-Null
    foreach ($p in $plugins) {
        $salida = (& $claude plugin update $p 2>&1 | Out-String)
        if ($salida -match 'already at the latest') { Bien "$p al día" }
        elseif ($salida -match 'updated from (\S+) to (\S+)') {
            Ojo "$p actualizado de $($Matches[1]) a $($Matches[2])" 'Reiniciá Claude Code. Si saltó de versión grande (ej. 5.x a 6.x), pedile a Claude que revise qué cambió'
        } else { Ojo "$p no se pudo actualizar" ''; Info ($salida.Trim()) }
    }
} else {
    $lista = $null
    try { $lista = (& $claude plugin list --json 2>$null | Out-String) | ConvertFrom-Json } catch { }
    if (-not $lista) { Info 'No pude leer la lista de plugins' }
    else {
        $viejos = 0
        foreach ($p in $lista) {
            $dias = [int]((Get-Date) - [datetime]$p.lastUpdated).TotalDays
            if ($dias -gt $diasPlugin) { $viejos++; Info "$($p.id) · $($p.version) · sin actualizar hace $dias días" }
            else { Bien "$($p.id) · $($p.version) · actualizado hace $dias días" }
        }
        if ($viejos -gt 0) {
            Ojo "$viejos plugin(s) sin actualizar hace más de $diasPlugin días" 'Para buscar versiones nuevas e instalarlas: .\revisar.ps1 -ActualizarPlugins'
        }
    }
}

# -------------------------------- CLAUDE.md --------------------------------
Titulo 'CLAUDE.md'
$mdReal = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
$mdCopia = Join-Path $PSScriptRoot 'claude\CLAUDE.md'
if (-not (Test-Path $mdReal) -or -not (Test-Path $mdCopia)) { Info 'Falta uno de los dos CLAUDE.md' }
elseif ((HuellaArchivo $mdReal) -eq (HuellaArchivo $mdCopia)) { Bien 'La copia del repo está al día' }
else { Ojo 'Tu CLAUDE.md cambió y la copia del repo quedó vieja' 'Copiá ~\.claude\CLAUDE.md a claude\CLAUDE.md y subilo' }

# -------------------------------- Este repo --------------------------------
Titulo 'Este repo (skills-del-sistema)'
$origen = (git -C $PSScriptRoot remote get-url origin 2>$null | Out-String).Trim()
if ($origen -match 'github\.com[/:]([^/]+/[^/.]+)') {
    $repo = ApiGitHub "repos/$($Matches[1])"
    if ($repo -is [int] -and $repo -eq 404) { Bien 'Es privado' }
    elseif ($repo -is [int]) { Info 'No pude consultar GitHub' }
    elseif ($repo.private -eq $false) {
        Ojo 'Es PÚBLICO: cualquiera puede ver tu CLAUDE.md' 'GitHub > el repo > Settings > General > Danger Zone > Change repository visibility > Make private'
    } else { Bien 'Es privado' }
}
EstadoGit $PSScriptRoot 'skills-del-sistema'

# ---------------------------------- Final ----------------------------------
Remove-Item $temporal -Recurse -Force -ErrorAction SilentlyContinue
Titulo 'Resumen'
if ($pendientes.Count -eq 0) { Write-Host '  Todo al día.' -ForegroundColor Green }
else {
    Write-Host "  $($pendientes.Count) cosa(s) para mirar:" -ForegroundColor Yellow
    $pendientes | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
