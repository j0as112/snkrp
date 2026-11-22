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
- **Brazo cortado**: no se usa `ManipulateBoneScale` (escalar huesos deja el brazo largo y "fino"). En el cliente, un callback `BuildBonePositions` encoge todos los huesos del antebrazo hacia el codo con el factor `FactorBrazo` (0 recien cortado, crece hasta 1 al regenerar). La duracion va en red (`DurBrazoI/D`). El vapor del brazo sale a lo largo del trozo que crece, para tapar el muñon.
- **Derribo**: el cliente mostraba al titan de pie al acabar la caida. El servidor manda el ciclo en `CicloDerribo` y el cliente lo impone en `Draw` (secuencia `titan_dying`, ritmo 0) mientras `GetDerribado()`.
- **Caja baja, trazos altos**: la caja de colision es baja para navegar; `SetSurroundingBounds` cubre todo el modelo para que ganchos y balas toquen cabeza y nuca.
- **Nuca facil**: radio mayor, ayuda al tajo (cuenta pasar cerca con el cuerpo), gana siempre a otras partes, solo se rechaza de frente y desde abajo, y un tajo con algo de velocidad mata. Derribado, el daño a la nuca se duplica. El anclaje automatico clava los ganchos junto a la nuca (sujetos al hueso del cuello) si miras hacia un titan, y fijar un titan fija la nuca salvo que apuntes con precision a otra parte.
- No usar caracteres no ASCII en nombres de funcion.

## Despliegue
Codigo en el repo/servidor, contenido en la Workshop (ver CLAUDE.md). La Workshop no debe incluir `lua/`.

- **El servidor tambien necesita los modelos.** `resource.AddWorkshop` solo los manda a los clientes. Si el servidor no tiene `models/hydralis_titan*.mdl`, el titan no tiene secuencias ni huesos: se ve congelado, sin ninguna animacion, y los cortes por huesos fallan. Al iniciar sale el aviso `[SNK Titanes] El servidor no tiene los modelos de titan`.
- Servidor de pruebas local: el contenido se monta con enlaces en `garrysmod/addons/`: `snk_contenido_titanes` → `Desktop\SNKtitanes` y `snk_contenido_armas` → `Desktop\SNKarmas`.
- Servidor alquilado: hay que montar la coleccion de la Workshop en el servidor (`+host_workshop_collection` con su clave de API) o subir el contenido a `addons/`.
