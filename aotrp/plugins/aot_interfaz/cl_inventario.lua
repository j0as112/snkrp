-- Pestana de inventario con el personaje en 3D y huecos de equipo, al estilo AoT (como el de Naruto).
-- La cuadricula de objetos es la de Helix (ixInventory: arrastrar, usar, equipar, bolsas...); aqui se anade
-- el escenario del personaje con sus huecos. Los huecos muestran lo que lleva equipado, se vacian con un clic
-- y aceptan objetos arrastrados desde la cuadricula.

local UI = ix.aotUI

local RECEPTOR = "ixInventoryItem"

-- Acciones de objeto (mismo protocolo que usa Helix).
local function Accion(accion, item)
	net.Start("ixInventoryAction")
		net.WriteString(accion)
		net.WriteUInt(item:GetID(), 32)
		net.WriteUInt(item.invID, 32)
		net.WriteTable({})
	net.SendToServer()
end

-- A que hueco pertenece un objeto equipable.
local function Tipo(item)
	if (item.class == "aot_odm") then return "equipo" end
	if (item.isWeapon or item.base == "base_weapons") then return "arma" end
	if (item.outfitCategory or item.base == "base_outfit" or item.base == "base_pacoutfit") then return "ropa" end

	return "extra"
end

local IZQUIERDA = {
	{tipo = "ropa", texto = "ROPA"},
	{tipo = "extra", texto = "EXTRA"},
}

local DERECHA = {
	{tipo = "equipo", texto = "EQUIPO"},
	{tipo = "arma", texto = "ARMA"},
	{tipo = "arma", texto = "ARMA", segunda = true},
}

-- ===== Hueco de equipo =====
local RANURA = {}

function RANURA:Init()
	self.f = 0
	self:Receiver(RECEPTOR, function(ranura, paneles, soltado)
		if (!soltado) then return end

		local icono = paneles and paneles[1]
		local item = icono and icono.itemTable

		if (item and Tipo(item) == ranura.tipo and !item:GetData("equip", false)) then
			Accion("Equip", item)
		end
	end)
end

function RANURA:Poner(item)
	self.item = item

	if (IsValid(self.icono)) then self.icono:Remove() end

	if (item) then
		local icono = vgui.Create("ixSpawnIcon", self)
		icono:SetModel(item:GetModel(), item:GetSkin())
		icono:SetMouseInputEnabled(false)
		icono:SetSize(self:GetWide() - 10, self:GetTall() - 10)
		icono:SetPos(5, 5)

		self.icono = icono
	end
end

function RANURA:OnMousePressed(codigo)
	if (codigo == MOUSE_LEFT and self.item) then
		surface.PlaySound("helix/ui/press.wav")
		Accion("EquipUn", self.item)
	end
end

function RANURA:Paint(w, h)
	local activo = self.item != nil

	self.f = Lerp(math.min(FrameTime() * 12, 1), self.f, (self:IsHovered() and self.item) and 1 or 0)

	surface.SetDrawColor(6, 9, 8, 200)
	surface.DrawRect(0, 0, w, h)

	local a = activo and 200 or 70
	surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, a * (0.5 + 0.5 * self.f))
	surface.DrawOutlinedRect(0, 0, w, h)

	if (!activo) then
		UI.TextoEspaciado(self.texto, "aotMenuPequeno", w / 2, h / 2 - ScreenScale(2.6), Color(130, 136, 140, 150), ScreenScale(1.2), 1)
	end

	-- aviso al arrastrar un objeto compatible
	local arrastrado = (dragndrop.GetDroppable() or {})[1]

	if (IsValid(arrastrado) and arrastrado.itemTable and Tipo(arrastrado.itemTable) == self.tipo) then
		surface.SetDrawColor(110, 200, 120, 60 + 40 * math.sin(CurTime() * 6))
		surface.DrawRect(1, 1, w - 2, h - 2)
	end
end

