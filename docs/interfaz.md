---
tags: [plugin, cliente, ui]
---
# Interfaz AoT (`aotrp/plugins/aot_interfaz`)

Tema visual de Attack on Titan para Helix, replicando el metodo del servidor de Naruto (tema comun + skin de Helix + pantalla de carga web).

- **Paleta** (`cl_tema.lua`, `ix.aotUI`): verde del Cuerpo de Exploracion, cuero, pergamino, acero, rojo sangre, azul de las alas y oro. Helpers `ix.aotUI.Plancha` y `ix.aotUI.Marco` (esquinas en "L").
- **Skin** (`cl_skin.lua`): sobrescribe el skin `helix` (marcos, paneles, tooltips, fichas de entidad, barras, huecos de inventario, filas, fondos de seleccion/creacion de personaje, tira de pestanas del menu y pantalla de muerte "HAS CAIDO").
- **Barras**: vida y armadura se vuelven a registrar con la paleta AoT.
- El color base de Helix (`color`) por defecto es el verde (`schema/sh_config.lua`).
- **Pantalla de carga**: `web/loading/index.html` (HTML autonomo, sin recursos externos). Es lo que carga `sv_loadingurl`.

## Pantalla de carga (despliegue)
GMod solo acepta una URL **https**. Opciones: GitHub Pages del repo (carpeta `web/loading`) o Netlify. Cuando este alojada:
`sv_loadingurl "https://<url>/"` en `cfg/server.cfg` y reiniciar. Probar localmente abriendo el HTML en el navegador.

## Gotchas
- **Sin probar en juego** al escribirlo (22/11/2026): se valido la sintaxis y el HTML en navegador. Si algun panel se ve raro, el primer sospechoso es una firma de funcion de skin distinta a la de Helix (`gamemodes/helix/gamemode/core/cl_skin.lua`).
- Solo se pinta; no hay logica. Los botones del menu y el inventario HTML/derma de Helix mantienen su distribucion; lo que cambia es el estilo.
- La fuente es `Georgia` (Windows). Si faltara en un cliente, GMod usa una por defecto.
- Pendiente (siguiente iteracion): HUD propio con retrato, inventario y menu con diseno propio (como el DHTML de Naruto), intro de Helix personalizada.
