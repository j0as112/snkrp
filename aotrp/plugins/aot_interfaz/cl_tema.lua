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
