--[[
	Equipo de maniobras tridimensional (3DMG)

	Controles:
	  Clic derecho (mantener)  Lanza los dos ganchos al punto de mira y recoge cable con gas.
	                           Si tienes un objetivo fijado, los ganchos van a esa parte del titán.
	  Ctrl (con ganchos)       Deja de recoger cable: balanceo libre tipo péndulo (sin gas).
	  A / D (con ganchos)      Orbitar alrededor del punto de anclaje.
	  Espacio (en el aire)     Impulso de gas en la dirección en la que te mueves.
	  Shift (en el aire)       Propulsión continua de gas hacia donde miras.
	  Clic izquierdo           Tajo. Con mucha velocidad en el aire, corte giratorio.
	  R                        Cambiar el par de hojas.
	  Rueda del ratón          Fijar/soltar objetivo (la parte del titán a la que apuntas).
]]

AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.PrintName = "Equipo de maniobras tridimensional"
SWEP.Category = "Attack on Titan"
SWEP.Author = "j0as"
SWEP.Instructions = "Clic dcho: ganchos | Espacio/Shift: gas | Clic izq: tajo | R: hojas | Rueda: fijar"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.ViewModel = "models/super_hard_blade/v_super_hard_blade.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFOV = 65
SWEP.UseHands = false
SWEP.ShowWorldModel = false
SWEP.HoldType = "knife"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.AOT_ODM = true
SWEP.IsAlwaysRaised = true

SWEP.WElements = {
	["left_cutter"] = {model = "models/olddeath/w_snk_sword.mdl", bone = "ValveBiped.Bip01_R_Hand", pos = Vector(1, -0.5, -2), angle = Angle(91.023, -101.25, -5.114), size = Vector(1, 1, 1), hoja = true},
	["right_cutter"] = {model = "models/olddeath/w_snk_sword.mdl", bone = "ValveBiped.Bip01_L_Hand", pos = Vector(2.273, 0.455, 2.273), angle = Angle(-72.614, -168.75, -31.705), size = Vector(1, 1, 1), hoja = true},
	["3d_maneuver"] = {model = "models/hatana/snk_gear_f.mdl", bone = "ValveBiped.Bip01_Spine", pos = Vector(-48.637, -4.092, 0.455), angle = Angle(90, -168.75, -13.296), size = Vector(1, 1, 1)},
}

local VEL_GANCHO = 7000
local VEC_CENTRO = Vector(0, 0, 40)

local SND_DISPARO = Sound("wire_shoot.wav")
local SND_IMPACTO = Sound("wire_hit.wav")
local SND_RECOGER = Sound("wire_move.wav")
local SND_TAJO = Sound("weapons/iceaxe/iceaxe_swing1.wav")
local SND_GIRO = Sound("slash.wav")
local SND_HOJAS = Sound("physics/metal/weapon_impact_soft2.wav")
local SND_VACIO = Sound("weapons/pistol/pistol_empty.wav")
local SND_FIJAR = Sound("buttons/blip1.wav")

local LADO_SUFIJO = {"I", "D"}

