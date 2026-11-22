-- Seleccion de personaje con escena 3D (sustituye a "ixCharMenuLoad" de Helix). Mismo planteamiento que la de Naruto:
-- los personajes de la cuenta aparecen de pie delante de una camara, hasta 3 por pagina; pasar el raton los
-- resalta, clic elige, la X del rotulo borra y las flechas cambian de pagina.
--   * Modo mundo: la camara es un rincon real del mapa (/SeleccionCamara, la fija el staff y se guarda por mapa).
--   * Modo estudio (por defecto): diorama AoT con luz de estudio, suelo y muralla de fondo.
-- Contrato con ixCharMenu: SlideUp/SlideDown (ixCharMenuPanel), OnSlideUp, Populate, OnCharacterDeleted y
-- OnCharacterLoadFailed. Elegir envia ixCharacterChoose; borrar, ixCharacterDelete.

local UI = ix.aotUI

local MODELO_ERROR = "models/error.mdl"
local POR_PAGINA = 3
local gradienteAbajo = surface.GetTextureID("vgui/gradient-d")
local gradienteArriba = surface.GetTextureID("vgui/gradient-u")

-- Camara y huecos del diorama de estudio (camara en el origen mirando a +X; los personajes miran a la camara).
local ESTUDIO = {
	cam = {pos = Vector(0, 0, 52), ang = Angle(2, 0, 0), fov = 62},
	dist = 200,
	sep = 72
}

-- util.IsInWorld solo existe en el servidor: en el cliente se comprueba que el punto no esta dentro de un
-- solido y que hay suelo debajo (una camara en el vacio daba una pantalla negra).
local function CamaraValida(pos)
	if (!pos or bit.band(util.PointContents(pos), CONTENTS_SOLID) != 0) then return false end

	local tr = util.TraceLine({start = pos, endpos = pos - Vector(0, 0, 3000), mask = MASK_SOLID_BRUSHONLY})

	return tr.Hit and !tr.StartSolid
end

-- ===== Escena real del mapa (llega del servidor) =====
net.Receive("aot_SeleccionEscena", function()
	local t = net.ReadTable()

	ix.aotUI.escena = (t and t.cam and t.cam.pos) and t or nil

	if (IsValid(ix.aotUI.panelSeleccion)) then
		ix.aotUI.panelSeleccion:ActualizarModo()
	end
end)

-- La camara de la escena solo manda mientras el panel esta visible y hay escena guardada.
hook.Add("CalcView", "aot_SeleccionEscena", function(client, origen, angulos, fov)
	local panel = ix.aotUI.panelSeleccion

	if (!IsValid(panel) or !panel:IsVisible() or !panel.modoMundo or !ix.aotUI.escena) then return end

	local cam = ix.aotUI.escena.cam

	return {origin = cam.pos, angles = cam.ang, fov = cam.fov, drawviewer = false}
end)

-- ===== Figuras =====
local function AplicarPersonaje(modelo, personaje)
	modelo:SetModel(personaje:GetModel())
	modelo:SetSkin(personaje:GetData("skin", 0))

	for i = 0, (modelo:GetNumBodyGroups() - 1) do
		modelo:SetBodygroup(i, 0)
	end

	local grupos = personaje:GetData("groups", nil)

	if (istable(grupos)) then
		for k, v in pairs(grupos) do
			modelo:SetBodygroup(k, v)
		end
	end
end

local function PonerIdle(modelo)
	local secuencia = modelo:LookupSequence("idle_unarmed")

	if (secuencia <= 0) then secuencia = modelo:SelectWeightedSequence(ACT_IDLE) end

	if (secuencia <= 0) then
		for _, v in ipairs(modelo:GetSequenceList()) do
			if (v:lower():find("idle") and v != "idlenoise") then
				secuencia = modelo:LookupSequence(v)
				break
			end
		end
	end

	if (secuencia > 0) then modelo:ResetSequence(secuencia) end

	modelo:SetIK(false)
end

