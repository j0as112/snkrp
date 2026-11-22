---
tags: [addon, titanes]
depende: [SNKarmas]
---
# Titanes (`addons/SNKtitanes`)

- Nextbots `aot_titan` (solo camina) y `aot_titan_aberrante` (corre; algunos reptan). Sin saltos.
- Ataque: agarra (y lo lleva a la boca) o da un manotazo que lanza y hiere; el pie hace pisoton al tocar el suelo (aplasta si esta justo debajo).
- Partes (nuca, ojos, brazos, tendones) se resuelven por huesos en `SNKarmas/lua/aot/sh_partes.lua`.

## Gotchas
- **`GetActivity()` no es fiable**: con estos modelos devolvia un valor distinto de `ACT_WALK` y `Animar` reiniciaba la secuencia cada tick (camina congelado). Se usa `self.AOT_Anim` y secuencias por nombre.
- Las secuencias no tienen velocidad de suelo: el ritmo se calcula con la velocidad real (`BodyUpdate`).
- **Alcance**: el titan mide 5-9 veces al jugador; medir en 3D desde el pecho deja fuera a quien esta a sus pies. Se mide en horizontal (`EnAlcance`/`DistPlano`).
- **Colision con jugadores**: si el jugador queda dentro de la caja del titan, se bugea. Los jugadores atraviesan titanes mediante el hook `ShouldCollide` (+ `SetCustomCollisionCheck`). **No cambiar el `CollisionGroup` del nextbot**: `DEBRIS_TRIGGER` y `PASSABLE_DOOR` lo hacen caer atravesando el suelo.
- Altura de salto = altura de paso para que el navegador nunca salte.
- No usar caracteres no ASCII en nombres de funcion.

## Despliegue
Codigo en el repo/servidor, contenido en la Workshop (ver CLAUDE.md). La Workshop no debe incluir `lua/`.

- **El servidor tambien necesita los modelos.** `resource.AddWorkshop` solo los manda a los clientes. Si el servidor no tiene `models/hydralis_titan*.mdl`, el titan no tiene secuencias ni huesos: se ve congelado, sin ninguna animacion, y los cortes por huesos fallan. Al iniciar sale el aviso `[SNK Titanes] El servidor no tiene los modelos de titan`.
- Servidor de pruebas local: el contenido se monta con enlaces en `garrysmod/addons/`: `snk_contenido_titanes` → `Desktop\SNKtitanes` y `snk_contenido_armas` → `Desktop\SNKarmas`.
- Servidor alquilado: hay que montar la coleccion de la Workshop en el servidor (`+host_workshop_collection` con su clave de API) o subir el contenido a `addons/`.
