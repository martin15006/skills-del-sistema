<#
.SYNOPSIS
    Rearma en una PC nueva todo el setup de Claude Code de Martín: plugins, skills, agent-browser y CLAUDE.md.

.DESCRIPTION
    - Agrega los marketplaces de terceros e instala los mismos plugins.
    - Baja cada skill suelta desde su repo original y la copia a ~/.claude/skills con el mismo nombre
      (las de terceros llevan su LICENSE).
    - Instala el CLI agent-browser y deja AGENT_BROWSER_HEADED=1 (ventanas visibles).
    - Pone el CLAUDE.md global (si ya había uno, antes lo respalda).
    Se puede correr varias veces: lo que ya está instalado se saltea.

.PARAMETER SoloVer
    Muestra lo que haría, sin cambiar nada.

.PARAMETER SinClaudeMd
    No toca el CLAUDE.md global.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\instalar.ps1 -SoloVer
#>
param(
    [switch]$SoloVer,
    [switch]$SinClaudeMd
)

$ErrorActionPreference = 'Continue'

# El inventario (marketplaces, plugins y skills sueltas) vive en inventario.ps1.
. (Join-Path $PSScriptRoot 'inventario.ps1')

$raiz = $PSScriptRoot
$avisos = New-Object System.Collections.Generic.List[string]

function Titulo([string]$texto) {
    Write-Host "`n== $texto ==" -ForegroundColor Cyan
}

function Hacer([string]$descripcion, [scriptblock]$accion) {
    if ($SoloVer) {
        Write-Host "  (solo ver) $descripcion" -ForegroundColor DarkGray
        return
    }
    Write-Host "  $descripcion"
    & $accion
}

function Avisar([string]$texto) {
    Write-Warning $texto
    $avisos.Add($texto)
}

# ------------------------------ Requisitos ------------------------------
Titulo 'Requisitos'

$claude = $null
$enPath = Get-Command claude -ErrorAction SilentlyContinue
if ($enPath) {
    $claude = $enPath.Source
} else {
    $candidato = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
    if (Test-Path $candidato) { $claude = $candidato }
}
if (-not $claude) {
    Write-Host 'No encuentro Claude Code. Instalalo primero (https://claude.com/claude-code) y volvé a correr este script.' -ForegroundColor Red
    exit 1
}
Write-Host "  Claude Code: $claude"

$faltan = @()
foreach ($herramienta in @('git', 'npm')) {
    if (-not (Get-Command $herramienta -ErrorAction SilentlyContinue)) { $faltan += $herramienta }
}
if ($faltan.Count -gt 0) {
    Write-Host ('Faltan: ' + ($faltan -join ', ') + '. Instalá Git y Node.js y volvé a correr el script.') -ForegroundColor Red
    exit 1
}
Write-Host '  git y npm: OK'

# ----------------------------- Marketplaces -----------------------------
Titulo 'Marketplaces'

$listaMarket = (& $claude plugin marketplace list 2>&1 | Out-String)
foreach ($m in $marketplaces) {
    if ($listaMarket -match [regex]::Escape("($m)")) {
        Write-Host "  ya estaba: $m" -ForegroundColor DarkGray
        continue
    }
    Hacer "agregar $m" {
        & $claude plugin marketplace add $m
        if ($LASTEXITCODE -ne 0) { Avisar "No se pudo agregar el marketplace $m" }
    }
}

# ------------------------------- Plugins --------------------------------
Titulo 'Plugins'

$listaPlugins = (& $claude plugin list 2>&1 | Out-String)
foreach ($p in $plugins) {
    if ($listaPlugins -match [regex]::Escape($p)) {
        Write-Host "  ya estaba: $p" -ForegroundColor DarkGray
        continue
    }
    Hacer "instalar $p" {
        & $claude plugin install $p
        if ($LASTEXITCODE -ne 0) { Avisar "No se pudo instalar el plugin $p" }
    }
}

# ---------------------------- Skills sueltas ----------------------------
Titulo 'Skills sueltas'

