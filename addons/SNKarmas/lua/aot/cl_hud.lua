if (!CLIENT) then return end

local PLUGIN = {}

AOT = AOT or {}

surface.CreateFont("AOT_Grande", {font = "Roboto", size = ScreenScale(18), weight = 900, extended = true})
surface.CreateFont("AOT_Medio", {font = "Roboto", size = ScreenScale(9), weight = 700, extended = true})
surface.CreateFont("AOT_Pequeno", {font = "Roboto", size = ScreenScale(6.5), weight = 600, extended = true})

local COL_FONDO = Color(10, 12, 16, 170)
local COL_GAS = Color(170, 215, 255)
local COL_TEXTO = Color(235, 235, 235)
local COL_AVISO = Color(255, 90, 70)
local COL_OK = Color(130, 230, 140)
local COL_FIJADO = Color(255, 200, 60)

local function ArmaODM()
	local ply = LocalPlayer()
	if (!IsValid(ply) or !ply:Alive()) then return end

	local wep = ply:GetActiveWeapon()
	if (IsValid(wep) and wep.AOT_ODM) then return wep end
end

local function Barra(x, y, w, h, frac, color)
	draw.RoundedBox(4, x, y, w, h, COL_FONDO)
	draw.RoundedBox(4, x + 2, y + 2, math.max(0, (w - 4) * math.Clamp(frac, 0, 1)), h - 4, color)
end

-- ============================================================
-- Marcadores de impacto y killfeed
-- ============================================================
local marcador = {texto = "", color = color_white, hasta = 0}
local killfeed = {}

net.Receive("AOT_Impacto", function()
	marcador.texto = net.ReadString()
	marcador.color = net.ReadColor()
	marcador.inicio = CurTime()
	marcador.hasta = CurTime() + 1.3

	if (marcador.texto:find("NUCA") and !marcador.texto:find("%%")) then
		surface.PlaySound("physics/flesh/flesh_bloody_break.wav")
	end
end)

