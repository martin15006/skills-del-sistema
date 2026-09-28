# Segundo cerebro de Martín (Obsidian)

Martín tiene un **"segundo cerebro"** (base de conocimiento central) en el vault de Obsidian:
`C:\Users\Usuario\Desktop\cerebros del monarca\`

Es donde acumula TODO su conocimiento y proyectos. **Cualquier sesión/chat, en cualquier proyecto, debe conocerlo y trabajar en él cuando aplique.**

## Qué hacer (en cualquier chat)
- Cuando hagamos algo que valga la pena recordar (un proyecto, algo que aprende, decisiones, avances), **documentarlo en el cerebro**.
- Antes de escribir, leer la guía `Como funciona este cerebro.md` y el hub `Inicio.md` del vault, para **respetar el sistema y no desordenarlo**.
- Poner cada cosa en su lugar; si el tema no tiene apartado, **crearle su propia nota/carpeta** y enlazarla desde el índice que corresponda:
  - `Proyectos/` → proyectos (índice `[[Proyectos]]`)
  - `Aprendizaje/` → temas que aprende, ej. `[[ADB]]` (índice `[[Aprendizaje]]`)
  - `Bitacora/` → diario por fecha (`YYYY-MM-DD.md`): qué se hizo, qué aprendió, próximos pasos
  - `Recursos/` → herramientas, enlaces, chuletas
  - `libros/` → lecturas / manhwa
- Formato **Obsidian**: frontmatter, `[[wikilinks]]` (enlazar liberalmente), callouts `> [!tipo]`. Todo **ordenado y conectado**.
- Las skills de Obsidian están en `.claude/skills/` del vault (se activan al editar archivos bajo esa ruta); usar `obsidian-markdown` al escribir notas.

> Regla de oro: el cerebro debe quedar **siempre ordenado**. Si algo no encaja, crea/ajusta su apartado en vez de improvisar.

# Identidad propia: nunca copiar, siempre crear

Cuando un proyecto de Martín (o cualquier referencia) sirva de inspiración, se toma **el nivel de ambición y el oficio, nunca los elementos**. Cada cosa nueva lleva **identidad propia**: nombre, paleta, tipografía, metáfora y **estructura** distintos.

- **Prueba antes de entregar:** ponelo mentalmente al lado de la referencia. Si el parecido salta a la vista, no hay identidad propia — hay un reskin.
- **Cambiar la estructura y la metáfora pesa más que cambiar la paleta.** Un calco con otros colores sigue siendo el mismo proyecto.
- Los **nombres, títulos y lemas** también cuentan: dos proyectos suyos no pueden llamarse casi igual.
- Sí se conservan los elementos que Martín **pidió explícitamente**, pero dándoles otro papel dentro del concepto nuevo.
- **¿Sin ideas?** Buscar referencias reales en internet, o preguntarle. Nunca copiar por comodidad ni quedarse quieto.

> Un calco se ve feo y se siente plagio, aunque la fuente sea un proyecto del propio Martín. La consigna es animarse a crear cosas nuevas.

# Selección automática de skills (no esperar que Martín la nombre)

Las skills se auto-activan por su `description`; Martín **no** tiene que decir "usá tal skill". Cuando varias se solapan, **elegir la mejor y avisar en UNA línea cuál y por qué** antes de arrancar (ej. *"Uso impeccable porque es rediseño general de UI"*). Precedencia cuando hay empate:

- **Diseño general de UI / web / componentes / landing / dashboard** → `impeccable` (primaria, la más completa). `frontend-design` solo como respaldo liviano si impeccable no aplica.
  - Sus hooks están activos (revisan el diseño después de cada edición de interfaz), salvo en refugio-torre. La carpeta **`.impeccable/`** que crea en cada proyecto **nunca se sube**: ya está en el gitignore global de esta PC (`~/.config/git/ignore`), y si un proyecto no la tiene en su `.gitignore`, agregá `.impeccable/`.
- **Animación / motion / micro-interacciones / "que se sienta bien"** → `emil-design-eng` (fuente original de Emil Kowalski). Para **auditar** animaciones ya hechas → `review-animations`.
- **Un estilo concreto pedido** (brutalista, minimalista, soft, brandkit) o **imagen→código** → `taste-skill`.
- **Cualquier cosa con pantalla** (probar una app o un servidor que levanté, login, formularios, verificar un cambio de UI, abrir o buscar en una web) → **`navegador-visible`**: ventana real de Chrome en el escritorio de Martín. Le gana al panel Browser integrado, a Claude Preview y al MCP de Playwright, porque esos corren donde Martín no mira. Una vez abierta la ventana, **toda** la prueba sigue en ella hasta el final. Excepción: el bucle de agentes del juego (bot y Crítico de refugio-torre) usa Playwright a propósito, en un navegador aparte.
- **Trabajo con acuerdo escrito** (funcionalidad mediana en un proyecto existente, proyecto o versión nueva, "hagamos el pacto", historias de usuario y criterios, retomar o sellar un pacto) → **`pacto-skill`**. En ese trabajo le gana a `writing-plans`, `executing-plans` y `subagent-driven-development`: las obligaciones del pacto son el plan. `brainstorming` va antes solo si la idea todavía está verde. No se usa para cambios chicos, bugs sueltos ni en refugio-torre (tiene su bucle de agentes).

> Si dos skills siguen empatadas tras esto, elegir la más específica a la tarea y decirlo. Nunca quedarse trabado preguntando cuál usar.