local function CrearFigura(personaje, pos, yaw)
	local m = ClientsideModel(MODELO_ERROR)
	if (!IsValid(m)) then return end

	m:SetNoDraw(true)
	AplicarPersonaje(m, personaje)
	PonerIdle(m)

	local altura = personaje.GetAltura and tonumber(personaje:GetAltura()) or 1
	if (altura and altura > 0.3) then m:SetModelScale(altura, 0) end

	m:SetPos(pos)
	m:SetAngles(Angle(0, yaw, 0))

	return {ent = m, personaje = personaje, id = personaje:GetID(), pos = pos, yaw = yaw, alto = 74 * (altura or 1)}
end

local function LimpiarFigura(fig)
	if (fig and IsValid(fig.ent)) then fig.ent:Remove() end
end

-- ===== Panel =====
local PANEL = {}

function PANEL:Init()
	-- por si el motor no encadena el Init de la clase base
	if (self.subpanels == nil) then
		local base = vgui.GetControlTable("ixCharMenuPanel")
		if (base and base.Init) then base.Init(self) end
	end

	local padding = ScreenScale(16)

	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)
	self:SetMouseInputEnabled(true)

	self.figuras = {}
	self.lista = {}
	self.page = 1
	self.botones = {}
	self.ultimo = RealTime()

	ix.aotUI.panelSeleccion = self

	self.volver = self:Add("ixMenuButton")
	self.volver:SetText("return")
	self.volver:SizeToContents()
	self.volver:SetPos(padding, ScrH() - self.volver:GetTall() - padding)
	-- Siempre hay una salida clara: "Continuar" elige el personaje resaltado (o el primero de la pagina).
	self.continuar = self:Add("ixMenuButton")
	self.continuar:SetText("choose")
	self.continuar:SizeToContents()
	self.continuar:SetPos(ScrW() - self.continuar:GetWide() - padding, ScrH() - self.continuar:GetTall() - padding)
	self.continuar.DoClick = function()
		local fig = self.hover or self.figuras[1]

		if (fig) then self:Elegir(fig.id) end
	end

	self.volver.DoClick = function()
		local menu = self:GetParent()

		self:SlideDown()

		if (IsValid(menu) and IsValid(menu.mainPanel)) then
			menu.mainPanel:Undim()
		end
	end
end

-- Salida de emergencia: Esc vuelve al menu.
function PANEL:Think()
	if (!self:IsVisible()) then return end

	local esc = input.IsKeyDown(KEY_ESCAPE)

	if (esc and !self.escAntes and IsValid(self.volver)) then
		self.volver:DoClick()
	end

	self.escAntes = esc
end

function PANEL:OnRemove()
	self:Limpiar()
	if (ix.aotUI.panelSeleccion == self) then ix.aotUI.panelSeleccion = nil end
end

function PANEL:Limpiar()
	for _, fig in ipairs(self.figuras) do LimpiarFigura(fig) end
	self.figuras = {}
	self.hover = nil
end

-- Camara y huecos segun el modo
function PANEL:Vista()
	if (self.modoMundo and ix.aotUI.escena) then
		return ix.aotUI.escena.cam, ix.aotUI.escena.dist or 190, ix.aotUI.escena.sep or 70, true
	end

	return ESTUDIO.cam, ESTUDIO.dist, ESTUDIO.sep, false
end

function PANEL:Huecos(n)
	local cam, dist, sep, mundo = self:Vista()
	local huecos = {}

	for i = 1, n do
		local lateral = (i - (n + 1) / 2) * sep
		local pos, yaw

		if (mundo) then
			local angulo = Angle(0, cam.ang.y, 0)
			pos = cam.pos + angulo:Forward() * dist - angulo:Right() * lateral
			local tr = util.TraceLine({start = pos + Vector(0, 0, 120), endpos = pos - Vector(0, 0, 500), mask = MASK_SOLID_BRUSHONLY})
			if (tr.Hit) then pos = tr.HitPos end
			yaw = cam.ang.y + 180
		else
			pos = Vector(dist, -lateral, 0)
			yaw = 180
		end

		huecos[i] = {pos = pos, yaw = yaw}
	end

	return huecos