$destinoSkills = Join-Path $env:USERPROFILE '.claude\skills'
$temporal = Join-Path $env:TEMP ('skills-del-sistema-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
if (-not $SoloVer) {
    New-Item -ItemType Directory -Force -Path $destinoSkills, $temporal | Out-Null
}

$reposFallidos = New-Object System.Collections.Generic.HashSet[string]
foreach ($grupo in ($skillsSueltas | Group-Object { $_.Repo })) {
    $repo = $grupo.Name
    $clon = Join-Path $temporal ($repo -replace '/', '__')
    Hacer "bajar $repo" {
        git clone --quiet --depth 1 "https://github.com/$repo.git" $clon 2>$null
        if ($LASTEXITCODE -ne 0) {
            Avisar "No se pudo bajar $repo (¿existe y tenés acceso?). Se saltean sus skills."
            [void]$reposFallidos.Add($repo)
        }
    }
    foreach ($s in $grupo.Group) {
        if ($reposFallidos.Contains($repo)) { continue }
        $origen = Join-Path $clon $s.Carpeta
        $destino = Join-Path $destinoSkills $s.Nombre
        Hacer "poner la skill $($s.Nombre)" {
            if (-not (Test-Path $origen)) {
                Avisar "No encontré $($s.Carpeta) en $repo"
                return
            }
            if (Test-Path $destino) { Remove-Item $destino -Recurse -Force }
            Copy-Item $origen $destino -Recurse
            if (-not $s.Propia) {
                $licencia = Get-ChildItem $clon -File | Where-Object { $_.Name -match '^LICEN[CS]E' } | Select-Object -First 1
                if ($licencia) { Copy-Item $licencia.FullName (Join-Path $destino $licencia.Name) }
            }
        }
    }
}

# ---------------------------- agent-browser -----------------------------
Titulo 'agent-browser (el navegador de navegador-visible)'

if (Get-Command agent-browser -ErrorAction SilentlyContinue) {
    Write-Host '  ya estaba instalado' -ForegroundColor DarkGray
} else {
    Hacer 'npm install -g agent-browser' {
        npm install -g agent-browser
        if ($LASTEXITCODE -ne 0) { Avisar 'No se pudo instalar agent-browser' }
    }
}
Hacer 'AGENT_BROWSER_HEADED=1 (todas las ventanas visibles)' {
    [Environment]::SetEnvironmentVariable('AGENT_BROWSER_HEADED', '1', 'User')
}

# ------------------------------ CLAUDE.md -------------------------------
if ($SinClaudeMd) {
    Titulo 'CLAUDE.md global (salteado por -SinClaudeMd)'
} else {
    Titulo 'CLAUDE.md global'
    $origenMd = Join-Path $raiz 'claude\CLAUDE.md'
    $destinoMd = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
    Hacer "copiar a $destinoMd" {
        if (-not (Test-Path $origenMd)) {
            Avisar "No encontré $origenMd"
            return
        }
        New-Item -ItemType Directory -Force -Path (Split-Path $destinoMd) | Out-Null
        if (Test-Path $destinoMd) {
            $respaldo = $destinoMd + '.respaldo-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
            Copy-Item $destinoMd $respaldo
            Write-Host "  respaldo del anterior: $respaldo" -ForegroundColor DarkGray
        }
        Copy-Item $origenMd $destinoMd -Force
    }
}

# -------------------------------- Final ---------------------------------
if (-not $SoloVer -and (Test-Path $temporal)) {
    Remove-Item $temporal -Recurse -Force
}

Titulo 'Listo'
if ($avisos.Count -gt 0) {
    Write-Host "Terminó con $($avisos.Count) aviso(s):" -ForegroundColor Yellow
    $avisos | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
} elseif ($SoloVer) {
    Write-Host 'Eso es lo que haría. Para instalar de verdad, correlo sin -SoloVer.'
} else {
    Write-Host 'Todo instalado.' -ForegroundColor Green
}
Write-Host ''
Write-Host 'Después:'
Write-Host '  1. Reiniciá Claude Code para que cargue plugins, skills y la variable.'
Write-Host '  2. Revisá en el CLAUDE.md la ruta del cerebro (asume C:\Users\Usuario\Desktop\cerebros del monarca).'
Write-Host '  3. banana-claude necesita tu clave de Google en la variable GOOGLE_AI_API_KEY (no se guarda en este repo).'