function RANURA:PaintOver(w, h)
	if (self.f > 0.05 and self.item) then
		surface.SetDrawColor(216, 80, 80, 110 * self.f)
		surface.DrawRect(0, h - 3, w, 3)
	end
end

vgui.Register("aotRanura", RANURA, "DPanel")

-- ===== Escenario del personaje =====
local ESCENARIO = {}

function ESCENARIO:Init()
	self.ranuras = {}
	self.giro = 160
	self.refresco = 0
	self.firma = ""

	-- modelo del personaje
	local m = vgui.Create("DModelPanel", self)
	m:SetFOV(34)
	m:SetCamPos(Vector(125, 0, 46))
	m:SetLookAt(Vector(0, 0, 36))
	m:SetAmbientLight(Color(110, 110, 110))
	m:SetDirectionalLight(BOX_FRONT, Color(255, 245, 230))
	m:SetDirectionalLight(BOX_TOP, Color(220, 220, 220))
	m:SetDirectionalLight(BOX_BACK, Color(110, 150, 220))
	m:SetMouseInputEnabled(true)
	self.modelo = m

	local escenario = self

	function m:LayoutEntity(ent)
		ent:SetAngles(Angle(0, escenario.giro, 0))
		ent:FrameAdvance(FrameTime() * 0.5)
		ent:SetIK(false)
	end

	function m:OnMousePressed(codigo)
		if (codigo == MOUSE_LEFT) then
			escenario.arrastrando = true
			escenario.xAnterior = gui.MouseX()
			self:MouseCapture(true)
		end
	end

	function m:OnMouseReleased()
		escenario.arrastrando = false
		self:MouseCapture(false)
	end

	-- huecos
	for _, def in ipairs(IZQUIERDA) do self:NuevaRanura(def, "izq") end
	for _, def in ipairs(DERECHA) do self:NuevaRanura(def, "der") end
end

