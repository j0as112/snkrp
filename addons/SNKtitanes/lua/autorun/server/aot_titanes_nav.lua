-- Navegación de los titanes: generación del navmesh y análisis de cada zona.
--
-- Un titán mide 5-9 veces lo que un jugador: no cabe por puertas, callejones ni bajo tejados.
-- El navmesh normal está hecho para personas, así que cada zona (CNavArea) se mide una vez:
--   techo  = altura libre por encima (los interiores y los arcos tienen techo bajo)
--   hueco  = anchura libre más estrecha alrededor (callejones entre casas)
-- y el titán solo planifica rutas por las zonas donde cabe (ver ENT:CosteNav en aot_titan.lua).
--
-- Comando de staff (consola del servidor o superadmin): aot_nav_generar
--   Genera el navmesh del mapa entero teniendo en cuenta los edificios de mapeado (brushes) y los
--   edificios entidad (prop_dynamic). Siembra desde los spawns y desde una rejilla sobre todo el
--   suelo del mapa (si no, en mapas con sala de spawn aislada solo se generaría esa sala).
--   Al terminar el motor guarda maps/<mapa>.nav y recarga el mapa.

AOT = AOT or {}
AOT.NavInfo = AOT.NavInfo or {}

local ALTURA_MEDIDA = 4000
local ALTURA_HUECO = 120 -- a esta altura se mide la anchura (por encima de vallas, bancos y carros)
local DIRECCIONES = {0, 45, 90, 135}
local MARCA_TRUCOS = "aot_nav_trucos.txt"

-- Solo cuentan el mundo y lo que no se mueve solo (casas prop_dynamic, puertas...), no jugadores ni NPCs.
local function FiltroEstatico(ent)
	if (!IsValid(ent)) then return true end
	return !(ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() or ent:GetClass() == "prop_physics")
end

local function Distancia(desde, dir, largo)
	local tr = util.TraceLine({start = desde, endpos = desde + dir * largo, mask = MASK_NPCSOLID, filter = FiltroEstatico})
	return tr.Hit and tr.Fraction * largo or largo
end

function AOT.MedirZona(area)
	local id = area:GetID()
	local info = AOT.NavInfo[id]
	if (info) then return info end

	local c = area:GetCenter()

	-- Techo: el cielo no cuenta como techo.
	local arriba = util.TraceLine({
		start = c + Vector(0, 0, 40),
		endpos = c + Vector(0, 0, ALTURA_MEDIDA),
		mask = MASK_NPCSOLID,
		filter = FiltroEstatico
	})
	local techo = (arriba.Hit and !arriba.HitSky) and (arriba.HitPos.z - c.z) or ALTURA_MEDIDA

	-- Hueco: en cada eje, distancia a la pared de un lado más la del otro; se queda el eje más estrecho.
	local origen = c + Vector(0, 0, ALTURA_HUECO)
	local hueco = ALTURA_MEDIDA

	for _, a in ipairs(DIRECCIONES) do
		local dir = Angle(0, a, 0):Forward()
		local ancho = Distancia(origen, dir, 800) + Distancia(origen, -dir, 800)
		hueco = math.min(hueco, ancho)
	end

	info = {techo = techo, hueco = hueco}
	AOT.NavInfo[id] = info
	return info
end

