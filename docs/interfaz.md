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

## Menu de bienvenida (`cl_menu_principal.lua`)
Lo primero que se ve al conectar (Nuevo soldado / Continuar / Comunidad / Abandonar), hecho como el de Naruto: una **pagina HTML a pantalla completa** (DHTML) con escena de fondo (cielo de tormenta, sol bajo, muralla, niebla y ceniza flotando en un canvas) y un **panel de cristal** con el logo de SNKRP, el titulo, el lema y botones con barra dorada animada. Lua solo conecta los botones: `gmod.Trigger('new'|'load'|'community'|'exit')` y `gmod.Hover()` (sonido).
- Sustituye a `ixCharMenuMain` y mantiene el contrato con Helix: `Dim/Undim`, `loadButton:SetDisabled` (compat), `UpdateReturnButton` y `bUsingCharacter` ("Abandonar" si no hay personaje activo, "Volver al juego" si lo hay).
- "Continuar" se desactiva si no hay personajes. "Comunidad" solo sale si `communityURL` esta configurado.
- El logo se carga de `https://j0as112.github.io/snkrp/logo.jpg`; si falla, solo se ve el texto.
- `cl_personaje.lua` queda para el fondo del contenedor y el estilo de `ixMenuButton`.

## Seleccion de personaje con escena 3D (`cl_seleccion.lua`, `sv_seleccion.lua`)
Sustituye a `ixCharMenuLoad` de Helix siguiendo la seleccion de Naruto: los personajes de la cuenta salen de pie delante de una camara, 3 por pagina; el raton resalta, clic elige, la X del rotulo borra (con confirmacion) y las flechas pasan de pagina.
- **Modo mundo:** la camara es un rincon real del mapa. El staff (superadmin) se coloca mirando donde quiera y usa `/SeleccionCamara [distancia] [separacion] [fov]`; se guarda **por mapa** (`ix.data` `seleccionEscena`) y `/SeleccionBorrar` la quita. El servidor mete el punto en el PVS del jugador sin personaje (`SetupPlayerVisibility`). Los huecos se calculan delante de la camara, sobre el suelo (traza hacia abajo).
- **Modo estudio** (mapa sin camara guardada): diorama AoT con luz de estudio, suelo y muralla.
- Elegir = `ixCharacterChoose`; borrar = `ixCharacterDelete`; el resto del flujo (crear, volver) sigue siendo el de Helix.
- Los modelos se escalan con la `altura` del personaje.

## Pantalla de carga (despliegue)
GMod solo acepta una URL **https**. Se publica con GitHub Pages mediante el workflow `.github/workflows/pages.yml` (origen "GitHub Actions"), que despliega `web/loading` cada vez que cambia: **https://j0as112.github.io/snkrp/**. En `cfg/server.cfg` (fuera de git): `sv_loadingurl "https://j0as112.github.io/snkrp/"`; hace falta reiniciar. El logo va incrustado en el HTML (`logo.jpg` es la copia original).

## Gotchas
- **Sin probar en juego** al escribirlo (22/11/2026): se valido la sintaxis y el HTML en navegador. Si algun panel se ve raro, el primer sospechoso es una firma de funcion de skin distinta a la de Helix (`gamemodes/helix/gamemode/core/cl_skin.lua`).
- Solo se pinta; no hay logica. Los botones del menu y el inventario HTML/derma de Helix mantienen su distribucion; lo que cambia es el estilo.
- La fuente es `Georgia` (Windows). Si faltara en un cliente, GMod usa una por defecto.
- Pendiente (siguiente iteracion): accesorios en la seleccion, HUD propio con retrato, inventario con diseno propio, intro de Helix personalizada.
