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
- **Navegacion por donde caben**: el navmesh esta hecho para personas. `lua/autorun/server/aot_titanes_nav.lua` mide cada zona (`AOT.MedirZona`: `techo` libre y `hueco` = anchura del eje mas estrecho) y `ENT:CosteNav` se pasa a `Path:Compute`: prohibe zonas con techo por debajo del 80 % de la altura del titan (interiores, arcos, arboles) o mas estrechas que su cuerpo (`RadioCuerpo` = 11 x escala), y encarece los callejones justos. Si la presa esta donde no cabe, va al punto accesible mas cercano (`DestinoAccesible`).
- **Edificios entidad**: el mapa `rp_shiganshina_tdv1` tiene unas 500 casas/tiendas/torres como `prop_dynamic` (solid 6, con `.phy`). Los trazos de los titanes usan `MASK_NPCSOLID` con un filtro que ignora jugadores, NPCs, nextbots y `prop_physics`, asi que ven tanto los brushes como estas casas.
- **Sin teletransportes a ciegas**: antes, al atascarse, el titan saltaba a un punto al azar (que podia estar dentro o detras de una casa). Ahora rodea el obstaculo (4 intentos) y solo como ultimo recurso se recoloca en una zona abierta del navmesh que se vea desde donde esta.
- No usar caracteres no ASCII en nombres de funcion.

## Navmesh
- Se genera con el comando `aot_nav_generar` (consola del servidor o superadmin). Activa `sv_cheats` solo mientras dura (marca en `data/aot_nav_trucos.txt`) y `nav_solid_props 1` para que las casas entidad cuenten como solidas.
- Siembra desde los spawns, los destinos de teletransporte y una rejilla de 1024 unidades sobre todo el suelo: en `rp_shiganshina_tdv1` los spawns estan en una sala aislada en lo alto (z 6761) y un `nav_generate` normal solo generaria esa sala.
- Tarda bastante en un mapa de este tamaño; al terminar el motor guarda `maps/<mapa>.nav` y recarga el mapa. Al cargar, las zonas se miden poco a poco y sale `[SNK Titanes] Navmesh analizado: N zonas.`
- El `.nav` no hace falta mandarlo a los clientes; en el servidor alquilado hay que copiarlo a su `maps/`.

## Despliegue
Codigo en el repo/servidor, contenido en la Workshop (ver CLAUDE.md). La Workshop no debe incluir `lua/`.

- **El servidor tambien necesita los modelos.** `resource.AddWorkshop` solo los manda a los clientes. Si el servidor no tiene `models/hydralis_titan*.mdl`, el titan no tiene secuencias ni huesos: se ve congelado, sin ninguna animacion, y los cortes por huesos fallan. Al iniciar sale el aviso `[SNK Titanes] El servidor no tiene los modelos de titan`.
- Servidor de pruebas local: el contenido se monta con enlaces en `garrysmod/addons/`: `snk_contenido_titanes` → `Desktop\SNKtitanes` y `snk_contenido_armas` → `Desktop\SNKarmas`.
- Servidor alquilado: hay que montar la coleccion de la Workshop en el servidor (`+host_workshop_collection` con su clave de API) o subir el contenido a `addons/`.

## Sin brazos
Un titan con los dos brazos cortados (o regenerandose) **no puede atacar**: `EnAlcance` devuelve false y `Atacar` se cancela si pierde los brazos a mitad. Solo persigue y pisa. Los tendones tienen menos vida (`22 + 2.5 * escala`) y un derribo dura como minimo 8 s.
