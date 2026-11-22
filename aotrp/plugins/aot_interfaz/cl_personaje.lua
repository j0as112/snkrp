-- Estilo AoT del contenedor del menu de personaje y de los botones de menu de Helix.
-- El menu de bienvenida (crear/continuar/salir) esta en cl_menu_principal.lua y la seleccion en cl_seleccion.lua.

local UI = ix.aotUI

local gradienteIzq = surface.GetTextureID("vgui/gradient-l")
local gradienteAbajo = surface.GetTextureID("vgui/gradient-d")
local gradienteArriba = surface.GetTextureID("vgui/gradient-u")

-- Botones del menu de personaje (crear, cargar...): filete dorado a la izquierda al pasar el raton.
local BOTON = vgui.GetControlTable("ixMenuButton")

if (BOTON) then
	function BOTON:PaintBackground(width, height)
		local f = self.currentBackgroundAlpha / math.max(self.backgroundAlpha, 1)

		if (f > 0) then
			surface.SetDrawColor(UI.verde.r, UI.verde.g, UI.verde.b, 190 * f)
			surface.SetTexture(gradienteIzq)
			surface.DrawTexturedRect(0, 0, width, height)

			surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 255 * f)
			surface.DrawRect(0, 0, 3, height)
		end
	end
end

-- ===== Fondo del contenedor del menu de personaje =====
local CONTENEDOR = vgui.GetControlTable("ixCharMenu")

if (CONTENEDOR) then
	function CONTENEDOR:Paint(width, height)
		-- Con la camara real del mapa (seleccion de personaje) el mundo tiene que verse detras.
		local sel = ix.aotUI.panelSeleccion

		if (IsValid(sel) and sel:IsVisible() and sel.modoMundo) then return end

		surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 255)
		surface.DrawRect(0, 0, width, height)

		-- niebla verde desde la izquierda
		surface.SetDrawColor(UI.verde.r, UI.verde.g, UI.verde.b, 110)
		surface.SetTexture(gradienteIzq)
		surface.DrawTexturedRect(0, 0, width, height)

		-- resplandor rojizo en la parte baja (la ciudad en llamas)
		surface.SetDrawColor(UI.sangre.r, UI.sangre.g, UI.sangre.b, 55)
		surface.SetTexture(gradienteArriba)
		surface.DrawTexturedRect(0, height * 0.55, width, height * 0.45)

		-- muralla
		surface.SetDrawColor(0, 0, 0, 120)
		surface.DrawRect(0, height * 0.86, width, height * 0.14)
		surface.SetDrawColor(UI.acero.r, UI.acero.g, UI.acero.b, 45)
		surface.DrawRect(0, height * 0.86, width, 2)

		-- viñeta
		surface.SetDrawColor(0, 0, 0, 170)
		surface.SetTexture(gradienteAbajo)
		surface.DrawTexturedRect(0, 0, width, height * 0.22)
	end

	function CONTENEDOR:PaintOver(width, height)
		if (self.bClosing and self.bFromMenu) then
			surface.SetDrawColor(color_black)
			surface.DrawRect(0, 0, width, height)
		end
	end
end

-- Si el menu ya estaba abierto al recargar el plugin, se recrea con el aspecto nuevo.
if (IsValid(ix.gui.characterMenu)) then
	ix.gui.characterMenu:Remove()
	ix.gui.characterMenu = vgui.Create("ixCharMenu")
end