-- Acceso a las variables de red de cada gancho (I = izquierdo, D = derecho).
local function G(self, campo, lado) return self["Get" .. campo .. LADO_SUFIJO[lado]](self) end
local function S(self, campo, lado, valor) self["Set" .. campo .. LADO_SUFIJO[lado]](self, valor) end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "Gas")
	self:NetworkVar("Float", 1, "Filo")
	self:NetworkVar("Float", 2, "LanzI")
	self:NetworkVar("Float", 3, "LanzD")
	self:NetworkVar("Float", 4, "LlegaI")
	self:NetworkVar("Float", 5, "LlegaD")
	self:NetworkVar("Float", 6, "CuerdaI")
	self:NetworkVar("Float", 7, "CuerdaD")
	self:NetworkVar("Float", 8, "SigImpulso")
	self:NetworkVar("Float", 9, "Cambiando")
	self:NetworkVar("Float", 10, "UltimoGas")

	self:NetworkVar("Int", 0, "Hojas")
	self:NetworkVar("Int", 1, "HuesoI")
	self:NetworkVar("Int", 2, "HuesoD")
	self:NetworkVar("Int", 3, "ParteObjetivo")
	self:NetworkVar("Int", 4, "Combo")

	self:NetworkVar("Vector", 0, "AnclaI")
	self:NetworkVar("Vector", 1, "AnclaD")

	self:NetworkVar("Entity", 0, "EntI")
	self:NetworkVar("Entity", 1, "EntD")
	self:NetworkVar("Entity", 2, "Objetivo")
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)

	if (SERVER) then
		self:SetGas(100)
		self:SetFilo(100)
		self:SetHojas(AOT.Config("aotHojasRecambio", 4))
		self:SetHuesoI(-2)
		self:SetHuesoD(-2)
	end
end

-- ============================================================
-- Persistencia en el item de Helix (gas, filo y hojas sobreviven a desequipar)
-- ============================================================
function SWEP:BuscarItem()
	if (!ix) then return end

	local owner = self:GetOwner()
	if (!IsValid(owner) or !owner.GetCharacter) then return end

	local character = owner:GetCharacter()
	if (!character or !character:GetInventory()) then return end

	for _, item in pairs(character:GetInventory():GetItems()) do
		if (item.class == self:GetClass() and item:GetData("equip")) then
			return item
		end
	end
end

function SWEP:CargarItem()
	local item = self:BuscarItem()
	if (!item) then return end

	self.AOT_Item = item
	self:SetGas(item:GetData("aotGas", 100))
	self:SetFilo(item:GetData("aotFilo", 100))
	self:SetHojas(item:GetData("aotHojas", AOT.Config("aotHojasRecambio", 4)))
end

function SWEP:GuardarItem()
	local item = self.AOT_Item
	if (!item or !item.SetData) then return end

	item:SetData("aotGas", math.Round(self:GetGas(), 1))
	item:SetData("aotFilo", math.Round(self:GetFilo(), 1))
	item:SetData("aotHojas", self:GetHojas())
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 0.5)

	if (SERVER) then
		self.AOT_CargarEn = CurTime() + 0.3
	end

	return true
end

function SWEP:Holster()
	self:SoltarGanchos(false)

	if (SERVER) then self:GuardarItem() end

	return true
end

function SWEP:OnRemove()
	if (SERVER) then self:GuardarItem() end
end

function SWEP:OwnerChanged()
	self:SoltarGanchos(false)
end

-- ============================================================
-- Ganchos
-- ============================================================
function SWEP:GanchosActivos()
	return self:GetLanzI() > 0 or self:GetLanzD() > 0
end

function SWEP:Enganchado(lado)
	return G(self, "Cuerda", lado) > 0 and CurTime() >= G(self, "Llega", lado)
end

-- Posición mundial del ancla; devuelve nil si el gancho no existe o su entidad ya no es válida.
function SWEP:PosAncla(lado)
	if (G(self, "Lanz", lado) <= 0) then return end

	local hueso = G(self, "Hueso", lado)
	local ancla = G(self, "Ancla", lado)

	if (hueso <= -2) then return ancla end

	local ent = G(self, "Ent", lado)
	if (!IsValid(ent)) then return end

	if (hueso >= 0) then
		local m = ent:GetBoneMatrix(hueso)

		if (m) then
			return LocalToWorld(ancla, angle_zero, m:GetTranslation(), m:GetAngles())
		end
	end

	return ent:LocalToWorld(ancla)
end

