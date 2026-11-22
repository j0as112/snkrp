-- Sobrescribe el skin de Helix con el estilo AoT. Solo toca dibujo (nada de logica).

local UI = ix.aotUI
local SKIN = derma.GetNamedSkin("helix")

if (!SKIN) then
	ErrorNoHalt("[aot_interfaz] No se encontro el skin 'helix'.\n")
	return
end

local gradienteIzq = surface.GetTextureID("vgui/gradient-l")
local gradienteAbajo = surface.GetTextureID("vgui/gradient-d")

SKIN.Colours.Info = Color(130, 170, 215)
SKIN.Colours.Success = Color(110, 170, 100)
SKIN.Colours.Error = Color(215, 85, 75)
SKIN.Colours.Warning = Color(205, 165, 70)
SKIN.Colours.Window.TitleActive = UI.pergamino
SKIN.Colours.Window.TitleInactive = UI.acero
SKIN.Colours.Button.Normal = UI.pergamino
SKIN.Colours.Button.Hover = Color(255, 240, 200)
SKIN.Colours.Label.Default = UI.pergamino
SKIN.Colours.MenuLabel = UI.pergamino

-- Tira de pestanas del menu y de los botones de menu.
function SKIN.tex.Menu_Strip(x, y, width, height, color)
	surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 215)
	surface.DrawRect(x, y, width, height)

	surface.SetDrawColor(UI.verde.r, UI.verde.g, UI.verde.b, 170)
	surface.SetTexture(gradienteIzq)
	surface.DrawTexturedRect(x, y, width, height)

	surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 120)
	surface.DrawRect(x, y + height - 1, width, 1)

	surface.SetTextColor(UI.pergamino)
end

function SKIN:PaintFrame(panel)
	if (!panel.bNoBackgroundBlur) then
		ix.util.DrawBlur(panel, 10)
	end

	local w, h = panel:GetWide(), panel:GetTall()

	UI.Plancha(0, 0, w, h, 205)

	if (panel:GetTitle() != "" or panel.btnClose:IsVisible()) then
		surface.SetDrawColor(UI.verde.r, UI.verde.g, UI.verde.b, 235)
		surface.DrawRect(0, 0, w, 24)

		surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 200)
		surface.DrawRect(0, 24, w, 1)

		if (panel.bHighlighted) then
			self:DrawImportantBackground(0, 0, w, 24, ColorAlpha(UI.pergamino, 22))
		end
	end

	UI.Marco(0, 0, w, h, UI.oro, 8)
end

function SKIN:PaintBaseFrame(panel, width, height)
	if (!panel.bNoBackgroundBlur) then
		ix.util.DrawBlur(panel, 10)
	end

	UI.Plancha(0, 0, width, height, 205)
	UI.Marco(0, 0, width, height, UI.oro, 8)
end

function SKIN:PaintPanel(panel)
	if (!panel.m_bBackground) then return end

	local w, h = panel:GetWide(), panel:GetTall()

	surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 170)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(UI.cuero.r, UI.cuero.g, UI.cuero.b, 140)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function SKIN:PaintTooltipBackground(panel, width, height)
	UI.Plancha(0, 0, width, height, 235)
	UI.Marco(0, 0, width, height, UI.oro, 6)
end

function SKIN:PaintEntityInfoBackground(panel, width, height)
	UI.Plancha(0, 0, width, height, 220)
	UI.Marco(0, 0, width, height, UI.oro, 6)
end

function SKIN:PaintTooltipMinimalBackground(panel, width, height)
	surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 215)
	surface.DrawRect(0, 0, width, height)
end

-- Barras de estado (vida, armadura...): plancha con filete y brillo.
function SKIN:PaintInfoBar(panel, width, height, color)
	surface.SetDrawColor(color.r, color.g, color.b, 245)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(255, 255, 255, 18)
	surface.SetTexture(gradienteAbajo)
	surface.DrawTexturedRect(0, 0, width, height)
end

function SKIN:PaintInfoBarBackground(panel, width, height)
	surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 200)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(UI.acero.r, UI.acero.g, UI.acero.b, 110)
	surface.DrawOutlinedRect(0, 0, width, height)

	panel.bar:PaintManual()

	DisableClipping(true)
		panel.label:PaintManual()
	DisableClipping(false)
end

function SKIN:PaintInventorySlot(panel, width, height)
	surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 150)
	surface.DrawRect(1, 1, width - 2, height - 2)

	surface.SetDrawColor(UI.cuero.r, UI.cuero.g, UI.cuero.b, 230)
	surface.DrawOutlinedRect(1, 1, width - 2, height - 2)
end

function SKIN:PaintListRow(panel, width, height)
	surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 90)
	surface.DrawRect(0, 0, width, height)
end

-- Fondo "importante" (pestanas seleccionadas, botones del menu): degradado con barra dorada a la izquierda.
function SKIN:DrawImportantBackground(x, y, width, height, color)
	color = color or UI.verde

	surface.SetTexture(gradienteIzq)
	surface.SetDrawColor(color.r, color.g, color.b, color.a or 255)
	surface.DrawTexturedRect(x, y, width, height)

	surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, math.min(color.a or 255, 230))
	surface.DrawRect(x, y, 3, height)
