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

	-- panel redondeado, translucido y sin borde marcado (estilo moderno)
	draw.RoundedBox(8, 0, 0, w, h, Color(20, 16, 12, 205))

	if (panel:GetTitle() != "" or panel.btnClose:IsVisible()) then
		draw.RoundedBoxEx(8, 0, 0, w, 26, Color(255, 255, 255, 14), true, true, false, false)

		if (panel.bHighlighted) then
			self:DrawImportantBackground(0, 0, w, 26, ColorAlpha(UI.pergamino, 22))
		end
	end
end

function SKIN:PaintBaseFrame(panel, width, height)
	if (!panel.bNoBackgroundBlur) then
		ix.util.DrawBlur(panel, 10)
	end

	draw.RoundedBox(8, 0, 0, width, height, Color(20, 16, 12, 190))
end

function SKIN:PaintPanel(panel)
	if (!panel.m_bBackground) then return end

	local w, h = panel:GetWide(), panel:GetTall()

	draw.RoundedBox(6, 0, 0, w, h, Color(20, 16, 12, 165))
end

function SKIN:PaintTooltipBackground(panel, width, height)
	draw.RoundedBox(6, 0, 0, width, height, Color(20, 16, 12, 238))
	draw.RoundedBox(6, 0, 0, width, height, Color(255, 255, 255, 6))
end

function SKIN:PaintEntityInfoBackground(panel, width, height)
	draw.RoundedBox(6, 0, 0, width, height, Color(20, 16, 12, 225))
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
	draw.RoundedBox(3, 0, 0, width, height, Color(240, 225, 190, 16))

	panel.bar:PaintManual()

	DisableClipping(true)
		panel.label:PaintManual()
	DisableClipping(false)
end

function SKIN:PaintInventorySlot(panel, width, height)
	-- casillas suaves y redondeadas, sin borde
	draw.RoundedBox(4, 1, 1, width - 2, height - 2, Color(240, 225, 190, 11))
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

-- Fondo del menu del tabulador: la ilustracion del servidor, oscurecida hacia la izquierda para que el contenido
-- se lea, con un velo calido. Si la imagen aun no se ha descargado, el mundo desenfocado.
function SKIN:PaintMenuBackground(panel, width, height, alphaFraction)
	alphaFraction = alphaFraction or 1

	if (UI.DibujarFondoImagen and UI.DibujarFondoImagen(width, height)) then
		-- velo general calido y degradado mas oscuro a la izquierda
		surface.SetDrawColor(16, 12, 9, alphaFraction * 150)
		surface.DrawRect(0, 0, width, height)

		surface.SetDrawColor(10, 8, 6, alphaFraction * 235)
		surface.SetTexture(gradienteIzq)
		surface.DrawTexturedRect(0, 0, width, height)
	else
		ix.util.DrawBlur(panel, alphaFraction * 10, nil, 200)

		surface.SetDrawColor(14, 11, 8, alphaFraction * 215)
		surface.DrawRect(0, 0, width, height)
	end

	-- viñeta suave arriba y abajo
	surface.SetDrawColor(0, 0, 0, alphaFraction * 110)
	surface.SetTexture(gradienteAbajo)
	surface.DrawTexturedRect(0, 0, width, height * 0.12)
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