-- Punto visible del extremo del cable (en vuelo o clavado).
function SWEP:PosPuntaCable(lado, origen)
	local ancla = self:PosAncla(lado)
	if (!ancla) then return end

	local lanz, llega = G(self, "Lanz", lado), G(self, "Llega", lado)

	if (CurTime() < llega and llega > lanz) then
		return LerpVector(math.Clamp((CurTime() - lanz) / (llega - lanz), 0, 1), origen, ancla), false
	end

	return ancla, true
end

-- ============================================================
-- Anclaje automático
-- Cada gancho busca su propio punto: el izquierdo a la izquierda y el derecho a la derecha,
-- por delante (según la cámara y la dirección en la que vuelas), preferiblemente en alto,
-- a media distancia y sobre paredes (no suelos ni cielo). Es lo que hace el juego oficial.
-- ============================================================
local ANCLA_GIRO = {10, 22, 34, 48, 64}
local ANCLA_ALTURA = {-40, -28, -16, -5, 6, 18}

function SWEP:AnclajeAuto()
	local owner = self:GetOwner()
	return IsValid(owner) and owner:GetInfoNum("aot_anclaje_auto", 1) != 0
end

function SWEP:BuscarAnclaje(lado)
	local owner = self:GetOwner()
	local eye = owner:GetShootPos()
	local rango = AOT.Config("aotRangoGancho", 2600)
	local ideal = math.min(900, rango * 0.4)
	local base = owner:EyeAngles()

	-- Si vas rápido, la búsqueda se orienta también hacia donde vuelas.
	local vel = owner:GetVelocity()
	if (vel:Length2D() > 400) then
		base.y = base.y + math.AngleDifference(vel:Angle().y, base.y) * 0.35
	end

	base.p = math.Clamp(base.p, -60, 30)

	local signo = lado == 1 and 1 or -1
	local filtro = function(ent) return ent != owner and !ent:IsPlayer() end
	local mejor, mejorPuntos

	for _, giro in ipairs(ANCLA_GIRO) do
		for _, altura in ipairs(ANCLA_ALTURA) do
			local dir = Angle(base.p + altura, base.y + giro * signo, 0):Forward()
			local tr = util.TraceLine({start = eye, endpos = eye + dir * rango, mask = MASK_SHOT, filter = filtro})

			-- Solo superficies "de frente" (paredes, troncos, titanes), no suelos ni roces.
			if (tr.Hit and !tr.HitSky and tr.HitNormal.z < 0.7 and tr.HitNormal:Dot(dir) < -0.15) then
				local dist = tr.Fraction * rango

				if (dist > 150) then
					local puntos = math.abs(dist - ideal) / ideal
						+ math.abs(giro - 25) / 60
						+ math.abs(altura + 15) / 60

					if (tr.HitPos.z < eye.z) then puntos = puntos + 0.5 end

					if (!mejorPuntos or puntos < mejorPuntos) then
						mejor, mejorPuntos = tr, puntos
					end
				end
			end
		end
	end

	return mejor
end

