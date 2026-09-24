# Inventario de Skills del Sistema: lo leen instalar.ps1 y revisar.ps1.
# Editar acá cuando se agregue o se quite algo (y actualizar el README).

$marketplaces = @(
    'anthropics/claude-plugins-official',
    'pbakaus/impeccable',
    'leonxlnx/taste-skill',
    'vercel-labs/agent-browser',
    'coreyhaines31/marketingskills',
    'AgriciDaniel/banana-claude',
    'trailofbits/skills',
    'briiirussell/cybersecurity-skills'
)

$plugins = @(
    'superpowers@claude-plugins-official',
    'frontend-design@claude-plugins-official',
    'playwright@claude-plugins-official',
    'context7@claude-plugins-official',
    'ralph-loop@claude-plugins-official',
    'remember@claude-plugins-official',
    'impeccable@impeccable',
    'taste-skill@taste-skill',
    'agent-browser@agent-browser',
    'marketing-skills@marketingskills',
    'banana-claude@banana-claude-marketplace',
    'testing-handbook-skills@trailofbits',
    'static-analysis@trailofbits',
    'semgrep-rule-creator@trailofbits',
    'insecure-defaults@trailofbits',
    'supply-chain-risk-auditor@trailofbits',
    'cybersecurity-skills@cybersecurity-skills'
)

# Skills sueltas: se copian a ~/.claude/skills/<Nombre> desde su repo, con el mismo nombre que usa el CLAUDE.md.
# Las propias (Propia = $true) tienen además su carpeta de repo en el Escritorio (RepoLocal).
$skillsSueltas = @(
    @{ Nombre = 'navegador-visible';        Repo = 'martin15006/navegador-visible';     Carpeta = 'skills/navegador-visible'; Propia = $true;  RepoLocal = 'navegador-visible' },
    @{ Nombre = 'pacto-skill';              Repo = 'martin15006/pacto-skill';           Carpeta = 'skills/pacto-skill';       Propia = $true;  RepoLocal = 'pacto-skill' },
    @{ Nombre = 'emil-design-eng';          Repo = 'emilkowalski/skills';               Carpeta = 'skills/emil-design-eng';   Propia = $false; RepoLocal = $null },
    @{ Nombre = 'review-animations';        Repo = 'emilkowalski/skills';               Carpeta = 'skills/review-animations'; Propia = $false; RepoLocal = $null },
    @{ Nombre = 'cybersecurity-codereview'; Repo = 'AgriciDaniel/claude-cybersecurity'; Carpeta = 'skills/cybersecurity';     Propia = $false; RepoLocal = $null }
)

# Bugs de agent-browser en Windows que navegador-visible esquiva. Cuando se cierren, se puede simplificar la skill.
$bugsVigilados = @(
    @{ Numero = 1407; Que = 'el comando que abre la ventana se cuelga si su salida pasa por un tubo' },
    @{ Numero = 1981; Que = 'set viewport da EOF con la ventana maximizada' }
)