function ESCENARIO:NuevaRanura(def, lado)
	local r = vgui.Create("aotRanura", self)

	r.tipo = def.tipo
	r.texto = def.texto
	r.segunda = def.segunda
	r.lado = lado

	self.ranuras[#self.ranuras + 1] = r
end

function ESCENARIO:PerformLayout(w, h)
	local s = ScreenScale(34)
	local margen = w * 0.03
	local mw = w * 0.46

	self.modelo:SetPos((w - mw) / 2, h * 0.04)
	self.modelo:SetSize(mw, h * 0.92)

	local filasIzq, filasDer = 0, 0

	for _, r in ipairs(self.ranuras) do
		r:SetSize(s, s)

		local n = (r.lado == "izq") and #IZQUIERDA or #DERECHA
		local i = (r.lado == "izq") and (filasIzq + 1) or (filasDer + 1)
		local paso = s + ScreenScale(8)
		local y0 = h * 0.5 - (n * paso - ScreenScale(8)) / 2

		if (r.lado == "izq") then filasIzq = filasIzq + 1 else filasDer = filasDer + 1 end

		r:SetPos(r.lado == "izq" and margen or (w - s - margen), y0 + (i - 1) * paso)
	end
end

-- Mantiene el modelo igual que el personaje (modelo, skin, bodygroups) y los huecos al dia.
function ESCENARIO:Think()
	local jugador = LocalPlayer()

	if (self.arrastrando) then
		local x = gui.MouseX()
		self.giro = self.giro + (x - (self.xAnterior or x)) * 0.7
		self.xAnterior = x
	end

	if (IsValid(self.modelo) and jugador:GetModel() != self.modeloActual) then
		self.modeloActual = jugador:GetModel()
		self.modelo:SetModel(self.modeloActual)

		local ent = self.modelo.Entity

		if (IsValid(ent)) then
			ent:SetSkin(jugador:GetSkin())

			for i = 0, jugador:GetNumBodyGroups() - 1 do
				ent:SetBodygroup(i, jugador:GetBodygroup(i))
			end

			local seq = ent:LookupSequence("idle_unarmed")
			if (seq <= 0) then seq = ent:SelectWeightedSequence(ACT_IDLE) end
			if (seq > 0) then ent:ResetSequence(seq) end
		end
	end

	if (CurTime() < self.refresco) then return end

	self.refresco = CurTime() + 0.25
	self:Refrescar()
end

function ESCENARIO:Refrescar()
	local personaje = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
	local inventario = personaje and personaje:GetInventory()

	if (!inventario) then return end

	local porTipo = {}
	local firma = {}

	for _, item in pairs(inventario:GetItems()) do
		if (item:GetData("equip", false)) then
			local tipo = Tipo(item)

			porTipo[tipo] = porTipo[tipo] or {}
			table.insert(porTipo[tipo], item)
			firma[#firma + 1] = item:GetID()
		end
	end

	table.sort(firma)

	local clave = table.concat(firma, ",")

	if (clave == self.firma) then return end

	self.firma = clave

	for _, r in ipairs(self.ranuras) do
		local lista = porTipo[r.tipo] or {}
		r:Poner(lista[r.segunda and 2 or 1])
	end
end

function ESCENARIO:Paint(w, h)
	-- plataforma bajo el personaje
	surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 40)
	surface.DrawRect(w / 2 - w * 0.2, h * 0.93, w * 0.4, 1)

	UI.TextoEspaciado("EQUIPO", "aotMenuPequeno", ScreenScale(2), ScreenScale(1), Color(150, 156, 160), ScreenScale(1.6), 0)
	UI.TextoEspaciado("ARRASTRA PARA GIRAR", "aotMenuPequeno", w / 2, h - ScreenScale(8), Color(110, 116, 120, 160), ScreenScale(1.2), 1)
end

vgui.Register("aotEscenario", ESCENARIO, "DPanel")

-- ===== Pestana =====
-- Sustituye a la de Helix (mismo identificador de hook, se carga despues que el nucleo).
hook.Add("CreateMenuButtons", "ixInventory", function(tabs)
	if (hook.Run("CanPlayerViewInventory") == false) then
		return
	end

	tabs["inv"] = {
		bDefault = true,
		Create = function(info, contenedor)
			local ancho = contenedor:GetWide()

			-- izquierda: personaje y huecos
			local escenario = contenedor:Add("aotEscenario")
			escenario:Dock(LEFT)
			escenario:SetWide(ancho * 0.46)

			-- derecha: cuadricula de objetos de Helix
			local derecha = contenedor:Add("Panel")
			derecha:Dock(FILL)
			derecha:DockMargin(ScreenScale(8), 0, 0, 0)

			function derecha:Paint(w, h)
				UI.TextoEspaciado("INVENTARIO", "aotMenuPequeno", ScreenScale(2), ScreenScale(1), Color(150, 156, 160), ScreenScale(1.6), 0)

				surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 90)
				surface.DrawRect(0, ScreenScale(11), ScreenScale(14), 2)
			end

			local lienzo = derecha:Add("DTileLayout")
			local lienzoLayout = lienzo.PerformLayout
			lienzo.PerformLayout = nil
			lienzo:SetBorder(0)
			lienzo:SetSpaceX(2)
			lienzo:SetSpaceY(2)
			lienzo:Dock(FILL)
			lienzo:DockMargin(0, ScreenScale(18), 0, 0)

			ix.gui.menuInventoryContainer = lienzo

			local panel = lienzo:Add("ixInventory")
			panel:SetPos(0, 0)
			panel:SetDraggable(false)
			panel:SetSizable(false)
			panel:SetTitle(nil)
			panel.bNoBackgroundBlur = true
			panel.childPanels = {}

			local inventario = LocalPlayer():GetCharacter():GetInventory()

			if (inventario) then
				panel:SetInventory(inventario)
			end

			ix.gui.inv1 = panel

			if (ix.option.Get("openBags", true) and inventario) then
				for _, v in pairs(inventario:GetItems()) do
					if (!v.isBag) then continue end

					v.functions.View.OnClick(v)
				end
			end

			lienzo.PerformLayout = lienzoLayout
			lienzo:Layout()
		end
	}
end)