function SWEP:LanzarGanchos()
	local owner = self:GetOwner()

	if (self:GetGas() < 1) then
		if (IsFirstTimePredicted()) then self:EmitSound(SND_VACIO) end
		return
	end

	local eye = owner:GetShootPos()
	local rango = AOT.Config("aotRangoGancho", 2600)
	local objetivo = self:GetObjetivo()
	local parte = self:GetParteObjetivo()
	local ahora = CurTime()

	if (SERVER) then owner:LagCompensation(true) end

	for lado = 1, 2 do
		local dir, tr

		if (AOT.EsTitan(objetivo) and parte > 0) then
			-- Objetivo fijado: cada gancho a un lado de la parte del titán.
			local punto = AOT.PuntoParte(objetivo, parte)
			local separacion = objetivo:GetRight() * (lado == 1 and -1 or 1) * AOT.RadioParte(objetivo, parte) * 0.8
			dir = (punto + separacion - eye):GetNormalized()
		elseif (self:AnclajeAuto()) then
			-- Anclaje automático (como en el juego oficial): busca el mejor punto a cada lado.
			tr = self:BuscarAnclaje(lado)
			if (tr) then dir = tr.Normal end
		end

		if (!dir) then
			local ang = owner:EyeAngles()
			ang:RotateAroundAxis(ang:Up(), lado == 1 and 2.5 or -2.5)
			dir = ang:Forward()
		end

		tr = tr or util.TraceLine({
			start = eye,
			endpos = eye + dir * rango,
			mask = MASK_SHOT,
			filter = function(ent)
				return ent != owner and !ent:IsPlayer()
			end
		})

		S(self, "Lanz", lado, ahora)
		self["AOT_Sonado" .. lado] = false

		if (tr.Hit and !tr.HitSky) then
			local dist = tr.HitPos:Distance(eye)
			S(self, "Llega", lado, ahora + dist / VEL_GANCHO)
			S(self, "Cuerda", lado, math.max(dist, 50))

			local ent = tr.Entity

			if (IsValid(ent) and !ent:IsWorld()) then
				local hueso = -1

				if (tr.HitBox and ent.GetHitBoxBone) then
					local b = ent:GetHitBoxBone(tr.HitBox, (ent:GetHitboxSet()) or 0)
					if (b) then hueso = b end
				end

				local m = hueso >= 0 and ent:GetBoneMatrix(hueso)

				if (m) then
					S(self, "Ancla", lado, (WorldToLocal(tr.HitPos, angle_zero, m:GetTranslation(), m:GetAngles())))
				else
					hueso = -1
					S(self, "Ancla", lado, ent:WorldToLocal(tr.HitPos))
				end

				S(self, "Ent", lado, ent)
				S(self, "Hueso", lado, hueso)
			else
				S(self, "Ent", lado, NULL)
				S(self, "Hueso", lado, -2)
				S(self, "Ancla", lado, tr.HitPos)
			end
		else
			-- Fallo: el cable sale hasta el alcance máximo y se recoge.
			S(self, "Ent", lado, NULL)
			S(self, "Hueso", lado, -2)
			S(self, "Ancla", lado, eye + dir * rango)
			S(self, "Cuerda", lado, -1)
			S(self, "Llega", lado, ahora + rango / VEL_GANCHO)
		end
	end

	if (SERVER) then owner:LagCompensation(false) end

	self:SetGas(math.max(0, self:GetGas() - 1.5 * AOT.Config("aotGasConsumo", 1)))
	self:SetUltimoGas(ahora)

	if (IsFirstTimePredicted()) then
		self:EmitSound(SND_DISPARO, 75, math.random(95, 105))
	end
end

function SWEP:SoltarGanchos(conSonido)
	local habia = self:GanchosActivos()

	for lado = 1, 2 do
		S(self, "Lanz", lado, 0)
		S(self, "Llega", lado, 0)
		S(self, "Cuerda", lado, 0)
		S(self, "Ent", lado, NULL)
		S(self, "Hueso", lado, -2)
	end

	if (habia and conSonido and IsFirstTimePredicted()) then
		self:EmitSound(SND_RECOGER, 65, 120, 0.5)
	end
end

