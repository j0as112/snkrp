if (!SERVER) then return end

local PLUGIN = {}

AOT = AOT or {}

util.AddNetworkString("AOT_Impacto")
util.AddNetworkString("AOT_Killfeed")

-- Helix se carga después del autorun: el tipo de log se registra al iniciar.
hook.Add("Initialize", "AOT_LogHelix", function()
	if (ix and ix.log) then
		ix.log.AddType("aotTitanAbatido", function(client, metros)
			return string.format("%s ha abatido un titán de %d m.", client:Name(), metros)
		end)
	end
end)

-- Marcador de impacto para quien corta (texto grande en el centro de la pantalla).
function AOT.Marcador(client, texto, color)
	net.Start("AOT_Impacto")
		net.WriteString(texto)
		net.WriteColor(color or Color(255, 255, 255))
	net.Send(client)
end

-- Daño de un tajo: la velocidad es lo que corta (como en el anime y los juegos).
function AOT.DanoCorte(wep, rapidez, giro)
	local filo = wep:GetFilo()
	if (filo <= 0) then return 0 end

	local dano = (25 + rapidez * 0.06) * (0.35 + 0.65 * filo / 100)
	if (giro) then dano = dano * 1.25 end

	return dano * AOT.Config("aotDanoCorte", 1)
end

-- Desgaste por tipo de impacto.
local DESGASTE = {
	[AOT.PARTE.NUCA] = 14,
	[AOT.PARTE.OJOS] = 5,
	[AOT.PARTE.BRAZO_I] = 9,
	[AOT.PARTE.BRAZO_D] = 9,
	[AOT.PARTE.TENDON_I] = 9,
	[AOT.PARTE.TENDON_D] = 9,
	[AOT.PARTE.CUERPO] = 6,
}

function AOT.ResolverCorte(owner, wep, rapidez, giro)
	local eye = owner:GetShootPos()
	local aim = owner:GetAimVector()
	local alcance = giro and 190 or 135
	local fin = eye + aim * alcance
	local centro = owner:WorldSpaceCenter()

	-- Atrapado: los tajos van contra la mano que te sujeta.
	local captor = owner:GetNW2Entity("aot_agarre")
	if (AOT.EsTitan(captor)) then
		if (wep:GetFilo() > 0) then
			wep:Desgastar(8)
			captor:Forcejeo(owner)
		else
			AOT.Avisar(owner, "¡Tus hojas están rotas!")
		end
		return
	end

	-- 1) ¿El filo pasa por alguna parte de un titán?
	local objetivoFijado = wep:GetObjetivo()
	local mejorTitan, mejorParte, mejorMargen, mejorPunto

	for _, ent in ipairs(ents.FindInSphere(eye, 3000)) do
		if (AOT.EsTitan(ent) and !ent:GetMuerto()) then
			for _, parte in ipairs(AOT.PRIORIDAD) do
				if (parte == AOT.PARTE.OJOS or parte == AOT.PARTE.NUCA or parte == AOT.PARTE.CUERPO or !AOT.ParteCortada(ent, parte)) then
					local punto = AOT.PuntoParte(ent, parte)
					local radio = AOT.RadioParte(ent, parte)
					local dist, cercano

					if (giro) then
						dist, cercano = punto:Distance(centro), punto
					else
						dist, cercano = AOT.DistPuntoSegmento(punto, eye, fin)
					end

					-- Ayuda con la nuca: basta con pasar cerca de ella (el cuerpo del jugador cuenta,
					-- no solo la línea del tajo). El titán decide luego si el ángulo vale.
					if (parte == AOT.PARTE.NUCA) then
						radio = radio * 1.6
						local dCentro = punto:Distance(centro)
						if (dCentro < dist) then dist, cercano = dCentro, punto end
					end

					-- Ayuda a apuntar si la parte está fijada.
					if (ent == objetivoFijado and parte == wep:GetParteObjetivo()) then
						radio = radio * 1.5
					end

					local margen = dist - radio

					if (margen < 0) then
						-- Las partes vitales tienen prioridad sobre el cuerpo.
						-- La nuca gana siempre que el tajo la alcance.
						local peso = (parte == AOT.PARTE.CUERPO) and 1000 or (parte == AOT.PARTE.NUCA and -1000 or 0)

						if (!mejorMargen or margen + peso < mejorMargen) then
							mejorTitan, mejorParte, mejorMargen, mejorPunto = ent, parte, margen + peso, cercano
						end
					end
				end
			end
		end
	end

	if (mejorTitan) then
		local dano = AOT.DanoCorte(wep, rapidez, giro)

		if (dano <= 0) then
			AOT.Avisar(owner, "¡Tus hojas están rotas! Pulsa R.")
			return
		end

		wep:Desgastar(DESGASTE[mejorParte] or 6)
		mejorTitan:RecibirCorte(owner, mejorParte, dano, mejorPunto, rapidez)
		return
	end

	-- 2) Golpe normal contra el mundo, props o personas.
	local tr = util.TraceHull({
		start = eye,
		endpos = eye + aim * 90,
		mins = Vector(-10, -10, -10),
		maxs = Vector(10, 10, 10),
		filter = owner,
		mask = MASK_SHOT_HULL
	})

	if (!tr.Hit) then return end

	if (tr.HitWorld or !IsValid(tr.Entity)) then
		wep:Desgastar(5)

		local efecto = EffectData()
		efecto:SetOrigin(tr.HitPos)
		efecto:SetNormal(tr.HitNormal)
		util.Effect("ManhackSparks", efecto)
		owner:EmitSound("physics/metal/metal_solid_impact_bullet" .. math.random(1, 4) .. ".wav", 70, 130)
		return
	end

	local dano = 25 * (0.35 + 0.65 * wep:GetFilo() / 100) * AOT.Config("aotDanoCorte", 1)
	if (wep:GetFilo() <= 0) then dano = 3 end

	local info = DamageInfo()
	info:SetDamage(dano)
	info:SetDamageType(DMG_SLASH)
	info:SetAttacker(owner)
	info:SetInflictor(wep)
	info:SetDamagePosition(tr.HitPos)
	info:SetDamageForce(aim * 3000)
	tr.Entity:TakeDamageInfo(info)

	wep:Desgastar(3)
	owner:EmitSound("slash.wav", 70, math.random(95, 110))
