# Skills del Sistema

Mi setup completo de Claude Code, para rearmarlo en cualquier PC con un solo script.

> Repo **privado**: lleva mi CLAUDE.md global. Mis skills propias viven en sus repos públicos;
> acá está lo necesario para instalarlas todas junto con el resto.

## Qué hay adentro

| Archivo | Qué es |
|---|---|
| `instalar.ps1` | Script que rearma todo: marketplaces, plugins, skills, agent-browser y CLAUDE.md |
| `revisar.ps1` | Revisa qué hay que actualizar, sin cambiar nada |
| `inventario.ps1` | La lista de marketplaces, plugins y skills que usan los dos scripts |
| `claude/CLAUDE.md` | Mis instrucciones globales para Claude Code |

## Instalar en una PC nueva

**Requisitos:** Claude Code, Git, Node.js (con npm) y Google Chrome.

1. Clonar el repo (es privado: hace falta iniciar sesión con mi cuenta de GitHub).

   ```bash
   git clone https://github.com/martin15006/skills-del-sistema.git
   ```

2. Ver primero qué va a hacer, sin cambiar nada:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\instalar.ps1 -SoloVer
   ```

3. Instalar de verdad:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\instalar.ps1
   ```

4. Reiniciar Claude Code.

| Opción | Qué hace |
|---|---|
| `-SoloVer` | Muestra lo que haría, sin tocar nada |
| `-SinClaudeMd` | No reemplaza el CLAUDE.md global |

Se puede correr varias veces: lo que ya está instalado se saltea.

> **Ojo en la PC original:** el script reemplaza las skills sueltas por la versión que esté en
> GitHub. Si cambié una skill y todavía no la subí, primero subirla.

## Revisar si hay que actualizar algo

```powershell
powershell -ExecutionPolicy Bypass -File .\revisar.ps1
```

Solo mira, no cambia nada. Dice:

- si mis skills instaladas son iguales a las de GitHub, y si sus carpetas del Escritorio tienen
  cambios sin subir;
- si las skills de terceros cambiaron en su repo original;
- si hay versión nueva de agent-browser, y si ya cerraron los bugs que esquiva `navegador-visible`;
- cuándo se actualizó cada plugin;
- si la copia de `claude/CLAUDE.md` está al día, y si este repo sigue privado.

Para además buscar e instalar versiones nuevas de los plugins:

```powershell
powershell -ExecutionPolicy Bypass -File .\revisar.ps1 -ActualizarPlugins
```

> Una actualización de un plugin o una skill de terceros trae código nuevo que no revisé. Si
> alguno salta de versión grande, pedirle a Claude, en el chat de skills, que revise qué cambió.

## Inventario

### Mis skills

| Skill | Qué hace | Repo |
|---|---|---|
| `navegador-visible` | Probar todo lo que tenga pantalla en una ventana real de Chrome, narrando cada paso | [martin15006/navegador-visible](https://github.com/martin15006/navegador-visible) |
| `pacto-skill` | Acordar por escrito qué se construye, construirlo en tandas y sellarlo probando criterio por criterio | [martin15006/pacto-skill](https://github.com/martin15006/pacto-skill) |

### Plugins de terceros (17, de 8 marketplaces)

| Plugin | Marketplace | Para qué |
|---|---|---|
| `superpowers` | claude-plugins-official | Planificación, debugging sistemático, TDD, revisión de código |
| `frontend-design` | claude-plugins-official | Diseño de interfaces (respaldo liviano) |
| `playwright` | claude-plugins-official | Navegador del bot y el Crítico del juego |
| `context7` | claude-plugins-official | Documentación actualizada de librerías |
| `ralph-loop` | claude-plugins-official | Bucles de trabajo autónomo |
| `remember` | claude-plugins-official | Memoria entre sesiones |
| `impeccable` | impeccable | Diseño de UI (principal) |
| `taste-skill` | taste-skill | Estilos concretos e imagen → código |
| `agent-browser` | agent-browser | Automatizar el navegador |
| `marketing-skills` | marketingskills | Copy, SEO y presentación |
| `banana-claude` | banana-claude-marketplace | Imágenes con Gemini (la API necesita facturación) |
| `testing-handbook-skills` | trailofbits | Handbook de testing de seguridad |
| `static-analysis` | trailofbits | CodeQL, Semgrep y SARIF |
| `semgrep-rule-creator` | trailofbits | Escribir reglas de detección |
| `insecure-defaults` | trailofbits | Credenciales y configuraciones inseguras |
| `supply-chain-risk-auditor` | trailofbits | Riesgo de dependencias |
| `cybersecurity-skills` | cybersecurity-skills | Playbooks de seguridad que explican lo que encuentran |

### Skills de terceros sueltas

Se bajan de su repo original y se copian con su licencia.

| Skill | Repo original | Carpeta |
|---|---|---|
| `emil-design-eng` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | `skills/emil-design-eng` |
| `review-animations` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | `skills/review-animations` |
| `cybersecurity-codereview` | [AgriciDaniel/claude-cybersecurity](https://github.com/AgriciDaniel/claude-cybersecurity) | `skills/cybersecurity` |

### Configuración

- `agent-browser` instalado global con npm.
- Variable de usuario `AGENT_BROWSER_HEADED=1`, para que toda ventana de agent-browser sea visible.
- Variable de usuario `DO_NOT_TRACK=1`: impeccable (y otras herramientas) no mandan avisos de uso.
- `.impeccable/` en el gitignore global (`~/.config/git/ignore`): la carpeta que crea impeccable
  en cada proyecto nunca se sube. Sus hooks quedan activos; en refugio-torre están apagados.
- CLAUDE.md global.

## Qué NO está (a propósito)

- **La memoria de Claude:** cambia todo el tiempo, tiene datos personales y rutas de esta PC.
- **Las skills de Obsidian:** viven dentro del vault y viajan con él.
- **Claves y secretos** (por ejemplo `GOOGLE_AI_API_KEY` para banana-claude): se ponen a mano.

## Cuando agregue o quite algo

1. Editar las listas de `inventario.ps1`.
2. Actualizar las tablas de este README.
3. Si cambió mi CLAUDE.md, copiar `~/.claude/CLAUDE.md` a `claude/CLAUDE.md`.
4. Commit y push.
