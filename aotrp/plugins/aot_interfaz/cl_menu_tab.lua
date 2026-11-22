-- Menu del tabulador (inventario, personaje, ajustes, ayuda...) con barra de pestanas arriba y panel a pantalla
-- completa, como el de Naruto pero con el estilo minimalista de AoT.
-- Por debajo se conserva el motor de Helix (ixMenu): crea las pestanas, los paneles, la vista 3D del personaje y el
-- inventario. Aqui solo se rehace el LAYOUT (columna izquierda -> barra superior) y el aspecto.

local UI = ix.aotUI

local ALTO_BARRA = ScreenScale(22)
local ALTO_SUB = ScreenScale(15)
local ALTO_TOP = ALTO_BARRA + ALTO_SUB

-- ===== Botones de menu de Helix: fuente fina, y pestanas minimalistas (las del menu de personaje) =====
local BOTON = vgui.GetControlTable("ixMenuButton")

if (BOTON and !BOTON.aotFuente) then
	local initOriginal = BOTON.Init

	function BOTON:Init()
		if (initOriginal) then initOriginal(self) end

		self:SetFont("aotMenuBoton")
	end

	BOTON.aotFuente = true
end

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

-- ===== Boton de texto de la barra =====
local function AnchoTexto(texto, fuente, espacio)
	surface.SetFont(fuente)

	local ancho = 0

	for _, codigo in utf8.codes(texto) do
		ancho = ancho + surface.GetTextSize(utf8.char(codigo)) + espacio
	end

	return ancho - espacio
end

-- origen: boton original de Helix que mantiene el estado "seleccionado" (opcional).
local function BotonBarra(padre, texto, fuente, espacio, padx, alto, origen, accion, peligro)
	local ancho = AnchoTexto(texto, fuente, espacio) + padx * 2
	local btn = vgui.Create("DButton", padre)

	btn:SetText("")
	btn:SetSize(ancho, alto)
	btn.f = 0

	local desfaseY = (fuente == "aotMenuBoton") and ScreenScale(5.6) or ScreenScale(2.8)

	function btn:Paint(w, h)
		local activo = origen and origen:GetSelected()

		self.f = Lerp(math.min(FrameTime() * 12, 1), self.f, activo and 1 or (self:IsHovered() and 0.6 or 0))

		local f = self.f
		local color = peligro and Color(Lerp(f, 170, 235), Lerp(f, 160, 95), Lerp(f, 160, 95)) or Color(Lerp(f, 140, 240), Lerp(f, 146, 240), Lerp(f, 150, 238))

		UI.TextoEspaciado(texto, fuente, w / 2, h / 2 - desfaseY, color, espacio, 1)

		if (f > 0.03) then
			local lw = (w - padx) * f

			surface.SetDrawColor(peligro and 216 or UI.oro.r, peligro and 80 or UI.oro.g, peligro and 80 or UI.oro.b, 230 * f)
			surface.DrawRect((w - lw) / 2, h - 3, lw, 2)
		end
	end

	function btn:DoClick()
		LocalPlayer():EmitSound("Helix.Press")
		accion()
	end

	function btn:OnCursorEntered()
		LocalPlayer():EmitSound("Helix.Rollover")
	end

	return btn
end

-- ===== Menu =====
local MENU = vgui.GetControlTable("ixMenu")

