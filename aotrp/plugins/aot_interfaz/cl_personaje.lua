-- Menu de personaje (el que sale al conectar) con estilo AoT.
-- Mantiene el flujo de Helix (crear, cargar, borrar, volver) y rehace cabecera, botones y fondo.
-- Estructura inspirada en el menu de Naruto (cabecera HTML + botones); aqui el resto de pantallas
-- (crear/cargar) siguen siendo las de Helix, con el skin AoT.

local UI = ix.aotUI

local gradienteIzq = surface.GetTextureID("vgui/gradient-l")
local gradienteAbajo = surface.GetTextureID("vgui/gradient-d")
local gradienteArriba = surface.GetTextureID("vgui/gradient-u")

-- Logo publicado con la pantalla de carga (GitHub Pages del repo).
local LOGO_URL = "https://j0as112.github.io/snkrp/logo.jpg"

-- Cabecera: franja oscura con el logo, el titulo y el lema. Dibuja su propio fondo para no depender
-- de la transparencia del navegador embebido.
local CABECERA_HTML = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; user-select: none; }
  html, body { width: 100%; height: 100%; overflow: hidden; }
  body {
    display: flex; align-items: center; justify-content: center; gap: 3vw;
    background:
      linear-gradient(180deg, rgba(14,21,17,.92), rgba(20,32,26,.88) 50%, rgba(14,21,17,.92)),
      repeating-linear-gradient(90deg, rgba(255,255,255,.03) 0 2px, transparent 2px 90px);
    border-top: 2px solid #c4a050; border-bottom: 2px solid #c4a050;
    font-family: Georgia, 'Palatino Linotype', serif; color: #d9c9a3;
    animation: entra 1.2s ease-out both;
  }
  @keyframes entra { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: none; } }
  img { height: 86%; aspect-ratio: 1; border-radius: 50%; object-fit: cover;
        box-shadow: 0 0 0 2px rgba(196,160,80,.6), 0 0 30px rgba(0,0,0,.8); }
  h1 { font-size: 11vh; letter-spacing: .2em; text-transform: uppercase; font-weight: 800; text-shadow: 0 3px 16px rgba(0,0,0,.8); }
  h1 span { color: #a82525; }
  p { margin-top: 1vh; font-style: italic; color: #8a929b; font-size: 3.4vh; letter-spacing: .08em; }
  .linea { margin-top: 2vh; height: 2px; width: 100%; background: linear-gradient(90deg, #c4a050, transparent); }
</style>
</head>
<body>
  <img src="]] .. LOGO_URL .. [[" onerror="this.style.display='none'">
  <div>
    <h1>SNK <span>RP</span></h1>
    <p>Shinzou wo Sasageyo &mdash; Ofrece tu coraz&oacute;n</p>
    <div class="linea"></div>
  </div>
</body>
</html>
]]

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

-- ===== Panel principal del menu de personaje =====
local PANEL = {}

AccessorFunc(PANEL, "bUsingCharacter", "UsingCharacter", FORCE_BOOL)

function PANEL:Init()
	local parent = self:GetParent()
	local padding = self:GetPadding()
	local bHasCharacter = #ix.characters > 0

	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
	self:DockPadding(padding, padding, padding, padding)

	local info = self:Add("DLabel")
	info:SetTextColor(ColorAlpha(UI.acero, 70))
	info:SetFont("ixMenuMiniFont")
	info:SetText("SnkRP \226\128\148 Los Muros")
	info:SizeToContents()
	info:SetPos(ScrW() - info:GetWide() - 6, ScrH() - info:GetTall() - 4)

	-- cabecera con el logo
	local cabecera = self:Add("DHTML")
	cabecera:SetSize(ScrW(), ScrH() * 0.25)
	cabecera:SetPos(0, ScrH() * 0.25)
	cabecera:SetMouseInputEnabled(false)
	cabecera:SetHTML(CABECERA_HTML)
	self.cabecera = cabecera

	-- lista de botones
	self.mainButtonList = self:Add("ixCharMenuButtonList")
	self.mainButtonList:Dock(LEFT)

	local createButton = self.mainButtonList:Add("ixMenuButton")
	createButton:SetText("create")
	createButton:SizeToContents()
	createButton.DoClick = function()
		local maximum = ix.config.Get("maxCharacters", 5)

		if (LocalPlayer():IsAdmin()) then
			maximum = maximum + 100
		end

		if (#ix.characters >= maximum) then
			self:GetParent():ShowNotice(3, L("maxCharacters"))
			return
		end

		self:Dim()
		parent.newCharacterPanel:SetActiveSubpanel("faction", 0)
		parent.newCharacterPanel:SlideUp()
	end

	self.loadButton = self.mainButtonList:Add("ixMenuButton")
	self.loadButton:SetText("load")
	self.loadButton:SizeToContents()
	self.loadButton.DoClick = function()
		self:Dim()
		parent.loadCharacterPanel:SlideUp()
	end

	if (!bHasCharacter) then
		self.loadButton:SetDisabled(true)
	end

	local extraURL = ix.config.Get("communityURL", "")
	local extraText = ix.config.Get("communityText", "@community")

	if (extraURL != "" and extraText != "") then
		if (extraText:sub(1, 1) == "@") then
			extraText = L(extraText:sub(2))
		end

		local extraButton = self.mainButtonList:Add("ixMenuButton")
		extraButton:SetText(extraText, true)
		extraButton:SizeToContents()
		extraButton.DoClick = function()
			gui.OpenURL(extraURL)
		end
	end

	self.returnButton = self.mainButtonList:Add("ixMenuButton")
	self:UpdateReturnButton()
	self.returnButton.DoClick = function()
		if (self.bUsingCharacter) then
			parent:Close()
		else
			RunConsoleCommand("disconnect")
		end
	end

	self.mainButtonList:SizeToContents()
end

function PANEL:UpdateReturnButton(bValue)
	if (bValue != nil) then
		self.bUsingCharacter = bValue
	end

	self.returnButton:SetText(self.bUsingCharacter and "return" or "leave")
	self.returnButton:SizeToContents()
end

function PANEL:OnDim()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

function PANEL:OnUndim()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
	self:UpdateReturnButton()
end

function PANEL:OnClose()
	for _, v in pairs(self:GetChildren()) do
		if (IsValid(v)) then
			v:SetVisible(false)
		end
	end
end

function PANEL:PerformLayout(width, height)
	local padding = self:GetPadding()

	self.mainButtonList:SetPos(padding, height - self.mainButtonList:GetTall() - padding)
end

vgui.Register("ixCharMenuMain", PANEL, "ixCharMenuPanel")

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
