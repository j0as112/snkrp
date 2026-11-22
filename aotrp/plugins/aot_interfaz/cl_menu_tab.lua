-- Menu del tabulador (inventario, personaje, ajustes...) con el estilo AoT minimalista del menu de bienvenida.
-- Mantiene la estructura de Helix (ixMenu: botones a la izquierda y paneles a la derecha) y solo cambia el
-- aspecto: tipografia fina, pestanas de texto con barra dorada, fondo degradado y marca arriba.

local UI = ix.aotUI

-- Fuente fina en todos los botones de menu de Helix (los del menu de personaje tambien).
local BOTON = vgui.GetControlTable("ixMenuButton")

if (BOTON and !BOTON.aotFuente) then
	local initOriginal = BOTON.Init

	function BOTON:Init()
		if (initOriginal) then initOriginal(self) end

		self:SetFont("aotMenuBoton")
	end

	BOTON.aotFuente = true
end

-- Pestanas del menu: sin relleno de color, solo un velo sutil y una barra dorada a la izquierda.
local SELECCION = vgui.GetControlTable("ixMenuSelectionButton")

if (SELECCION) then
	function SELECCION:PaintBackground(ancho, alto)
		local f = self.selected and 1 or (self.currentBackgroundAlpha / math.max(self.backgroundAlpha or 128, 1))

		if (f <= 0.01) then return end

		surface.SetDrawColor(255, 255, 255, 10 * f)
		surface.DrawRect(0, 0, ancho, alto)

		surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 255 * f)
		surface.DrawRect(0, 0, 3, alto * f)
	end
end

-- Deja sitio arriba para la marca "SNK RP" que pinta el skin.
local MENU = vgui.GetControlTable("ixMenu")

if (MENU and !MENU.aotMargen) then
	local initOriginal = MENU.Init

	function MENU:Init()
		initOriginal(self)

		if (IsValid(self.tabs)) then
			self.tabs:DockMargin(0, ScreenScale(18), 0, 0)
		end
	end

	MENU.aotMargen = true
end