-- ============================================================
-- Física (llamada desde el hook Move, predicha)
-- ============================================================
function SWEP:MoverODM(ply, mv)
	if (IsValid(ply:GetNW2Entity("aot_agarre"))) then return end

	local dt = FrameTime()
	if (dt <= 0) then return end

	local ahora = CurTime()
	local vel = mv:GetVelocity()
	local centro = mv:GetOrigin() + VEC_CENTRO
	local ang = mv:GetAngles()
	local fwd, right = ang:Forward(), ang:Right()
	local enSuelo = ply:IsOnGround()
	local gas = self:GetGas()
	local usoGas = 0
	local fuerza = AOT.Config("aotFuerzaGancho", 2300)
	local tirar = mv:KeyDown(IN_ATTACK2) and !mv:KeyDown(IN_DUCK) and gas > 0
	local enganchados = 0
	local dirMedia = Vector(0, 0, 0)

	local fSign = mv:GetForwardSpeed() > 0 and 1 or (mv:GetForwardSpeed() < 0 and -1 or 0)
	local sSign = mv:GetSideSpeed() > 0 and 1 or (mv:GetSideSpeed() < 0 and -1 or 0)

	for lado = 1, 2 do
		if (self:Enganchado(lado)) then
			local ancla = self:PosAncla(lado)

			if (ancla) then
				local delta = ancla - centro
				local dist = delta:Length()

				if (dist > 1) then
					local dir = delta / dist
					local cuerda = G(self, "Cuerda", lado)

					enganchados = enganchados + 1
					dirMedia = dirMedia + dir

					-- El carrete mantiene el cable tenso: nunca se alarga, solo se recoge.
					cuerda = math.max(math.min(cuerda, dist), 50)

					if (tirar) then
						vel = vel + dir * (fuerza * 0.5) * dt
						usoGas = usoGas + 2.5 * dt
					end

					-- Restricción de cuerda: elimina la velocidad que se aleja del ancla (péndulo).
					if (dist > cuerda) then
						local radial = vel:Dot(dir)
						local correccion = (dist - cuerda) * 6

						if (radial < correccion) then
							vel = vel + dir * (correccion - radial)
						end
					end

					S(self, "Cuerda", lado, cuerda)
				end
			end
		end
	end

	if (enganchados > 0) then
		if (enSuelo and tirar and dirMedia.z > -0.3) then
			ply:SetGroundEntity(NULL)
			vel.z = math.max(vel.z, 220)
			enSuelo = false
		end

		-- Orbitar con A/D y ajustar con W/S.
		if (sSign != 0) then vel = vel + right * sSign * 1100 * dt end
		if (fSign != 0) then vel = vel + fwd * fSign * 350 * dt end
	elseif (!enSuelo and (fSign != 0 or sSign != 0)) then
		-- Control en el aire sin ganchos.
		local deseo = fwd * fSign + right * sSign
		deseo.z = 0
		deseo:Normalize()
		vel = vel + deseo * 220 * dt
	end

	-- Impulso de gas con espacio (en el aire o enganchado).
	if (mv:KeyPressed(IN_JUMP) and (!enSuelo or enganchados > 0) and gas >= 3 and ahora >= self:GetSigImpulso()) then
		local deseo = fwd * fSign + right * sSign

		if (deseo:LengthSqr() < 0.01) then
			deseo = Vector(0, 0, 1) + fwd * 0.3
		else
			deseo:Normalize()
			deseo = deseo + Vector(0, 0, 0.25)
		end

		deseo:Normalize()
		vel = vel + deseo * 520
		usoGas = usoGas + 3
		self:SetSigImpulso(ahora + 0.35)
	end

	-- Propulsión continua con Shift en el aire.
	if (mv:KeyDown(IN_SPEED) and !enSuelo and gas > 0) then
		vel = vel + fwd * 1150 * dt
		usoGas = usoGas + 9 * dt
	end

	local rapidez = vel:Length()
	if (rapidez > 3800) then vel = vel * (3800 / rapidez) end

	mv:SetVelocity(vel)

	if (usoGas > 0) then
		self:SetGas(math.max(0, gas - usoGas * AOT.Config("aotGasConsumo", 1)))
		self:SetUltimoGas(ahora)

		if (SERVER) then ply.AOT_RuidoHasta = ahora + 1.5 end
	end
end