end

-- Fondo del menu del tabulador: degradado oscuro desde la izquierda (como el menu de bienvenida), desenfoque
-- y la marca arriba a la izquierda.
function SKIN:PaintMenuBackground(panel, width, height, alphaFraction)
	alphaFraction = alphaFraction or 1

	ix.util.DrawBlur(panel, alphaFraction * 10, nil, 200)

	local solido = width * 0.22

	surface.SetDrawColor(4, 6, 6, alphaFraction * 232)
	surface.DrawRect(0, 0, solido, height)
	surface.SetTexture(gradienteIzq)
	surface.DrawTexturedRect(solido, 0, width * 0.78, height)

	-- marca
	if (panel.GetPadding and UI.TextoEspaciado) then
		local pad = panel:GetPadding()

		UI.TextoEspaciado("SNK RP", "aotMenuBoton", pad, pad * 0.55, Color(240, 240, 238, alphaFraction * 255), ScreenScale(2.2), 0)

		surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, alphaFraction * 220)
		surface.DrawRect(pad, pad * 0.55 + ScreenScale(13), ScreenScale(16), 2)
	end
end

-- Cabeceras de categoria (ajustes, listas...).
function SKIN:PaintCategoryPanel(panel, text, color)
	text = text or ""

	surface.SetFont(self.fontCategoryBlur)

	local textHeight = select(2, surface.GetTextSize(text)) + 6
	local width, height = panel:GetSize()

	surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 150)
	surface.DrawRect(0, textHeight, width, height - textHeight)

	self:DrawImportantBackground(0, 0, width, textHeight, UI.verde)

	surface.SetFont(self.fontCategory)
	surface.SetTextColor(UI.pergamino)
	surface.SetTextPos(10, 4)
	surface.DrawText(text)

	surface.SetDrawColor(UI.cuero.r, UI.cuero.g, UI.cuero.b, 200)
	surface.DrawOutlinedRect(0, 0, width, height)

	return 1, textHeight, 1, 1
end

-- Botones normales de derma.
function SKIN:PaintButton(panel)
	if (!panel.m_bBackground) then return end

	local w, h = panel:GetWide(), panel:GetTall()
	local alpha = 120

	if (panel:GetDisabled()) then
		alpha = 40
	elseif (panel.Depressed) then
		alpha = 230
	elseif (panel.Hovered) then
		alpha = 190
	end

	surface.SetDrawColor(UI.verde.r, UI.verde.g, UI.verde.b, alpha)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, panel.Hovered and 200 or 80)
	surface.DrawOutlinedRect(0, 0, w, h)
end

-- Pantallas de personaje (fondo propio; el contenido lo pinta Helix encima).
function SKIN:PaintCharacterLoadBackground(panel, width, height)
	surface.SetDrawColor(UI.verdeOsc.r, UI.verdeOsc.g, UI.verdeOsc.b, 235)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(UI.verde.r, UI.verde.g, UI.verde.b, 120)
	surface.SetTexture(gradienteIzq)
	surface.DrawTexturedRect(0, 0, width, height)
end

SKIN.PaintCharacterCreateBackground = SKIN.PaintCharacterLoadBackground

-- Pantalla de muerte: "Shinzou wo sasageyo".
function SKIN:PaintDeathScreenBackground(panel, width, height, progress)
	local f = math.min(progress / 0.3, 1)

	surface.SetDrawColor(0, 0, 0, f * 255)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(UI.sangre.r, UI.sangre.g, UI.sangre.b, f * 60)
	surface.SetTexture(gradienteAbajo)
	surface.DrawTexturedRect(0, 0, width, height)
end

function SKIN:PaintDeathScreen(panel, width, height, progress)
	local alfa = math.Clamp((progress - 0.3) / 0.4, 0, 1) * 255

	draw.SimpleText("HAS CAIDO", "aotTitulo", width / 2, height * 0.42, ColorAlpha(UI.pergamino, alfa), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("Tu corazon queda entregado a la humanidad.", "aotSubtitulo", width / 2, height * 0.42 + ScreenScale(18), ColorAlpha(UI.acero, alfa), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	surface.SetDrawColor(UI.sangre.r, UI.sangre.g, UI.sangre.b, alfa)
	surface.DrawRect(width / 2 - ScreenScale(40), height * 0.42 + ScreenScale(30), ScreenScale(80), 2)

	ix.bar.DrawAction()
end

-- Barras de Helix con la paleta AoT (vida y armadura).
ix.bar.Remove("health")
ix.bar.Remove("armor")

ix.bar.Add(function()
	return math.max(LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0)
end, Color(150, 38, 34), nil, "health")

ix.bar.Add(function()
	return math.min(LocalPlayer():Armor() / 100, 1)
end, UI.alas, nil, "armor")
