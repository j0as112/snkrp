---
tags: [addon, armas]
---
# 3DMG (`addons/SNKarmas`, SWEP `aot_odm`)

- **Equipo visible en el cuerpo:** `SWEP:DibujarEquipo` pega los modelos (`SWEP.WElements`: cintura `hatana/snk_gear_*` y dos espadas `olddeath/w_snk_sword`) a los huesos del portador (`ValveBiped.Bip01_Spine`, `_R_Hand`, `_L_Hand`). Lo llama el hook `PostPlayerDraw` (`AOT_Equipo3DMG`): la cintura se ve siempre que el jugador lleve el SWEP, y las espadas solo cuando lo tiene en la mano y las hojas no estan rotas.
- **Gotcha:** `DrawWorldModel` solo se ejecuta para el arma **activa**; antes el equipo se dibujaba solo ahi y no se veia con otra cosa en la mano.
- Los modelos y materiales estan en la Workshop `SNK Armas`; los modelos de jugador (`models/j0as/aotrp`) tienen los huesos necesarios. Las posiciones de `WElements` estan ajustadas a los modelos antiguos: si algo queda desplazado en los nuevos, se retoca `pos`/`angle` ahi.
- **Gas:** el consumo se controla con `aotGasConsumo` (Helix, categoria "Attack on Titan"), por defecto 0,3.
