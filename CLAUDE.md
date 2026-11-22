# CLAUDE.md

Guia para Claude Code en este repositorio. Todo en **espanol**.

## Que es este repositorio

**SnkRP**: servidor de **Garry's Mod** (Source, AppID 4000) de rol de **Attack on Titan**, con el gamemode `aotrp` sobre **Helix**, mas dos addons propios:

- `aotrp/` — gamemode (schema Helix: `schema/` + `plugins/`). El servidor lo ve por enlace desde `D:\gmodserver\gmod\garrysmod\gamemodes\aotrp`.
- `addons/SNKarmas/` — nucleo AOT: 3DMG (`aot_odm`), partes del cuerpo del titan, HUD, cajas de suministros.
- `addons/SNKtitanes/` — titanes (`aot_titan`, `aot_titan_aberrante`, nextbots).
- `addons/*` (resto) — addons de terceros del servidor. `ulib` y `ulx` no se trackean (tienen su propio repo).
- `_desactivado_hp/` — herencia del servidor de Harry Potter (EternusRP), NO se carga. Solo referencia.

No hay build ni tests automaticos: se valida **en el juego**.

## Codigo en el servidor, contenido en la Workshop

- El **codigo** (`.lua`) de `SNKarmas` y `SNKtitanes` vive **solo en este repo** (`addons/SNKarmas`, `addons/SNKtitanes`). Las carpetas `SNKarmas` y `SNKtitanes` de `D:\gmodserver\gmod\garrysmod\addons\` son enlaces (junction) a ellas. Se edita ahi.
- La **Workshop** (coleccion "SNK Roleplay (servidor)", items 3844168113 Armas, 3844165113 Titanes, 3844163136/3844162594/3844162132 Modelos1-3) lleva **solo contenido**: modelos, materiales, sonidos, particulas. **Nunca `lua/`**: si no, se pisa con el codigo del servidor y se mezclan versiones.
- Los clientes reciben el contenido por `resource.AddWorkshop` (en `aotrp/gamemode/init.lua`) y el codigo desde el servidor.
- gmpublisher publica desde `C:\Users\r380\Desktop\SNKarmas` y `C:\Users\r380\Desktop\SNKtitanes`: esas carpetas contienen **solo contenido** (sin `lua/`) y se actualizan con el boton de gmpublisher solo cuando cambian los assets. Respaldo del codigo antiguo en `C:\Users\r380\Desktop\_respaldo_lua_snk` (ya esta en el repo; se puede borrar).

## Servidor de pruebas — REGLA DE ORO

- **Todo lo de SNK se prueba en el servidor de pruebas del usuario** (el que arranca desde su panel, puerto 27030, mapa por defecto `rp_shiganshina_tdv1`; Workshop 2795519670). 
- **Nunca abras servidores extra** (ni `srcds` en otro puerto, ni segundas instancias): se mezclan logs y se lia todo. Si no hay servidor arrancado, pidele al usuario que lo arranque.
- Nunca uses rcon contra el servidor ni toques sus procesos. Los logs se leen de `D:\gmodserver\gmod\garrysmod\logs\panel_consola.log`.
- Para recargar Lua de entidades/gamemode hace falta cambiar de mapa (`changelevel`) o reiniciar; pideselo al usuario.
- No dejes scripts de prueba dentro de `addons/` del servidor (los carga el servidor real). Si hace falta un script temporal, bórralo al terminar.

## Documentacion (`docs/`) — se mantiene en el MISMO cambio

- `docs/00-Indice.md` — punto de entrada. Lee la nota que necesites antes de tocar algo no trivial.
- `docs/titanes.md` — diseno, estados y trampas de los titanes (animacion, colision, alcance, pisoton).
- `docs/changelog.md` — **toda** modificacion lleva entrada, en el mismo commit.

### Changelog

Registro para jugadores, no tecnico: agrupa por dia (`## DD/MM/AAAA`, el mas nuevo arriba), un punto por cambio, **agrupando por funcionalidad** con sub-puntos. En espanol llano, **sin terminos tecnicos ni numeros** (di si sube o baja, nunca cuanto).

## Convenciones

- Identificadores y comentarios en espanol (sin acentos en nombres de comandos/variables nuevas). **No uses caracteres no ASCII en nombres de funciones Lua** (`Pisoton`, no `Pisotón`).
- Prefijos de fichero: `sh_` compartido, `sv_` servidor, `cl_` cliente.
- Los titanes: la animacion se controla por **nombre de secuencia** (`walk`, `run`, `grab_player`, `grab_player_idle`, `titan_dying`); no uses `GetActivity()` para decidir (no es fiable con estos modelos).

## Flujo Git

Remoto: `https://github.com/j0as112/snkrp` (`origin`). Rama de trabajo habitual: `main`.

1. **Un commit por cambio coherente**, hecho por Claude al cerrar el cambio. Nunca `git add -A`: anade solo los ficheros del cambio y comprueba con `git diff --cached --name-only`.
2. **No hagas `git push` sin que el usuario lo pida expresamente** (salvo la primera subida que ya pidio).
3. Para desarrollos largos: rama `dev/<slug-corto>`; pregunta *"¿Doy por cerrada esta iteracion y la mergeo a main?"* y **no mergees sin OK explicito**. Tras mergear, borra la rama (`-d`, nunca `-D`).
4. Mensajes de commit en espanol, sin acentos, sin conventional-commits: titulo concreto (~70 car.) + cuerpo con **que** y sobre todo **por que**.
5. Cierra con la linea `Co-Authored-By:` que corresponda.
6. En el mismo commit van la nota de `docs/` y la entrada de `docs/changelog.md`.

## Que NO esta en git

Binarios (`.mdl`, `.vtf`, `.wav`, `.bsp`, `.vpk`, `.gma`...), `data/`, `cfg/`, bases de datos y backups: ver `.gitignore`. Nunca fuerces su inclusion con `git add -f`.