net.Receive("AOT_Killfeed", function()
	local nombre = net.ReadString()
	local metros = net.ReadUInt(8)
	local aberrante = net.ReadBool()
	local total = net.ReadUInt(16)

	table.insert(killfeed, 1, {
		texto = string.format("%s ha abatido un titán %sde %d m  (%d)", nombre, aberrante and "aberrante " or "", metros, total),
		hasta = CurTime() + 7
	})

	if (#killfeed > 5) then table.remove(killfeed) end
end)

-- ============================================================
-- HUD del 3DMG
-- ============================================================
local NOMBRES_CORTOS = {"Nuca", "Ojos", "Brazo izq.", "Brazo dcho.", "Tendón izq.", "Tendón dcho.", "Cuerpo"}

local function EstadoTitan(titan)
	local lineas = {}
	local ahora = CurTime()
	local P = AOT.PARTE

	local function Linea(nombre, fin)
		if (fin > ahora) then
			lineas[#lineas + 1] = string.format("%s: regenera en %ds", nombre, math.ceil(fin - ahora))
		end
	end

	Linea("Brazo izq.", titan:GetRegenBrazoI())
	Linea("Brazo dcho.", titan:GetRegenBrazoD())
	Linea("Tendón izq.", titan:GetRegenTendonI())
	Linea("Tendón dcho.", titan:GetRegenTendonD())
	Linea("Ciego", titan:GetCegadoHasta())

	if (titan:GetDerribado()) then table.insert(lineas, 1, "¡DERRIBADO!") end

	return lineas
end

function PLUGIN:HUDPaint()
	local ply = LocalPlayer()
	local sw, sh = ScrW(), ScrH()

	-- Killfeed (visible para todos).
	local ky = sh * 0.12
	for i = #killfeed, 1, -1 do
		if (killfeed[i].hasta < CurTime()) then table.remove(killfeed, i) end
	end
	for _, k in ipairs(killfeed) do
		surface.SetFont("AOT_Pequeno")
		local tw, th = surface.GetTextSize(k.texto)
		draw.RoundedBox(4, sw - tw - 30, ky, tw + 16, th + 8, COL_FONDO)
		draw.SimpleText(k.texto, "AOT_Pequeno", sw - tw - 22, ky + 4, COL_FIJADO)
		ky = ky + th + 12
	end

	-- Atrapado por un titán.
	if (IsValid(ply) and IsValid(ply:GetNW2Entity("aot_agarre"))) then
		surface.SetDrawColor(120, 0, 0, 90 + math.sin(CurTime() * 8) * 40)
		surface.DrawRect(0, 0, sw, sh)
		draw.SimpleTextOutlined("¡ATRAPADO!", "AOT_Grande", sw / 2, sh * 0.3, COL_AVISO, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
		draw.SimpleTextOutlined("Clic izquierdo para forcejear con tus hojas", "AOT_Medio", sw / 2, sh * 0.3 + ScreenScale(18), COL_TEXTO, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	end

	-- Marcador de impacto.
	if (marcador.hasta > CurTime()) then
		local vida = (CurTime() - marcador.inicio) / 1.3
		local alfa = 255 * (1 - vida ^ 2)
		local c = marcador.color
		draw.SimpleTextOutlined(marcador.texto, "AOT_Grande", sw / 2, sh * 0.38 - vida * 30, Color(c.r, c.g, c.b, alfa), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, alfa))
	end

	local wep = ArmaODM()
	if (!wep) then return end

	-- Mira "( )" sobre el punto exacto donde se clavaría el gancho (como en el juego de AoT).
	-- En tercera persona el punto no está en el centro de la pantalla, así que se proyecta.
	local cx, cy = sw / 2, sh / 2
	local rango = AOT.Config("aotRangoGancho", 2600)
	local ojo = ply:GetShootPos()
	local tr = util.TraceLine({
		start = ojo,
		endpos = ojo + ply:GetAimVector() * rango,
		mask = MASK_SHOT,
		filter = function(ent) return !ent:IsPlayer() end
	})
	local alcanza = tr.Hit and !tr.HitSky
	local colMira = alcanza and COL_OK or COL_AVISO
	local punto = tr.HitPos:ToScreen()
	local mx, my = punto.visible and punto.x or cx, punto.visible and punto.y or cy
	local abre = 10 + (alcanza and 0 or 5)

	-- Anclaje automático: marca dónde se clavará cada gancho (se recalcula 10 veces por segundo).
	local fijado = AOT.EsTitan(wep:GetObjetivo()) and wep:GetParteObjetivo() > 0

	if (wep:AnclajeAuto() and !fijado and !wep:GanchosActivos()) then
		if (CurTime() >= (wep.AOT_SigPrevia or 0)) then
			wep.AOT_SigPrevia = CurTime() + 0.1
			wep.AOT_Previa = {wep:BuscarAnclaje(1), wep:BuscarAnclaje(2)}
		end

		local hay = false

		for lado = 1, 2 do
			local p = wep.AOT_Previa and wep.AOT_Previa[lado]

			if (p) then
				local s = p.HitPos:ToScreen()

				if (s.visible) then
					hay = true
					surface.DrawCircle(s.x, s.y, 7, COL_OK.r, COL_OK.g, COL_OK.b, 230)
					draw.SimpleTextOutlined(lado == 1 and "I" or "D", "AOT_Pequeno", s.x, s.y - 10, COL_OK, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
				end
			end
		end

		-- Pequeña mira central para orientarse; en rojo si no hay ningún anclaje posible.
		local c = hay and COL_TEXTO or COL_AVISO
		draw.SimpleTextOutlined("(  )", "AOT_Pequeno", cx, cy, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		mx, my, abre, alcanza = cx, cy, 14, false
	else
		-- Apuntado manual (o titán fijado / ganchos ya lanzados).
		draw.SimpleTextOutlined("(", "AOT_Medio", mx - abre, my, colMira, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
		draw.SimpleTextOutlined(")", "AOT_Medio", mx + abre, my, colMira, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
		surface.SetDrawColor(colMira)
		surface.DrawRect(mx - 1, my - 1, 2, 2)

		if (alcanza) then
			draw.SimpleTextOutlined(math.Round(tr.HitPos:Distance(ojo) * 0.01905) .. " m", "AOT_Pequeno", mx, my + abre + 6, colMira, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		end
	end

	-- Estado de cada gancho a los lados de la mira.
	for lado = 1, 2 do
		local x = lado == 1 and mx - abre - 22 or mx + abre + 16
		local col = Color(90, 90, 90, 200)

		if (wep:Enganchado(lado)) then col = COL_OK
		elseif ((lado == 1 and wep:GetLanzI() or wep:GetLanzD()) > 0) then col = COL_FIJADO end

		draw.RoundedBox(2, x, my - 8, 6, 16, col)
	end

	-- Panel inferior: gas, hojas y velocidad.
	local w, h = ScreenScale(150), ScreenScale(34)
	local x, y = cx - w / 2, sh - h - ScreenScale(10)
	draw.RoundedBox(8, x, y, w, h, COL_FONDO)

	local gas = wep:GetGas()
	local colGas = gas < 20 and COL_AVISO or COL_GAS
	draw.SimpleText("GAS", "AOT_Pequeno", x + 10, y + 6, COL_TEXTO)
	Barra(x + ScreenScale(22), y + 6, w * 0.55, ScreenScale(7), gas / 100, colGas)
	draw.SimpleText(math.floor(gas) .. "%", "AOT_Pequeno", x + ScreenScale(24) + w * 0.55, y + 6, colGas)

	local filo = wep:GetFilo()
	local colFilo = filo <= 0 and COL_AVISO or (filo < 30 and COL_FIJADO or COL_TEXTO)
	local cambiando = wep:GetCambiando() > CurTime()
	draw.SimpleText("HOJAS", "AOT_Pequeno", x + 10, y + 6 + ScreenScale(11), COL_TEXTO)
	Barra(x + ScreenScale(22), y + 6 + ScreenScale(11), w * 0.55, ScreenScale(7), filo / 100, colFilo)
	draw.SimpleText(cambiando and "..." or ("×" .. wep:GetHojas()), "AOT_Pequeno", x + ScreenScale(24) + w * 0.55, y + 6 + ScreenScale(11), colFilo)

	local kmh = math.Round(ply:GetVelocity():Length() * 0.06858)
	draw.SimpleText(kmh .. " km/h", "AOT_Medio", x + w - 10, y + h - 6, kmh > 80 and COL_FIJADO or COL_TEXTO, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

	if (filo <= 0) then
		draw.SimpleTextOutlined("HOJAS ROTAS: pulsa R", "AOT_Medio", cx, y - ScreenScale(8), COL_AVISO, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	elseif (gas <= 0) then
		draw.SimpleTextOutlined("SIN GAS", "AOT_Medio", cx, y - ScreenScale(8), COL_AVISO, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	end

	-- Objetivo fijado.
	local titan = wep:GetObjetivo()
	local parte = wep:GetParteObjetivo()

	if (AOT.EsTitan(titan) and parte > 0) then
		local punto = AOT.PuntoParte(titan, parte)
		local pantalla = punto:ToScreen()

		if (pantalla.visible) then
			local r = 14 + math.sin(CurTime() * 6) * 3
			surface.DrawCircle(pantalla.x, pantalla.y, r, COL_FIJADO.r, COL_FIJADO.g, COL_FIJADO.b, 255)
			surface.DrawCircle(pantalla.x, pantalla.y, r + 2, 0, 0, 0, 150)

			local metros = math.Round(punto:Distance(ply:GetShootPos()) * 0.01905)
			draw.SimpleTextOutlined(NOMBRES_CORTOS[parte] .. "  " .. metros .. " m", "AOT_Pequeno", pantalla.x, pantalla.y + r + 4, COL_FIJADO, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)

			local ly = pantalla.y + r + 4 + ScreenScale(8)
			for _, linea in ipairs(EstadoTitan(titan)) do
				draw.SimpleTextOutlined(linea, "AOT_Pequeno", pantalla.x, ly, COL_TEXTO, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
				ly = ly + ScreenScale(7)
			end
		end

		draw.SimpleText("FIJADO: " .. AOT.Metros(titan) .. " m", "AOT_Pequeno", x + 10, y + h - 6, COL_FIJADO, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	else
		draw.SimpleText("Rueda: fijar objetivo", "AOT_Pequeno", x + 10, y + h - 6, Color(160, 160, 160), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end

	-- Líneas de velocidad.
	if (GetConVar("aot_efecto_velocidad"):GetBool()) then
		local rapidez = ply:GetVelocity():Length()

		if (rapidez > 1200) then
			local intensidad = math.Clamp((rapidez - 1200) / 1800, 0, 1)
			surface.SetDrawColor(255, 255, 255, 40 * intensidad)

			for i = 1, 14 do
				local a = (i / 14) * math.pi * 2 + CurTime() * 0.3
				local r1 = math.max(sw, sh) * (0.42 + math.Rand(0, 0.05))
				local r2 = r1 + math.max(sw, sh) * 0.15 * intensidad
				surface.DrawLine(cx + math.cos(a) * r1, cy + math.sin(a) * r1, cx + math.cos(a) * r2, cy + math.sin(a) * r2)
			end
		end
	end
end

-- ============================================================
-- Cámara: vista al ser atrapado, tercera persona y FOV por velocidad
-- ============================================================
local distanciaCamara
function PLUGIN:CalcView(ply, origen, angulos, fov)
	if (ply != LocalPlayer() or !ply:Alive()) then return end

	local captor = ply:GetNW2Entity("aot_agarre")

	if (AOT.EsTitan(captor)) then
		local boca = AOT.PosBoca(captor)
		local ojo = ply:EyePos()
		local mirar = (boca - ojo):Angle()
		local t = CurTime()

		mirar.p = mirar.p + math.sin(t * 13) * 2
		mirar.y = mirar.y + math.cos(t * 11) * 2
		mirar.r = math.sin(t * 7) * 6

		return {origin = ojo, angles = mirar, fov = fov + 10, drawviewer = false}
	end

	if (!ArmaODM()) then
		distanciaCamara = nil
		return
	end

	local rapidez = ply:GetVelocity():Length()
	local extra = GetConVar("aot_efecto_velocidad"):GetBool() and math.Clamp((rapidez - 400) / 90, 0, 18) or 0

	if (!GetConVar("aot_tercera_persona"):GetBool()) then
		if (extra > 0) then return {origin = origen, angles = angulos, fov = fov + extra} end
		return
	end

	-- Cámara de persecución: detrás y algo por encima, se aleja con la velocidad y no atraviesa paredes.
	local objetivo = GetConVar("aot_camara_distancia"):GetFloat() + math.Clamp(rapidez * 0.03, 0, 90)
	distanciaCamara = Lerp(math.Clamp(FrameTime() * 4, 0, 1), distanciaCamara or objetivo, objetivo)

	local ojo = ply:EyePos()
	local deseada = ojo - angulos:Forward() * distanciaCamara + angulos:Up() * 14
	local tr = util.TraceHull({
		start = ojo,
		endpos = deseada,
		mins = Vector(-6, -6, -6),
		maxs = Vector(6, 6, 6),
		mask = MASK_SOLID_BRUSHONLY,
		filter = ply
	})

	return {origin = tr.HitPos, angles = angulos, fov = fov + extra, drawviewer = true}
end

-- Sonido de viento según la velocidad.
local viento

function PLUGIN:Think()
	local ply = LocalPlayer()
	if (!IsValid(ply)) then return end

	local rapidez = ArmaODM() and ply:GetVelocity():Length() or 0

	if (rapidez > 700) then
		if (!viento) then
			viento = CreateSound(ply, "ambient/levels/canals/windmill_wind_loop1.wav")
			viento:PlayEx(0, 100)
		end

		viento:ChangeVolume(math.Clamp((rapidez - 700) / 2000, 0, 0.8), 0.2)
		viento:ChangePitch(math.Clamp(80 + rapidez / 60, 80, 140), 0.2)
	elseif (viento) then
		viento:FadeOut(0.4)
		viento = nil
	end
end

AOT.RegistrarHooks(PLUGIN, "HUD")