end

-- Anuncio a todo el servidor y contador en el personaje.
function AOT.TitanAbatido(titan, atacante)
	if (!IsValid(atacante) or !atacante:IsPlayer()) then return end

	local metros = AOT.Metros(titan)
	local character = atacante.GetCharacter and atacante:GetCharacter()
	local total

	if (character) then
		total = character:GetData("aotTitanes", 0) + 1
		character:SetData("aotTitanes", total)
	else
		total = atacante:GetPData("aotTitanes", 0) + 1
		atacante:SetPData("aotTitanes", total)
	end

	if (ix and ix.log) then ix.log.Add(atacante, "aotTitanAbatido", metros) end

	if (AOT.Config("aotKillfeed", true)) then
		net.Start("AOT_Killfeed")
			net.WriteString(atacante:Name())
			net.WriteUInt(metros, 8)
			net.WriteBool(titan.AOT_Aberrante == true)
			net.WriteUInt(math.min(total, 65535), 16)
		net.Broadcast()
	end
end

-- Recarga de gas y hojas (suministros o items).
function AOT.Recargar(client, gas, hojas)
	local wep = client:GetWeapon(AOT.CLASE_3DMG)

	if (!IsValid(wep)) then
		AOT.Avisar(client, "Necesitas llevar equipado el 3DMG.")
		return false
	end

	local maxHojas = AOT.Config("aotHojasRecambio", 4)
	local hizo = false

	if (gas and wep:GetGas() < 99) then
		wep:SetGas(math.min(100, wep:GetGas() + gas))
		hizo = true
	end

	if (hojas and (wep:GetHojas() < maxHojas or wep:GetFilo() < 100)) then
		if (wep:GetFilo() <= 0 and hojas > 0) then
			wep:SetFilo(100)
			hojas = hojas - 1
		end

		wep:SetHojas(math.min(maxHojas, wep:GetHojas() + hojas))
		hizo = true
	end

	if (hizo) then
		wep:GuardarItem()
		client:EmitSound("items/ammo_pickup.wav")
	end

	return hizo
end

-- Si alguien atrapado muere, se desconecta o reaparece, el titán lo suelta.
local function LiberarPresa(client)
	local captor = client:GetNW2Entity("aot_agarre")

	if (AOT.EsTitan(captor) and captor.Soltar) then
		captor:Soltar(true)
	end

	client:SetNW2Entity("aot_agarre", NULL)

	if (client:GetMoveType() == MOVETYPE_NONE) then
		client:SetMoveType(MOVETYPE_WALK)
	end
end

function PLUGIN:PlayerDeath(client) LiberarPresa(client) end
function PLUGIN:PlayerDisconnected(client) LiberarPresa(client) end
function PLUGIN:PlayerSpawn(client) LiberarPresa(client) end

-- Los ganchos no deben "atrapar" al propio jugador ni dar problemas con la caída tras ser soltado.
function PLUGIN:PlayerNoClip(client, estado)
	if (estado) then LiberarPresa(client) end
end

-- Las cajas de suministros se guardan por mapa en data/aot_titanes/<mapa>.json.
local function ArchivoMapa()
	return "aot_titanes/" .. game.GetMap() .. ".json"
end

function AOT.GuardarSuministros()
	local datos = {}

	for _, ent in ipairs(ents.FindByClass("aot_suministros")) do
		local pos, ang = ent:GetPos(), ent:GetAngles()
		datos[#datos + 1] = {pos.x, pos.y, pos.z, ang.p, ang.y, ang.r, ent:GetCargas()}
	end

	file.CreateDir("aot_titanes")
	file.Write(ArchivoMapa(), util.TableToJSON(datos))
end

function AOT.CargarSuministros()
	local datos = util.JSONToTable(file.Read(ArchivoMapa(), "DATA") or "") or {}

	for _, v in ipairs(datos) do
		local ent = ents.Create("aot_suministros")
		ent:SetPos(Vector(v[1], v[2], v[3]))
		ent:SetAngles(Angle(v[4], v[5], v[6]))
		ent:Spawn()
		ent:SetCargas(v[7] or -1)
	end
end

function PLUGIN:InitPostEntity()
	timer.Simple(1, AOT.CargarSuministros)
	timer.Create("AOT_GuardarSuministros", 300, 0, AOT.GuardarSuministros)
end

function PLUGIN:PostCleanupMap()
	AOT.CargarSuministros()
end

function PLUGIN:ShutDown()
	AOT.GuardarSuministros()
end

concommand.Add("aot_guardar_suministros", function(client)
	if (IsValid(client) and !client:IsSuperAdmin()) then return end

	AOT.GuardarSuministros()

	if (IsValid(client)) then AOT.Avisar(client, "Cajas de suministros guardadas en este mapa.") end
end)

AOT.RegistrarHooks(PLUGIN, "SV")
