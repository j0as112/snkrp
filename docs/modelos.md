---
tags: [schema, modelos]
---
# Modelos de jugador por facción

`aotrp/schema/libs/sh_listamodelos.lua` (generado desde los modelos reales de la Workshop **SNK Modelos1/2/3**, ruta `models/j0as/aotrp/`):

| Facción | Lista | Contenido |
|---|---|---|
| Civiles | `AOTRP_MODELOS.civiles` | 45: camisa, campesinos, chaqueta, culto, burgueses/nobles, vestidos, invierno civil |
| Cuerpo de Cadetes | `.cadetes` | 12: cadete + entrenamiento |
| (instructores) | `.instructores` | 12: instructor + oficiales de entrenamiento (no asignada a ninguna facción; los asigna el staff) |
| Cuerpo de Exploración | `.exploracion` | 12: soldados + oficiales |
| Tropas de Guarnición | `.guarnicion` | 24: soldados + oficiales + comandante |
| Policía Militar | `.policia` | 12: soldados + oficiales |
| Maestro de rol | `.todos` | todos los jugables (+ invierno, VIP y Pixis) |

- `.invierno` (ropa de invierno de soldados), `.vip` (108 versiones VIP) y `.npc` (3) existen pero **no** se asignan a facciones.
- La lista antigua (`hydralis/kaouet`) ya no existe en la colección: causaba modelos de error. Las animaciones (`ix.anim.SetModelClass(...,"player")`) se registran en el propio `sh_listamodelos.lua`.
- Si se actualizan los modelos de la Workshop, hay que regenerar la lista (los nombres deben coincidir con los archivos reales).