-- ============================================================
-- Ciclo del arma
-- ============================================================
function SWEP:Think()
	local owner = self:GetOwner()
	if (!IsValid(owner)) then return end

	local agarrado = IsValid(owner:GetNW2Entity("aot_agarre"))

	if (owner:KeyPressed(IN_ATTACK2) and !agarrado) then
		self:LanzarGanchos()
	end

	if (self:GanchosActivos() and (!owner:KeyDown(IN_ATTACK2) or agarrado)) then
		self:SoltarGanchos(true)
	end

	for lado = 1, 2 do
		if (G(self, "Lanz", lado) > 0 and CurTime() >= G(self, "Llega", lado)) then
			local hueso = G(self, "Hueso", lado)

			if (G(self, "Cuerda", lado) < 0) then
				S(self, "Lanz", lado, 0)
				S(self, "Cuerda", lado, 0)
			elseif (hueso >= -1 and !IsValid(G(self, "Ent", lado))) then
				-- La entidad a la que estaba enganchado ha desaparecido.
				S(self, "Lanz", lado, 0)
				S(self, "Cuerda", lado, 0)
				S(self, "Hueso", lado, -2)
			elseif (!self["AOT_Sonado" .. lado]) then
				self["AOT_Sonado" .. lado] = true
				if (IsFirstTimePredicted()) then self:EmitSound(SND_IMPACTO, 70, math.random(95, 110), 0.6) end
			end
		end
	end

	if (owner:KeyPressed(IN_RELOAD)) then
		self:CambiarHojas()
	end

	if (SERVER) then
		if (self.AOT_CargarEn and CurTime() >= self.AOT_CargarEn) then
			self.AOT_CargarEn = nil
			self:CargarItem()
		end

		if (CurTime() >= (self.AOT_SigGuardado or 0)) then
			self.AOT_SigGuardado = CurTime() + 10
			self:GuardarItem()
		end

		-- Soltar el objetivo si ya no tiene sentido.
		local obj = self:GetObjetivo()
		if (IsValid(obj) and (!AOT.EsTitan(obj) or obj:GetMuerto() or obj:GetPos():DistToSqr(owner:GetPos()) > 7000 * 7000)) then
			self:SetObjetivo(NULL)
			self:SetParteObjetivo(0)
		end

		local parte = self:GetParteObjetivo()
		if (IsValid(obj) and parte > 0 and AOT.ParteCortada(obj, parte) and parte != AOT.PARTE.OJOS) then
			self:SetParteObjetivo(AOT.PARTE.NUCA)
		end
	end
end

function SWEP:CambiarHojas()
	if (self:GetCambiando() > CurTime() or self:GetFilo() >= 99) then return end

	local owner = self:GetOwner()

	if (self:GetHojas() <= 0) then
		if (SERVER) then AOT.Avisar(owner, "No te quedan hojas de recambio. Busca suministros.") end
		return
	end

	self:SetCambiando(CurTime() + 1.1)
	self:SetNextPrimaryFire(CurTime() + 1.1)
	self:SetHojas(self:GetHojas() - 1)
	self:SetFilo(100)
	self:SendWeaponAnim(ACT_VM_DRAW)
	owner:SetAnimation(PLAYER_RELOAD)

	if (IsFirstTimePredicted()) then self:EmitSound(SND_HOJAS, 70, 110) end
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if (self:GetCambiando() > CurTime()) then return end

	self:SetNextPrimaryFire(CurTime() + 0.42)

	local rapidez = owner:GetVelocity():Length()
	local giro = rapidez > 1100 and !owner:IsOnGround()

	self:SetCombo(1 - self:GetCombo())
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	owner:SetAnimation(PLAYER_ATTACK1)

	if (IsFirstTimePredicted()) then
		self:EmitSound(giro and SND_GIRO or SND_TAJO, 75, math.random(95, 112))
		owner:ViewPunch(Angle(-1.5, self:GetCombo() == 1 and 2 or -2, giro and 6 or 1.5))
	end

	if (SERVER) then
		owner:LagCompensation(true)
		AOT.ResolverCorte(owner, self, rapidez, giro)
		owner:LagCompensation(false)
	end
end

