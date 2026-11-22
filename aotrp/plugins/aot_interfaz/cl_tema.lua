-- Paleta y utilidades comunes de la interfaz AoT. Se leen desde cl_skin.lua y desde otros plugins.
-- Inspiracion: Cuerpo de Exploracion (verde y cuero), acero de las hojas, rojo sangre y el oro de las alas.

ix.aotUI = ix.aotUI or {}

local UI = ix.aotUI

UI.verde = Color(47, 74, 58)
UI.verdeOsc = Color(14, 21, 17)
UI.cuero = Color(92, 64, 40)
UI.pergamino = Color(217, 201, 163)
UI.acero = Color(138, 146, 155)
UI.sangre = Color(140, 28, 28)
UI.alas = Color(44, 79, 124)
UI.oro = Color(196, 160, 80)

-- Color base de Helix (lo usan las barras de titulo, bordes, etc.).
ix.config.SetDefault("color", UI.verde)

local FUENTE_TITULO = "Georgia"

surface.CreateFont("aotTitulo", {font = FUENTE_TITULO, size = ScreenScale(22), weight = 800, extended = true})
surface.CreateFont("aotSubtitulo", {font = FUENTE_TITULO, size = ScreenScale(9), weight = 500, italic = true, extended = true})

-- Esquinas en "L": da el aire de plancha militar a los paneles.
function UI.Marco(x, y, w, h, col, largo)
	col = col or UI.oro
	largo = largo or 10

	surface.SetDrawColor(col)

	surface.DrawRect(x, y, largo, 2)
	surface.DrawRect(x, y, 2, largo)
	surface.DrawRect(x + w - largo, y, largo, 2)
	surface.DrawRect(x + w - 2, y, 2, largo)
	surface.DrawRect(x, y + h - 2, largo, 2)
	surface.DrawRect(x, y + h - largo, 2, largo)
	surface.DrawRect(x + w - largo, y + h - 2, largo, 2)
	surface.DrawRect(x + w - 2, y + h - largo, 2, largo)
end

-- Fondo oscuro verdoso con filete exterior de acero.
function UI.Plancha(x, y, w, h, alfa)
	alfa = alfa or 200

	surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, alfa)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(UI.acero.r, UI.acero.g, UI.acero.b, 60)
	surface.DrawOutlinedRect(x, y, w, h)
end

-- Dibujo compartido (menu de bienvenida y seleccion de personaje).
-- Degradado vertical por bandas (no depende de texturas del motor).
function UI.Degradado(x, y, w, h, c1, c2, pasos)
	pasos = pasos or 40

	for i = 0, pasos - 1 do
		local f = i / (pasos - 1)

		surface.SetDrawColor(Lerp(f, c1.r, c2.r), Lerp(f, c1.g, c2.g), Lerp(f, c1.b, c2.b), 255)
		surface.DrawRect(x, y + h * i / pasos, w, math.ceil(h / pasos) + 1)
	end
end


-- Fondo del diorama de estudio: cielo de tormenta con resplandor, muralla y suelo.
function UI.FondoEstudio(w, h)
	local horizonte = h * 0.58

	-- cielo: verde azulado oscuro arriba, ocre rojizo cerca del horizonte
	UI.Degradado(0, 0, w, horizonte, Color(26, 40, 38), Color(138, 82, 52), 48)

	-- sol bajo detras de la muralla
	draw.NoTexture()

	for r = 6, 1, -1 do
		surface.SetDrawColor(255, 170, 90, 9)
		surface.DrawTexturedRectRotated(w * 0.5, horizonte - h * 0.03, w * 0.16 * r, h * 0.16 * r, 0)
	end

	-- muralla: franja con juntas de bloques
	local alto = h * 0.12

	surface.SetDrawColor(52, 58, 56, 255)
	surface.DrawRect(0, horizonte - alto, w, alto)

	surface.SetDrawColor(30, 34, 33, 255)

	for fila = 1, 3 do
		surface.DrawRect(0, horizonte - alto + alto * fila / 4, w, 2)
	end

	for col = 0, math.ceil(w / 110) do
		surface.DrawRect(col * 110 + ((col % 2) * 55), horizonte - alto, 2, alto)
	end

	surface.SetDrawColor(120, 124, 120, 200)
	surface.DrawRect(0, horizonte - alto, w, 3)

	-- suelo
	UI.Degradado(0, horizonte, w, h - horizonte, Color(34, 44, 38), Color(12, 16, 14), 36)

	-- niebla baja
	surface.SetDrawColor(190, 200, 190, 18)
	surface.DrawRect(0, horizonte - 6, w, h * 0.08)
end


-- Logo de SNKRP: se descarga una vez de la pagina de carga y se guarda en data/ (los clientes no reciben
-- materiales sueltos del servidor). UI.Logo() devuelve el material, o nil si aun no esta.
local LOGO_URL = "https://j0as112.github.io/snkrp/logo.jpg"
local LOGO_ARCHIVO = "snkrp_logo.jpg"

function UI.Logo()
	if (UI.logoMaterial) then return UI.logoMaterial end

	if (file.Exists(LOGO_ARCHIVO, "DATA")) then
		UI.logoMaterial = Material("data/" .. LOGO_ARCHIVO, "smooth")

		if (UI.logoMaterial and UI.logoMaterial:IsError()) then UI.logoMaterial = nil end

		return UI.logoMaterial
	end

	if (!UI.logoPedido) then
		UI.logoPedido = true

		http.Fetch(LOGO_URL, function(cuerpo, tamano, cabeceras, codigo)
			if (codigo == 200 and tamano > 1000) then
				file.Write(LOGO_ARCHIVO, cuerpo)
			end
		end, function() end)
	end
end

UI.Logo()

-- Imagen de fondo del menu de bienvenida (publicada con la pantalla de carga). Se descarga una vez a data/.
-- El numero del nombre del archivo es la version: si se cambia la imagen, se sube el numero para que los
-- clientes descarguen la nueva.
local FONDO_URL = "https://j0as112.github.io/snkrp/pantalla.jpg"
local FONDO_ARCHIVO = "snkrp_pantalla_v1.jpg"

function UI.Fondo()
	if (UI.fondoMaterial) then return UI.fondoMaterial end

	if (file.Exists(FONDO_ARCHIVO, "DATA")) then
		UI.fondoMaterial = Material("data/" .. FONDO_ARCHIVO, "smooth")

		if (UI.fondoMaterial and UI.fondoMaterial:IsError()) then UI.fondoMaterial = nil end

		return UI.fondoMaterial
	end

	if (!UI.fondoPedido) then
		UI.fondoPedido = true

		http.Fetch(FONDO_URL, function(cuerpo, tamano, cabeceras, codigo)
			if (codigo == 200 and tamano > 5000) then
				file.Write(FONDO_ARCHIVO, cuerpo)
			end
		end, function() end)
	end
end

-- Dibuja la imagen cubriendo toda la pantalla (16:9 recortada si hace falta). Devuelve false si aun no esta.
function UI.DibujarFondoImagen(w, h)
	local material = UI.Fondo()

	if (!material) then return false end

	local escala = math.max(w / 16, h / 9)
	local dw, dh = 16 * escala, 9 * escala

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(material)
	surface.DrawTexturedRect((w - dw) / 2, (h - dh) / 2, dw, dh)

	return true
end

UI.Fondo()
