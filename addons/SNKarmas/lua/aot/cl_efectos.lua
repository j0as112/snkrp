if (!CLIENT) then return end

local PLUGIN = {}

local MAT_CABLE = Material("cable/cable2")
local MAT_PUNTA = Material("sprites/light_glow02_add")
local COL_CABLE = Color(55, 55, 60)
local COL_PUNTA = Color(255, 240, 200, 160)

-- ============================================================
-- Postura de vuelo: el cuerpo se orienta según la trayectoria
-- (horizontal al volar, erguido al subir, de cabeza al caer) y se ladea en las curvas.
-- ============================================================
local postura = {}
local CENTRO = Vector(0, 0, 36)

local function PosturaObjetivo(ply)
	if (!ply:Alive() or ply:IsOnGround() or ply:GetMoveType() != MOVETYPE_WALK) then return end
	if (IsValid(ply:GetNW2Entity("aot_agarre"))) then return end

	local wep = ply:GetActiveWeapon()
	if (!IsValid(wep) or !wep.AOT_ODM) then return end

	local vel = ply:GetVelocity()
	local rapidez = vel:Length()
	if (rapidez < 250) then return end

	local dir = vel / rapidez
	local elevacion = math.deg(math.asin(math.Clamp(dir.z, -1, 1)))
	local intensidad = math.Clamp((rapidez - 250) / 500, 0, 1)

	return Angle(math.Clamp(75 - elevacion * 0.8, 0, 130) * intensidad, dir:Angle().y, 0)
end

function PLUGIN:PrePlayerDraw(ply)
	local objetivo = PosturaObjetivo(ply)
	local anterior = postura[ply]

	if (!objetivo) then
		if (!anterior) then return end

		-- Vuelve a la postura normal suavemente.
		objetivo = Angle(0, ply:EyeAngles().y, 0)

		if (math.abs(anterior.p) < 2 and math.abs(anterior.r) < 2) then
			postura[ply] = nil
			return
		end
	end

	-- Alabeo según lo rápido que gira la trayectoria.
	if (anterior) then
		local giro = math.AngleDifference(objetivo.y, anterior.y)
		objetivo.r = math.Clamp(-giro * 4, -45, 45)
	end

	local actual = anterior and LerpAngle(math.Clamp(FrameTime() * 8, 0, 1), anterior, objetivo) or objetivo
	postura[ply] = actual

	-- Gira el modelo alrededor de su centro (no de los pies) y recalcula los huesos:
	-- espadas, equipo y cables cuelgan de los huesos, así que giran con el cuerpo.
	local centro = ply:GetPos() + CENTRO
	ply:SetRenderAngles(actual)
	ply:SetRenderOrigin(centro - actual:Up() * CENTRO.z)
	ply:InvalidateBoneCache()
	ply:SetupBones()
	ply.AOT_PosturaPuesta = true
end

function PLUGIN:PostPlayerDraw(ply)
	if (ply.AOT_PosturaPuesta) then
		ply:SetRenderOrigin(nil)
		ply.AOT_PosturaPuesta = nil
	end
end

function PLUGIN:EntityRemoved(ent)
	postura[ent] = nil
end

-- Punto del equipo del que sale cada cable (sigue la postura de vuelo).
local function OrigenCable(ply, lado)
	local signo = lado == 1 and -1 or 1

	if (ply == LocalPlayer() and !ply:ShouldDrawLocalPlayer()) then
		local ang = EyeAngles()
		return EyePos() + ang:Right() * 10 * signo - ang:Up() * 18 + ang:Forward() * 6
	end

	local hueso = ply:LookupBone("ValveBiped.Bip01_Pelvis")
	local pos = hueso and ply:GetBonePosition(hueso) or ply:GetPos() + Vector(0, 0, 38)

	return pos + ply:GetRight() * 9 * signo
end

-- Cables de todos los jugadores con 3DMG.
function PLUGIN:PostDrawTranslucentRenderables(depth, skybox)
	if (skybox) then return end

	for _, ply in ipairs(player.GetAll()) do
		local wep = ply:Alive() and ply:GetActiveWeapon()

		if (IsValid(wep) and wep.AOT_ODM and wep:GanchosActivos()) then
			for lado = 1, 2 do
				local origen = OrigenCable(ply, lado)
				local punta, clavado = wep:PosPuntaCable(lado, origen)

				if (punta) then
					render.SetMaterial(MAT_CABLE)
					render.DrawBeam(origen, punta, 1.1, 0, origen:Distance(punta) / 48, COL_CABLE)

					render.SetMaterial(MAT_PUNTA)
					render.DrawSprite(punta, clavado and 10 or 6, clavado and 10 or 6, COL_PUNTA)
				end
			end
		end
	end
end

-- Chorros de gas a la espalda cuando se usa el equipo.
local emisor
local siguiente = 0

function PLUGIN:PostDrawOpaqueRenderables()
	if (CurTime() < siguiente) then return end
	siguiente = CurTime() + 0.04

	emisor = emisor or ParticleEmitter(EyePos())

	for _, ply in ipairs(player.GetAll()) do
		local wep = ply:Alive() and ply:GetActiveWeapon()

		if (IsValid(wep) and wep.AOT_ODM and CurTime() - wep:GetUltimoGas() < 0.12 and ply:GetPos():DistToSqr(EyePos()) < 4000 * 4000) then
			local hueso = ply:LookupBone("ValveBiped.Bip01_Spine")
			local espalda = (hueso and ply:GetBonePosition(hueso) or ply:GetPos() + Vector(0, 0, 40)) - ply:GetForward() * 10

			for _ = 1, 2 do
				local p = emisor:Add("particle/particle_smokegrenade", espalda + VectorRand() * 3)

				if (p) then
					p:SetVelocity(-ply:GetVelocity() * 0.15 - ply:GetForward() * 120 + VectorRand() * 25)
					p:SetDieTime(math.Rand(0.4, 0.8))
					p:SetStartAlpha(140)
					p:SetEndAlpha(0)
					p:SetStartSize(4)
					p:SetEndSize(26)
					p:SetColor(240, 240, 245)
					p:SetRoll(math.Rand(0, 360))
					p:SetRollDelta(math.Rand(-2, 2))
					p:SetAirResistance(120)
				end
			end
		end
	end
end

AOT.RegistrarHooks(PLUGIN, "FX")