if (MENU and !MENU.aotBarraSuperior) then
	local initOriginal = MENU.Init

	-- Los paneles ocupan toda la pantalla, debajo de la barra.
	function MENU:GetStandardSubpanelSize()
		local pad = self:GetPadding()

		return ScrW() - pad * 2, ScrH() - ALTO_TOP - pad * 2
	end

	function MENU:Init()
		initOriginal(self)

		local pad = self:GetPadding()

		-- fuera la columna izquierda de Helix (sus botones se siguen usando por dentro)
		if (IsValid(self.buttons)) then self.buttons:SetVisible(false) end
		if (IsValid(self.guard)) then self.guard:SetVisible(false) end

		self:SetLeftOffset(0)
		self:SetSubpanelAnimationTime(0.2)

		self:CrearBarra()
		self:Recolocar()
	end

	-- Reajusta los paneles que Helix creo con el layout antiguo (a la derecha de la columna).
	function MENU:Recolocar()
		local pad = self:GetPadding()

		for _, sp in ipairs(self.subpanels) do
			if (IsValid(sp) and !sp.sectionParent) then
				sp:SetSize(self:GetStandardSubpanelSize())
			end

			if (IsValid(sp)) then
				local x = sp:GetPos()
				sp:SetPos(x, ALTO_TOP + pad)
			end
		end

		if (self.activeSubpanel) then
			self:SetSubpanelPos(self.activeSubpanel, pad)
		end
	end

	function MENU:CrearBarra()
		local pad = self:GetPadding()
		local anterior = self

		-- barra principal
		local barra = vgui.Create("Panel", self)
		barra:SetPos(0, 0)
		barra:SetSize(ScrW(), ALTO_BARRA)
		self.aotBarra = barra

		function barra:Paint(w, h)
			surface.SetDrawColor(0, 0, 0, 120)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 70)
			surface.DrawRect(0, h - 1, w, 1)

			UI.TextoEspaciado("SNK RP", "aotMenuBoton", pad, h / 2 - ScreenScale(5.6), Color(240, 240, 238), ScreenScale(2.2), 0)
		end

		-- pestanas centradas (cada una maneja el boton original de Helix)
		local botones = {}
		local total = 0

		for _, origen in ipairs(self.tabs.buttons) do
			if (IsValid(origen)) then
				local btn = BotonBarra(barra, origen:GetText(), "aotMenuBoton", ScreenScale(2), ScreenScale(10), ALTO_BARRA, origen, function()
					origen:OnMousePressed(MOUSE_LEFT)
				end)

				btn.origen = origen
				botones[#botones + 1] = btn
				total = total + btn:GetWide()
			end
		end

		local x = (ScrW() - total) / 2

		for _, btn in ipairs(botones) do
			btn:SetPos(x, 0)
			x = x + btn:GetWide()
		end

		-- a la derecha: Personajes y Volver
		local volver = BotonBarra(barra, "VOLVER", "aotMenuPequeno", ScreenScale(1.6), ScreenScale(8), ALTO_BARRA, nil, function()
			self:Remove()
		end, true)

		volver:SetPos(ScrW() - volver:GetWide() - pad * 0.5, 0)

		local personajes = BotonBarra(barra, "PERSONAJES", "aotMenuPequeno", ScreenScale(1.6), ScreenScale(8), ALTO_BARRA, nil, function()
			self:Remove()
			vgui.Create("ixCharMenu")
		end)

		personajes:SetPos(volver:GetPos() - personajes:GetWide(), 0)

		-- fila secundaria: secciones de la pestana activa (p. ej. los temas de Ayuda)
		local sub = vgui.Create("Panel", self)
		sub:SetPos(0, ALTO_BARRA)
		sub:SetSize(ScrW(), ALTO_SUB)
		self.aotSub = sub
		sub.botones = {}

		function sub:Reconstruir(origen)
			for _, b in ipairs(self.botones) do
				if (IsValid(b)) then b:Remove() end
			end

			self.botones = {}

			if (!IsValid(origen) or !IsValid(origen.sectionPanel)) then return end

			local lista = {}

			for _, hijo in ipairs(origen.sectionPanel:GetChildren()) do
				if (IsValid(hijo) and hijo.GetText and hijo.OnMousePressed) then lista[#lista + 1] = hijo end
			end

			local anchoTotal = 0
			local nuevos = {}

			for _, seccion in ipairs(lista) do
				local b = BotonBarra(self, seccion:GetText(), "aotMenuPequeno", ScreenScale(1.4), ScreenScale(7), ALTO_SUB, seccion, function()
					seccion:OnMousePressed(MOUSE_LEFT)
				end)

				nuevos[#nuevos + 1] = b
				anchoTotal = anchoTotal + b:GetWide()
			end

			local sx = (ScrW() - anchoTotal) / 2

			for _, b in ipairs(nuevos) do
				b:SetPos(sx, 0)
				sx = sx + b:GetWide()
			end

			self.botones = nuevos
		end

		-- cuando cambia la pestana activa se reconstruye la fila secundaria
		function barra:Think()
			local menu = self:GetParent()
			local activa

			for _, origen in ipairs(menu.tabs.buttons) do
				if (IsValid(origen) and origen:GetSelected()) then activa = origen break end
			end

			if (activa != self.activaAnterior) then
				self.activaAnterior = activa
				menu.aotSub:Reconstruir(activa)
			end
		end
	end

	MENU.aotBarraSuperior = true
end