-- Mide todas las zonas poco a poco al cargar el mapa (para que la primera ruta no dé tirones).
local function MedirTodo()
	if (!navmesh.IsLoaded()) then return end

	local areas = navmesh.GetAllNavAreas()
	local i = 0

	timer.Create("AOT_MedirNav", 0, 0, function()
		for _ = 1, 150 do
			i = i + 1
			local area = areas[i]

			if (!area) then
				timer.Remove("AOT_MedirNav")
				print("[SNK Titanes] Navmesh analizado: " .. #areas .. " zonas.")
				return
			end

			if (IsValid(area)) then AOT.MedirZona(area) end
		end
	end)
end

hook.Add("InitPostEntity", "AOT_MedirNav", function()
	timer.Simple(5, MedirTodo)
end)

-- ============================================================
-- Generación
-- ============================================================
local function SembrarRejilla(paso)
	local mins, maxs = game.GetWorld():GetModelBounds()
	if (!mins or !maxs) then
		mins, maxs = Vector(-16000, -16000, -16000), Vector(16000, 16000, 16000)
	end
	local n = 0

	for x = mins.x + paso * 0.5, maxs.x, paso do
		for y = mins.y + paso * 0.5, maxs.y, paso do
			local arriba = Vector(x, y, maxs.z - 16)

			-- Baja desde lo alto del mapa; si empieza dentro de algo sólido, sigue desde donde sale.
			for _ = 1, 6 do
				local tr = util.TraceLine({start = arriba, endpos = Vector(x, y, mins.z), mask = MASK_PLAYERSOLID_BRUSHONLY})
				if (!tr.Hit) then break end

				if (tr.StartSolid) then
					if (tr.AllSolid or tr.FractionLeftSolid >= 1) then break end
					arriba = LerpVector(tr.FractionLeftSolid, arriba, Vector(x, y, mins.z)) - Vector(0, 0, 8)
				else
					if (!tr.HitSky and tr.HitNormal.z > 0.7 and bit.band(util.PointContents(tr.HitPos + Vector(0, 0, 8)), CONTENTS_WATER) == 0) then
						navmesh.AddWalkableSeed(tr.HitPos + Vector(0, 0, 4), tr.HitNormal)
						n = n + 1
					end
					break
				end
			end
		end
	end

	return n
end

local function Generar(ply)
	if (IsValid(ply) and !ply:IsSuperAdmin()) then return end

	local function Decir(texto)
		print("[SNK Titanes] " .. texto)
		if (IsValid(ply)) then ply:ChatPrint("[SNK Titanes] " .. texto) end
	end

	if (navmesh.IsGenerating()) then
		Decir("Ya se está generando el navmesh.")
		return
	end

	-- Los edificios entidad (prop_dynamic) tienen que contar como sólidos al generar.
	-- nav_solid_props es un convar de trucos: se activa sv_cheats solo durante la generación
	-- (una marca en data/ hace que se desactive al recargar el mapa).
	if (!GetConVar("sv_cheats"):GetBool()) then
		file.Write(MARCA_TRUCOS, "1")
		RunConsoleCommand("sv_cheats", "1")
	end

	timer.Simple(0.5, function()
		RunConsoleCommand("nav_solid_props", "1")
		RunConsoleCommand("nav_quicksave", "1")

		timer.Simple(0.5, function()
			navmesh.ClearWalkableSeeds()

			local n = 0
			for _, clase in ipairs({"info_player_start", "info_player_deathmatch", "info_teleport_destination"}) do
				for _, e in ipairs(ents.FindByClass(clase)) do
					navmesh.AddWalkableSeed(e:GetPos(), Vector(0, 0, 1))
					n = n + 1
				end
			end

			n = n + SembrarRejilla(1024)

			Decir("Generando navmesh con " .. n .. " semillas. Tarda varios minutos y al terminar se recarga el mapa.")
			navmesh.BeginGeneration()

			if (!navmesh.IsGenerating()) then
				Decir("No se pudo empezar la generación.")

				if (file.Exists(MARCA_TRUCOS, "DATA")) then
					file.Delete(MARCA_TRUCOS)
					RunConsoleCommand("sv_cheats", "0")
				end
			end
		end)
	end)
end

concommand.Add("aot_nav_generar", Generar, nil, "Genera el navmesh del mapa para los titanes (tarda; recarga el mapa).")

-- La generación recarga el mapa: si fuimos nosotros quienes activamos sv_cheats, se desactiva.
hook.Add("InitPostEntity", "AOT_NavSinTrucos", function()
	if (file.Exists(MARCA_TRUCOS, "DATA") and !navmesh.IsGenerating()) then
		file.Delete(MARCA_TRUCOS)
		RunConsoleCommand("sv_cheats", "0")
	end
end)