end

function PANEL:Reunir()
	self.lista = {}

	for _, id in pairs(ix.characters or {}) do
		local c = ix.char.loaded[id]
		if (c) then table.insert(self.lista, c) end
	end

	table.sort(self.lista, function(a, b) return a:GetName():lower() < b:GetName():lower() end)
end

function PANEL:TotalPaginas()
	return math.max(1, math.ceil(#self.lista / POR_PAGINA))
end

function PANEL:Reconstruir()
	self:Limpiar()

	self.page = math.Clamp(self.page or 1, 1, self:TotalPaginas())

	local primero = (self.page - 1) * POR_PAGINA + 1
	local ultimo = math.min(self.page * POR_PAGINA, #self.lista)
	local n = ultimo - primero + 1

	if (n < 1) then return end

	local huecos = self:Huecos(n)

	for i = primero, ultimo do
		local h = huecos[i - primero + 1]
		local fig = CrearFigura(self.lista[i], h.pos, h.yaw)

		if (fig) then table.insert(self.figuras, fig) end
	end
end

function PANEL:ActualizarModo()
	local esc = ix.aotUI.escena
	local nuevo = esc != nil and !ix.aotUI.forzarEstudio and CamaraValida(esc.cam.pos) and self:IsVisible()
	local cambio = (nuevo != (self.modoMundo or false))

	self.modoMundo = nuevo

	if (cambio and self:IsVisible()) then self:Reconstruir() end
end

function PANEL:OnSlideUp()
	self:SetVisible(true)
	self:SetAlpha(255)
	self.page = 1
	self.nacido = SysTime()

	net.Start("aot_SeleccionEscena_Pedir")
	net.SendToServer()

	self:ActualizarModo()
	self:Reunir()
	self:Reconstruir()
end

function PANEL:OnSlideDown()
	self.modoMundo = false
	self:Limpiar()
end

function PANEL:Populate()
	self:Reunir()
	self:Reconstruir()
end

function PANEL:OnCharacterDeleted(personaje)
	self:Populate()

	if (#ix.characters == 0) then
		self:SlideDown()

		local menu = self:GetParent()
		if (IsValid(menu) and IsValid(menu.mainPanel)) then menu.mainPanel:Undim() end
	end
end

function PANEL:OnCharacterLoadFailed(error)
	if (IsValid(ix.gui.characterMenu)) then
		ix.gui.characterMenu:ShowNotice(3, error)
	end
end

function PANEL:Elegir(id)
	surface.PlaySound("helix/ui/press.wav")

	self:SlideDown(1, function()
		net.Start("ixCharacterChoose")
			net.WriteUInt(id, 32)
		net.SendToServer()
	end, true)
end

function PANEL:Borrar(id)
	surface.PlaySound("helix/ui/press.wav")

	Derma_Query(
		"¿Seguro que quieres eliminar este personaje? No se puede deshacer.",
		"Eliminar personaje",
		"Eliminar", function()
			id = tonumber(id)
			if (!id) then return end

			net.Start("ixCharacterDelete")
				net.WriteUInt(id, 32)
			net.SendToServer()

			if (ix.characters) then
				for k, v in ipairs(ix.characters) do
					if (v == id) then table.remove(ix.characters, k) break end
				end
			end

			if (IsValid(self)) then self:Populate() end
		end,
		"Cancelar"
	)
end

function PANEL:CambiarPagina(delta)
	local nueva = math.Clamp(self.page + delta, 1, self:TotalPaginas())

	if (nueva != self.page) then
		self.page = nueva
		self:Reconstruir()
		surface.PlaySound("helix/ui/rollover.wav")
	end
end

function PANEL:AnadirBoton(x, y, w, h, fn)
	self.botones[#self.botones + 1] = {x = x, y = y, w = w, h = h, fn = fn}
end

function PANEL:OnMousePressed(codigo)
	if (codigo != MOUSE_LEFT) then return end

	local mx, my = self:CursorPos()

	for _, b in ipairs(self.botones) do
		if (mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h) then
			b.fn()
			return
		end
	end

	if (self.hover and self.hover.id) then
		self:Elegir(self.hover.id)
	end
end

-- Luz de estudio: clave calida desde delante-arriba, contraluz azul detras.
local function Luz(mundo)
	render.SuppressEngineLighting(true)
	render.SetModelLighting(BOX_FRONT, 1.15, 1.0, 0.85)
	render.SetModelLighting(BOX_TOP, 0.9, 0.88, 0.8)
	render.SetModelLighting(BOX_LEFT, 0.4, 0.45, 0.5)
	render.SetModelLighting(BOX_RIGHT, 0.25, 0.35, 0.6)
	render.SetModelLighting(BOX_BACK, mundo and 0.3 or 0.25, mundo and 0.35 or 0.4, mundo and 0.45 or 0.7)
	render.SetModelLighting(BOX_BOTTOM, 0.12, 0.12, 0.12)
end

function PANEL:Paint(w, h)
	self.botones = {}

	local ahora = RealTime()
	local dt = ahora - self.ultimo
	self.ultimo = ahora

	local vista, _, _, mundo = self:Vista()

	if (!mundo) then
		-- diorama de estudio: cielo de tormenta con resplandor rojizo y muralla lejana
		surface.SetDrawColor(UI.verdeOsc.r + 6, UI.verdeOsc.g + 10, UI.verdeOsc.b + 8, 255)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(UI.sangre.r, UI.sangre.g, UI.sangre.b, 70)
		surface.SetTexture(gradienteArriba)
		surface.DrawTexturedRect(0, h * 0.45, w, h * 0.55)

		surface.SetDrawColor(10, 14, 12, 230)
		surface.DrawRect(0, h * 0.6, w, h * 0.4)
		surface.SetDrawColor(UI.acero.r, UI.acero.g, UI.acero.b, 45)
		surface.DrawRect(0, h * 0.6, w, 2)
	else
		-- sobre el mundo real: solo un velo oscuro en los bordes
		surface.SetDrawColor(0, 0, 0, 120)
		surface.SetTexture(gradienteAbajo)
		surface.DrawTexturedRect(0, 0, w, h * 0.2)
		surface.SetDrawColor(0, 0, 0, 140)
		surface.SetTexture(gradienteArriba)
		surface.DrawTexturedRect(0, h * 0.8, w, h * 0.2)
	end

	-- 3D
	local mx, my = self:CursorPos()
	local masCercano, distMin

	vista = vista or ESTUDIO.cam

	cam.Start3D(vista.pos, vista.ang, vista.fov, 0, 0, w, h)
		render.ClearDepth()
		Luz(mundo)

		if (!mundo) then
			render.SetColorMaterial()
			render.DrawQuadEasy(Vector(ESTUDIO.dist, 0, -0.5), Vector(0, 0, 1), 1400, 1400, Color(12, 18, 15, 255), 0)

			for _, fig in ipairs(self.figuras) do
				render.DrawQuadEasy(fig.pos + Vector(0, 0, 0.2), Vector(0, 0, 1), 80, 80, Color(46, 62, 52, 80), 0)
			end
		end

		for _, fig in ipairs(self.figuras) do
			if (IsValid(fig.ent)) then
				local hover = self.hover == fig
				local b = hover and 1 or 0.78

				fig.ent:FrameAdvance(dt * 0.5)
				fig.ent:SetIK(false)

				render.SetColorModulation(b, b, b)
				fig.ent:DrawModel()

				-- zona del raton: pies y cabeza proyectados
				local pie = (fig.pos + Vector(0, 0, 0)):ToScreen()
				local cabeza = (fig.pos + Vector(0, 0, fig.alto)):ToScreen()

				fig.sx = pie.x
				fig.sy0 = cabeza.y
				fig.sy1 = pie.y
				fig.sw = math.abs(pie.y - cabeza.y) * 0.32

				if (mx >= pie.x - fig.sw and mx <= pie.x + fig.sw and my >= cabeza.y and my <= pie.y) then
					local d = math.abs(mx - pie.x)

					if (!distMin or d < distMin) then masCercano, distMin = fig, d end
				end
			end
		end

		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)
	cam.End3D()

	self.hover = masCercano

	-- rotulos
	for _, fig in ipairs(self.figuras) do
		if (fig.sx) then self:Rotulo(fig, self.hover == fig) end
	end

	-- paginacion
	if (self:TotalPaginas() > 1) then
		local y = h - ScreenScale(34)
		local t = ScreenScale(14)

		for lado = -1, 1, 2 do
			local x = w / 2 + lado * ScreenScale(50) - t / 2
			local activo = (lado == -1 and self.page > 1) or (lado == 1 and self.page < self:TotalPaginas())

			surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 200)
			surface.DrawRect(x, y, t, t)
			surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, activo and 220 or 70)
			surface.DrawOutlinedRect(x, y, t, t)
			draw.SimpleText(lado == -1 and "<" or ">", "ixMenuButtonFont", x + t / 2, y + t / 2, ColorAlpha(UI.pergamino, activo and 255 or 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			if (activo) then self:AnadirBoton(x, y, t, t, function() self:CambiarPagina(lado) end) end
		end

		draw.SimpleText(self.page .. " / " .. self:TotalPaginas(), "ixMenuMiniFont", w / 2, y + t / 2, UI.acero, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	-- titulo
	draw.SimpleText("ELIGE A TU SOLDADO", "aotSubtitulo", w / 2, ScreenScale(18), UI.pergamino, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 140)
	surface.DrawRect(w / 2 - ScreenScale(50), ScreenScale(28), ScreenScale(100), 2)
end

function PANEL:Rotulo(fig, resaltado)
	local personaje = fig.personaje
	local faccion = ix.faction.indices[personaje:GetFaction()]
	local color = faccion and faccion.color or UI.acero
	local x, y = fig.sx, fig.sy1 + ScreenScale(5)

	if (resaltado) then
		-- aro dorado bajo los pies
		surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 200)
		surface.DrawRect(x - fig.sw, fig.sy1 - 2, fig.sw * 2, 2)
	end

	draw.SimpleTextOutlined(personaje:GetName():utf8upper(), "aotSubtitulo", x, y, resaltado and UI.pergamino or ColorAlpha(UI.pergamino, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 200))

	if (faccion) then
		draw.SimpleTextOutlined(faccion.name:utf8upper(), "ixSmallFont", x, y + ScreenScale(13), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 200))
	end

	if (resaltado) then
		draw.SimpleTextOutlined("CLIC PARA ELEGIR", "ixMenuMiniFont", x, y + ScreenScale(24), UI.oro, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 200))

		-- X para borrar
		local t = ScreenScale(9)
		local bx, by = x + fig.sw - t, fig.sy0

		surface.SetDrawColor(UI.sangre.r, UI.sangre.g, UI.sangre.b, 220)
		surface.DrawRect(bx, by, t, t)
		draw.SimpleText("X", "ixMenuMiniFont", bx + t / 2, by + t / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		self:AnadirBoton(bx, by, t, t, function() self:Borrar(fig.id) end)
	end
end

vgui.Register("ixCharMenuLoad", PANEL, "ixCharMenuPanel")

-- Consola del cliente: "aot_seleccion_modo estudio" fuerza el diorama de estudio (por si la camara del mapa se ve mal);
-- "aot_seleccion_modo mundo" vuelve a la camara del mapa.
concommand.Add("aot_seleccion_modo", function(_, _, args)
	ix.aotUI.forzarEstudio = (args[1] == "estudio")

	if (IsValid(ix.aotUI.panelSeleccion)) then
		ix.aotUI.panelSeleccion:ActualizarModo()
	end
end)