function SWEP:SecondaryAttack() end
function SWEP:Reload() end

-- Desgaste del filo; avisa cuando se parten.
function SWEP:Desgastar(cantidad)
	local antes = self:GetFilo()
	local despues = math.max(0, antes - cantidad * AOT.Config("aotDesgasteHojas", 1))

	self:SetFilo(despues)

	if (antes > 0 and despues <= 0 and SERVER) then
		self:GetOwner():EmitSound("physics/metal/metal_box_break" .. math.random(1, 2) .. ".wav", 70, 140)
		AOT.Avisar(self:GetOwner(), "¡Se te han partido las hojas! Pulsa R para cambiarlas.")
	end
end

if (SERVER) then
	function SWEP:AlternarFijacion()
		local owner = self:GetOwner()

		if (IsValid(self:GetObjetivo())) then
			self:SetObjetivo(NULL)
			self:SetParteObjetivo(0)
			owner:EmitSound(SND_FIJAR, 50, 80)
			return
		end

		local eye, aim = owner:GetShootPos(), owner:GetAimVector()
		local mejor, mejorParte, mejorPuntos

		for _, ent in ipairs(ents.FindInSphere(eye, 6000)) do
			if (AOT.EsTitan(ent) and !ent:GetMuerto()) then
				for parte = 1, 7 do
					if (parte == AOT.PARTE.OJOS or !AOT.ParteCortada(ent, parte)) then
						local punto = AOT.PuntoParte(ent, parte)
						local dir = punto - eye
						local dist = dir:Length()
						dir:Div(math.max(dist, 1))

						local cos = dir:Dot(aim)

						if (cos > 0.93) then
							local puntos = (1 - cos) * 20 + dist / 6000

							if (!mejorPuntos or puntos < mejorPuntos) then
								mejor, mejorParte, mejorPuntos = ent, parte, puntos
							end
						end
					end
				end
			end
		end

		if (mejor) then
			self:SetObjetivo(mejor)
			self:SetParteObjetivo(mejorParte)
			owner:EmitSound(SND_FIJAR, 50, 120)
		end
	end
end

-- ============================================================
-- Modelo en el mundo (espadas y equipo pegados a los huesos)
-- ============================================================
if (CLIENT) then
	function SWEP:CrearModelos()
		self.AOT_Modelos = {}

		for nombre, v in pairs(self.WElements) do
			if (util.IsValidModel(v.model)) then
				local m = ClientsideModel(v.model, RENDERGROUP_OPAQUE)

				if (IsValid(m)) then
					m:SetNoDraw(true)
					local matriz = Matrix()
					matriz:Scale(v.size)
					m:EnableMatrix("RenderMultiply", matriz)
					self.AOT_Modelos[nombre] = m
				end
			end
		end
	end

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()

		if (!IsValid(owner)) then
			self:DrawModel()
			return
		end

		if (!self.AOT_Modelos) then self:CrearModelos() end

		local rotas = self:GetFilo() <= 0

		for nombre, v in pairs(self.WElements) do
			local m = self.AOT_Modelos[nombre]
			local hueso = owner:LookupBone(v.bone)

			if (IsValid(m) and hueso and !(v.hoja and rotas)) then
				local matriz = owner:GetBoneMatrix(hueso)

				if (matriz) then
					local pos, ang = matriz:GetTranslation(), matriz:GetAngles()
					pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
					ang:RotateAroundAxis(ang:Up(), v.angle.y)
					ang:RotateAroundAxis(ang:Right(), v.angle.p)
					ang:RotateAroundAxis(ang:Forward(), v.angle.r)

					m:SetPos(pos)
					m:SetAngles(ang)
					m:SetupBones()
					m:DrawModel()
				end
			end
		end
	end

	function SWEP:OnRemove()
		for _, m in pairs(self.AOT_Modelos or {}) do
			if (IsValid(m)) then m:Remove() end
		end
	end
end
