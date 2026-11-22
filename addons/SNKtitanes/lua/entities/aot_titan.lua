--[[
	Titán (nextbot)

	- Navega con navmesh si existe; si no, con esquiva por sensores. Detecta atascos y se recoloca.
	- Ve en un cono frontal y oye el gas del 3DMG. Cegado, solo oye de cerca.
	- Partes: nuca (solo por detrás/arriba, la única que mata), ojos (ceguera), brazos (se cercenan),
	  tendones (cojea; con los dos, cae al suelo). Todo regenera con vapor.
	- Agarra, sostiene y lleva a la boca. La presa puede forcejear; cortar esa mano la libera.
]]

AddCSLuaFile()

-- Requiere el addon "SNK Armas" (núcleo AOT).
if (!AOT or !AOT.PARTE) then
	ErrorNoHalt("[SNK Titanes] Falta el addon 'SNK Armas' (SNKarmas).\n")
	return
end

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
ENT.PrintName = "Titán"
ENT.Category = "Attack on Titan"
ENT.Spawnable = false
ENT.AdminOnly = true

ENT.AOT_EsTitan = true
ENT.AOT_Aberrante = false

ENT.Modelos = {
	"models/hydralis_titan1.mdl",
	"models/hydralis_titan2.mdl",
	"models/hydralis_titan3.mdl",
	"models/hydralis_titan4.mdl",
	"models/hydralis_titan5.mdl",
}

ENT.VelAndar = 120
ENT.VelCorrer = 240
ENT.MultEscala = 1

local P = AOT.PARTE
local H = AOT.HUESO

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Escala")
	self:NetworkVar("Float", 1, "CegadoHasta")
	self:NetworkVar("Float", 2, "RegenBrazoI")
	self:NetworkVar("Float", 3, "RegenBrazoD")
	self:NetworkVar("Float", 4, "RegenTendonI")
	self:NetworkVar("Float", 5, "RegenTendonD")
	self:NetworkVar("Float", 6, "DurBrazoI")
	self:NetworkVar("Float", 7, "DurBrazoD")
	self:NetworkVar("Float", 8, "CicloDerribo")

	self:NetworkVar("Bool", 0, "Muerto")
	self:NetworkVar("Bool", 1, "Derribado")

	self:NetworkVar("Entity", 0, "Presa")
end

function ENT:Ciego()
	return self:GetCegadoHasta() > CurTime()
end

-- Huesos que cuelgan de uno (él incluido): el brazo desde el codo hasta los dedos.
function ENT:Rama(nombre)
	if (self.AOT_RamasModelo != self:GetModel()) then
		self.AOT_Ramas = {}
		self.AOT_RamasModelo = self:GetModel()
	end

	if (self.AOT_Ramas[nombre]) then return self.AOT_Ramas[nombre] end

	local raiz = AOT.Hueso(self, nombre)
	local lista = {}

	if (raiz) then
		for b = 0, self:GetBoneCount() - 1 do
			local actual = b

			while (actual and actual >= 0) do
				if (actual == raiz) then
					lista[#lista + 1] = b
					break
				end

				actual = self:GetBoneParent(actual)
			end
		end
	end

	self.AOT_Ramas[nombre] = lista
	return lista
end

-- Tamaño del brazo de un lado: 1 entero, 0 recién cortado. Tras el corte solo hay muñón y vapor;
-- luego el brazo vuelve a crecer desde el codo poco a poco.
function ENT:FactorBrazo(lado)
	local fin = lado == 1 and self:GetRegenBrazoI() or self:GetRegenBrazoD()
	local ahora = CurTime()
	if (fin <= ahora) then return 1 end

	local dur = math.max(lado == 1 and self:GetDurBrazoI() or self:GetDurBrazoD(), 1)
	local f = math.Clamp(1 - (fin - ahora) / dur, 0, 1)
	f = math.Clamp((f - 0.3) / 0.7, 0, 1)

	return f * f * (3 - 2 * f)
end

-- Los jugadores atraviesan a los titanes (si no, quedan atrapados dentro de su caja); el resto colisiona normal.
hook.Add("ShouldCollide", "AOT_TitanJugadores", function(a, b)
	if (a.AOT_EsTitan and b:IsPlayer()) or (b.AOT_EsTitan and a:IsPlayer()) then return false end
end)

if (SERVER) then
	local ignorarJugadores = GetConVar("ai_ignoreplayers")

	-- ============================================================
	-- Inicio y tamaño
	-- ============================================================
	function ENT:Initialize()
		self:SetModel(self.Modelos[math.random(#self.Modelos)])

		self.AOT_RegenDur = {}
		self.AOT_VidaBrazo = {}
		self.AOT_VidaTendon = {}

		self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
		-- Los jugadores atraviesan al titán (si no, quedan atrapados dentro de su caja al alcanzarlos).
		-- Los trazos de los ganchos y los tajos (que miden por huesos) siguen funcionando.
		self:SetCustomCollisionCheck(true)
		self:SetHealth(1000000)
		self:SetMaxHealth(1000000)

		self.loco:SetAcceleration(450)
		self.loco:SetDeceleration(900)
		self.loco:SetDeathDropHeight(100000)

		local minimo = AOT.Config("aotTitanEscalaMin", 4)
		local maximo = math.max(minimo, AOT.Config("aotTitanEscalaMax", 9))

		if (self.PostInicio) then self:PostInicio() end

		self:FijarEscala(math.Rand(minimo, maximo) * (self.MultEscala or 1))
		self:Animar(ACT_WALK)
	end

	function ENT:FijarEscala(escala)
		escala = math.Clamp(escala, 0.5, 20)

		self:SetModelScale(escala, 0)
		self:SetEscala(escala)

		local ancho = math.Clamp(5 * escala, 16, 48)
		self:SetCollisionBounds(Vector(-ancho, -ancho, 0), Vector(ancho, ancho, math.Clamp(70 * escala, 72, 200)))

		-- La caja de colisión es baja a propósito (para navegar), pero los trazos (ganchos, balas en
		-- los ojos) tienen que poder tocar todo el cuerpo, hasta la cabeza.
		self:SetSurroundingBounds(Vector(-30, -30, 0) * escala, Vector(30, 30, 80) * escala)

		-- Un titán no salta: la altura de salto es igual a la de paso, así que el navegador nunca salta.
		local paso = math.Clamp(14 * escala, 24, 120)
		self.loco:SetStepHeight(paso)
		self.loco:SetJumpHeight(paso)

		self.AOT_VidaBrazoMax = 50 + 6 * escala
		self.AOT_VidaTendonMax = 22 + 2.5 * escala
		self.AOT_NucaMax = 35 + 4 * escala

		self.AOT_VidaBrazo = {self.AOT_VidaBrazoMax, self.AOT_VidaBrazoMax}
		self.AOT_VidaTendon = {self.AOT_VidaTendonMax, self.AOT_VidaTendonMax}
		self.AOT_NucaVida = self.AOT_NucaMax
	end

	-- ============================================================
	-- Animación
	-- ============================================================
	-- Las secuencias se reproducen por nombre y el estado se guarda aquí: GetActivity() no es fiable
	-- con estos modelos (devolvía otro valor que ACT_WALK y reiniciaba la animación en cada tick).
	function ENT:Animar(act)
		local nombre = (act == ACT_RUN) and "run" or "walk"

		if (self.AOT_Manual or self.AOT_CicloFijo or self.AOT_Anim != nombre) then
			self.AOT_Manual = false
			self.AOT_CicloFijo = false
			self.AOT_Anim = nombre

			local seq = self:LookupSequence(nombre)

			if (seq and seq >= 0) then
				self:ResetSequence(seq)
				self:ResetSequenceInfo()
				self:SetCycle(0)
			else
				self:StartActivity(act)
			end
		end
	end

	function ENT:Secuencia(nombre, ritmo)
		local seq = self:LookupSequence(nombre)
		if (!seq or seq < 0) then return 1 end

		ritmo = ritmo or 1
		self.AOT_Manual = true
		self.AOT_CicloFijo = false
		self.AOT_Anim = nil

		self:ResetSequence(seq)
		self:ResetSequenceInfo()
		self:SetCycle(0)
		self:SetPlaybackRate(ritmo)

		return self:SequenceDuration(seq) / ritmo
	end

	function ENT:BodyUpdate()
		if (self.AOT_CicloFijo) then return end

		if (self.AOT_Manual) then
			self:FrameAdvance()
			return
		end

		-- Las secuencias de estos modelos no tienen velocidad de suelo: el ritmo sigue a la velocidad real,
		-- para que los pies no patinen. Parado, se queda en su pose.
		local vel = self.loco:GetVelocity():Length2D()
		local base = (self.AOT_Anim == "run" and 90 or 40) * self:GetEscala()

		self:SetPlaybackRate(vel < 4 and 0 or math.Clamp(vel / base, 0.2, 2.5))
		self:FrameAdvance()
	end

	-- ============================================================
	-- Percepción
	-- ============================================================
	function ENT:ObjetivoValido(p)
		if (!IsValid(p) or !p:IsPlayer() or !p:Alive()) then return false end
		if (p:GetMoveType() == MOVETYPE_NOCLIP or p:GetObserverMode() != OBS_MODE_NONE) then return false end
		if (p:GetNoDraw() or p:GetColor().a < 50) then return false end
		if (p:GetModelScale() > 2) then return false end -- cambiantes en forma de titán
		if (p.GetCharacter and !p:GetCharacter()) then return false end
		if (ignorarJugadores and ignorarJugadores:GetBool()) then return false end

		local captor = p:GetNW2Entity("aot_agarre")
		if (IsValid(captor) and captor != self) then return false end

		return true
	end

	function ENT:Percibe(p)
		local cabeza = AOT.PosHueso(self, H.CABEZA)
		local ojo = p:EyePos()
		local dist = ojo:Distance(cabeza)
		local ruido = (p.AOT_RuidoHasta or 0) > CurTime()

		if (self:Ciego()) then
			return dist < 450 or (ruido and dist < 700)
		end

		if (dist > 7000) then return false end
		if (dist < 300 or (ruido and dist < 1800)) then return true end

		local dir = (ojo - cabeza):GetNormalized()
		if (dir:Dot(self:GetForward()) < -0.35) then return false end

		local tr = util.TraceLine({start = cabeza, endpos = ojo, filter = {self, p}, mask = MASK_VISIBLE})
		return !tr.Hit
	end

	function ENT:Vecinos(p)
		local n = 0
		for _, otro in ipairs(player.GetAll()) do
			if (otro != p and otro:Alive() and otro:GetPos():DistToSqr(p:GetPos()) < 600 * 600) then n = n + 1 end
		end
		return n
	end

	function ENT:BuscarObjetivo()
		self.AOT_SigBusqueda = CurTime() + 0.75

		if (IsValid(self.AOT_Provocado) and self:ObjetivoValido(self.AOT_Provocado) and !self:Ciego()) then
			local p = self.AOT_Provocado
			self.AOT_Provocado = nil
			return p
		end

		local mejor, mejorPuntos

		for _, p in ipairs(player.GetAll()) do
			if (self:ObjetivoValido(p) and self:Percibe(p)) then
				local puntos = p:GetPos():Distance(self:GetPos())

				-- Los aberrantes son impredecibles y prefieren los grupos.
				if (self.AOT_Aberrante) then
					puntos = puntos * math.Rand(0.4, 1.6) - self:Vecinos(p) * 300
				end

				if (!mejorPuntos or puntos < mejorPuntos) then
					mejor, mejorPuntos = p, puntos
				end
			end
		end

		return mejor
	end

	-- ============================================================
	-- Movimiento y atascos
	-- ============================================================
	function ENT:Velocidad(correr)
		local v = (correr and self.VelCorrer or self.VelAndar) * math.sqrt(self:GetEscala() / 5) * AOT.Config("aotTitanVelocidad", 1)

		if (AOT.ParteCortada(self, P.TENDON_I) or AOT.ParteCortada(self, P.TENDON_D)) then v = v * 0.4 end
		if (self:Ciego()) then v = v * 0.5 end

		return v
	end

	function ENT:HayNavmesh()
		return navmesh.IsLoaded() and navmesh.GetNavAreaCount() > 0
	end

	function ENT:PasoHacia(path, destino, correr)
		self:Animar(correr and ACT_RUN or ACT_WALK)
		self.loco:SetDesiredSpeed(self:Velocidad(correr))

		local desviando = (self.AOT_DesvioHasta or 0) > CurTime()

		if (self:HayNavmesh() and !desviando) then
			if (!path:IsValid() or path:GetAge() > 0.6 or path:GetEnd():DistToSqr(destino) > 200 * 200) then
				path:Compute(self, destino)
			end

			if (path:IsValid()) then
				path:Update(self)
			else
				self:Directo(destino)
			end
		else
			self:Directo(destino)
		end

		self:ComprobarAtasco()
	end

	-- Movimiento directo con "bigotes": si hay algo delante, prueba ángulos hasta encontrar paso.
	function ENT:Directo(destino)
		local pos = self:GetPos()
		local escala = self:GetEscala()
		local dir = destino - pos
		dir.z = 0

		if (dir:LengthSqr() < 100) then return end
		dir:Normalize()

		if ((self.AOT_DesvioHasta or 0) > CurTime() and self.AOT_DesvioDir) then
			dir = self.AOT_DesvioDir
		else
			local altura = Vector(0, 0, math.min(12 * escala, 80))
			local largo = math.max(70, 14 * escala)

			local function Libre(d)
				local tr = util.TraceHull({
					start = pos + altura,
					endpos = pos + altura + d * largo,
					mins = Vector(-16, -16, 0),
					maxs = Vector(16, 16, 16),
					mask = MASK_NPCSOLID_BRUSHONLY,
					filter = self
				})
				return !tr.Hit
			end

			if (!Libre(dir)) then
				for _, a in ipairs({35, -35, 70, -70, 110, -110}) do
					local d = Vector(dir)
					d:Rotate(Angle(0, a, 0))

					if (Libre(d)) then
						self.AOT_DesvioDir = d
						self.AOT_DesvioHasta = CurTime() + 1.2
						dir = d
						break
					end
				end
			end
		end

		local meta = pos + dir * 300
		self.loco:Approach(meta, 1)
		self.loco:FaceTowards(meta)
	end

	function ENT:ComprobarAtasco()
		local ahora = CurTime()
		if (ahora < (self.AOT_SigChequeo or 0)) then return end
		self.AOT_SigChequeo = ahora + 1

		local pos = self:GetPos()
		local movido = self.AOT_PosAnterior and pos:Distance(self.AOT_PosAnterior) or 999
		self.AOT_PosAnterior = pos

		if (self.loco:GetDesiredSpeed() < 10) then
			self.AOT_Atascos = 0
			return
		end

		if (movido < math.max(self.loco:GetDesiredSpeed() * 0.15, 15) or self.loco:IsStuck()) then
			self.AOT_Atascos = (self.AOT_Atascos or 0) + 1
			self:Desatascar()
		else
			self.AOT_Atascos = 0
		end
	end

	function ENT:Desatascar()
		local n = self.AOT_Atascos or 1
		self.loco:ClearStuck()

		if (n <= 3) then
			-- Rodear el obstáculo por un lado.
			self.AOT_DesvioDir = self:GetRight() * (math.random(2) == 1 and 1 or -1) + self:GetForward() * -0.3
			self.AOT_DesvioDir:Normalize()
			self.AOT_DesvioHasta = CurTime() + 1.5
		else
			-- Recolocación: busca un hueco libre cerca (un titán no se queda clavado en un árbol).
			local mins, maxs = self:GetCollisionBounds()
			local pos = self:GetPos()

			for _ = 1, 10 do
				local candidato = pos + Angle(0, math.random(0, 359), 0):Forward() * math.random(80, 220) + Vector(0, 0, 24)
				local tr = util.TraceHull({start = candidato, endpos = candidato, mins = mins, maxs = maxs, mask = MASK_NPCSOLID_BRUSHONLY, filter = self})

				if (!tr.Hit and !tr.StartSolid) then
					local suelo = util.TraceLine({start = candidato, endpos = candidato - Vector(0, 0, 600), mask = MASK_NPCSOLID_BRUSHONLY, filter = self})
					self:SetPos(suelo.HitPos + Vector(0, 0, 2))
					break
				end
			end

			self.AOT_Atascos = 0
		end
	end

	-- ============================================================
	-- Comportamiento
	-- ============================================================
	function ENT:RunBehaviour()
		while (true) do
			if (self:GetMuerto()) then
				coroutine.wait(1)
			elseif (self:GetDerribado()) then
				self:EstadoDerribado()
			elseif (IsValid(self:GetPresa())) then
				self:EstadoComer()
			else
				local objetivo = self:BuscarObjetivo()

				if (IsValid(objetivo)) then
					self:Perseguir(objetivo)
				else
					self:Deambular()
				end
			end

			coroutine.yield()
		end
	end

	function ENT:Interrumpido()
		return self:GetMuerto() or self:GetDerribado() or IsValid(self:GetPresa())
	end

	function ENT:Deambular()
		local destino

		if (self:HayNavmesh()) then
			local areas = navmesh.Find(self:GetPos(), self:Ciego() and 600 or 2500, 300, 300)
			if (#areas > 0) then destino = areas[math.random(#areas)]:GetRandomPoint() end
		end

		destino = destino or (self:GetPos() + Angle(0, math.random(0, 359), 0):Forward() * math.random(500, 1500))

		local path = Path("Follow")
		path:SetMinLookAheadDistance(300)
		path:SetGoalTolerance(80)

		local inicio = CurTime()

		while (CurTime() - inicio < 15) do
			if (self:Interrumpido()) then return end
			if (self:GetPos():DistToSqr(destino) < 150 * 150) then break end
			if (CurTime() >= (self.AOT_SigBusqueda or 0) and IsValid(self:BuscarObjetivo())) then return end

			self:PasoHacia(path, destino, false)
			coroutine.yield()
		end

		self.loco:SetDesiredSpeed(0)
		coroutine.wait(math.Rand(0.5, 2.5))
	end

	function ENT:AjustarDestino(destino)
		if (self.AOT_Aberrante and self:GetPos():DistToSqr(destino) > 600 * 600) then
			return destino + self:GetRight() * math.sin(CurTime() * 1.7 + self:EntIndex()) * 350
		end

		return destino
	end

	-- Distancia horizontal al objetivo (el titán es muy alto: medir en 3D desde el pecho dejaba
	-- fuera a cualquiera que estuviera a sus pies).
	function ENT:DistPlano(objetivo)
		return (objetivo:GetPos() - self:GetPos()):Length2D()
	end

	function ENT:EnAlcance(objetivo)
		-- Sin brazos no puede atrapar a nadie: solo persigue y pisa hasta que le vuelvan a crecer.
		if (#self:ManosLibres() == 0) then return false end

		local escala = self:GetEscala()
		local p = objetivo:WorldSpaceCenter()
		local pos = self:GetPos()

		local dir = objetivo:GetPos() - pos
		dir.z = 0
		local plano = dir:Length()
		if (plano > 0.01) then dir:Normalize() end

		local delante = plano < 6 * escala or dir:Dot(self:GetForward()) > 0.3

		-- Alcance a ras de suelo: la mano baja a por quien esté delante.
		if (delante and plano < 26 * escala and p.z - pos.z < 40 * escala) then return true end

		-- Alcance a media altura (jugadores en el aire con el 3DMG).
		local dist = p:Distance(AOT.PosHueso(self, H.PECHO))
		return dist < 28 * escala and (delante or dist < 10 * escala)
	end

	function ENT:Perseguir(objetivo)
		local path = Path("Follow")
		path:SetMinLookAheadDistance(300)
		path:SetGoalTolerance(60)

		self.AOT_Objetivo = objetivo
		self.AOT_UltimaVista = CurTime()
		self.AOT_UltimaPos = objetivo:GetPos()

		while (IsValid(objetivo)) do
			if (self:Interrumpido()) then return end
			if (!self:ObjetivoValido(objetivo)) then break end

			if (self:Percibe(objetivo)) then
				self.AOT_UltimaVista = CurTime()
				self.AOT_UltimaPos = objetivo:GetPos()
			elseif (self:Ciego() or CurTime() - self.AOT_UltimaVista > 6) then
				break
			end

			-- Cambia a una presa mucho más cercana si aparece.
			if (CurTime() >= (self.AOT_SigBusqueda or 0)) then
				local otro = self:BuscarObjetivo()

				if (IsValid(otro) and otro != objetivo and otro:GetPos():DistToSqr(self:GetPos()) < objetivo:GetPos():DistToSqr(self:GetPos()) * 0.25) then
					objetivo = otro
					self.AOT_Objetivo = otro
				end
			end

			if (CurTime() >= (self.AOT_SigAtaque or 0) and self:EnAlcance(objetivo)) then
				self:Atacar(objetivo)
				return
			end

			local recienVisto = CurTime() - self.AOT_UltimaVista < 0.5
			local destino = self:AjustarDestino(recienVisto and objetivo:GetPos() or self.AOT_UltimaPos)
			local distPlano = (destino - self:GetPos()):Length2D()

			if (recienVisto and self:DistPlano(objetivo) < 16 * self:GetEscala()) then
				-- Ya la tiene a los pies: se para y se gira hacia ella (sin empujarla ni subirse encima)
				-- hasta que pueda atacar.
				self:Animar(ACT_WALK)
				self.loco:SetDesiredSpeed(0)
				self.loco:FaceTowards(objetivo:GetPos())
				self.AOT_Atascos = 0
			else
				-- Los titanes normales solo caminan; solo los aberrantes corren.
				self:PasoHacia(path, destino, self.AOT_Aberrante)
			end

			coroutine.yield()
		end

		self.AOT_Objetivo = nil
	end

	-- ============================================================
	-- Ataques: agarrar, manotazo y mordisco
	-- ============================================================
	function ENT:ManosLibres()
		local manos = {}
		if (!AOT.ParteCortada(self, P.BRAZO_I)) then manos[#manos + 1] = 1 end
		if (!AOT.ParteCortada(self, P.BRAZO_D)) then manos[#manos + 1] = 2 end
		return manos
	end

	function ENT:PosMano(lado)
		if (lado == 1) then return AOT.PosHueso(self, H.MANO_I) end
		if (lado == 2) then return AOT.PosHueso(self, H.MANO_D) end
		return AOT.PosBoca(self)
	end

	function ENT:Atacar(objetivo)
		self.AOT_SigAtaque = CurTime() + (self.AOT_Aberrante and 2 or 3)
		self.loco:SetDesiredSpeed(0)

		local manos = self:ManosLibres()
		local escala = self:GetEscala()
		local duracion = self:Secuencia("grab_player", self.AOT_Aberrante and 1.3 or 1)
		local inicio = CurTime()
		local hecho = false

		-- A veces, en vez de agarrar, da un manotazo que lanza y hiere.
		local golpear = math.random() < (self.AOT_Aberrante and 0.4 or 0.3)

		self:EmitSound("npc/zombie_poison/pz_warn" .. math.random(1, 2) .. ".wav", 95, 50)

		while (CurTime() - inicio < duracion) do
			if (self:GetMuerto() or self:GetDerribado()) then break end

			-- Si le cortan los brazos en pleno ataque, se cancela: sin manos no agarra.
			manos = self:ManosLibres()
			if (#manos == 0) then break end

			if (IsValid(objetivo)) then self.loco:FaceTowards(objetivo:GetPos()) end

			local ciclo = (CurTime() - inicio) / duracion

			if (!hecho and ciclo > 0.22 and ciclo < 0.65) then
				-- Cualquiera que esté al alcance de alguna de sus manos libres.
				for _, lado in ipairs(manos) do
					local mano = self:PosMano(lado)

					for _, p in ipairs(player.GetAll()) do
						if (self:ObjetivoValido(p) and p:WorldSpaceCenter():Distance(mano) < 11 * escala) then
							hecho = true

							if (golpear or p:GetVelocity():Length() > 700) then
								self:Manotazo(p, mano)
							else
								self:Agarrar(p, lado)
							end

							break
						end
					end

					if (hecho) then break end
				end

				-- Respaldo: si la animación no pasa la mano justo por la presa, la atrapa igual si está delante.
				if (!hecho and ciclo > 0.45 and IsValid(objetivo) and self:ObjetivoValido(objetivo) and self:EnAlcance(objetivo)
					and objetivo:GetVelocity():Length() < 500) then
					hecho = true

					if (golpear) then
						self:Manotazo(objetivo, self:PosMano(manos[1]))
					else
						self:Agarrar(objetivo, manos[1])
					end
				end
			end

			if (IsValid(self:GetPresa())) then return end

			coroutine.yield()
		end

		self:Animar(ACT_WALK)
	end

	function ENT:Manotazo(p, mano)
		local empuje = (p:WorldSpaceCenter() - mano):GetNormalized() * 900 + Vector(0, 0, 250)

		p:SetVelocity(empuje)
		p:TakeDamage(AOT.Config("aotDanoGolpe", 35), self, self)
		p:ViewPunch(Angle(math.Rand(-15, 15), math.Rand(-15, 15), math.Rand(-20, 20)))
		p:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 80)
		util.ScreenShake(p:GetPos(), 10, 10, 0.5, 300)
	end

	local function Grito(p)
		local voz = (p:GetModel() or ""):lower():find("femin") and "female01" or "male01"
		p:EmitSound("vo/npc/" .. voz .. "/pain0" .. math.random(7, 9) .. ".wav", 85)
	end

	function ENT:Agarrar(p, lado)
		p:SetNW2Entity("aot_agarre", self)
		p:SetMoveType(MOVETYPE_NONE)

		local wep = p:GetActiveWeapon()
		if (IsValid(wep) and wep.AOT_ODM) then wep:SoltarGanchos(false) end

		self:SetPresa(p)
		self.AOT_ManoPresa = lado
		self.AOT_InicioPresa = CurTime()
		self.AOT_Forcejeo = 0

		-- El mordisco directo (sin manos) va mucho más rápido.
		if (lado == 0) then
			self.AOT_InicioPresa = CurTime() - math.max(0, AOT.Config("aotTiempoComer", 3.5) - 1.2)
		end

		Grito(p)
		AOT.Avisar(p, "¡Un titán te ha atrapado! Clic izquierdo para forcejear con tus hojas.")
	end

	function ENT:Soltar(empujar)
		local presa = self:GetPresa()
		self:SetPresa(NULL)

		if (IsValid(presa)) then
			presa:SetNW2Entity("aot_agarre", NULL)

			if (presa:GetMoveType() == MOVETYPE_NONE) then
				presa:SetMoveType(MOVETYPE_WALK)
			end

			if (empujar) then
				presa:SetVelocity(self:GetForward() * 250 + Vector(0, 0, 150))
			end
		end
	end

	-- La presa sigue a la mano y, en el último segundo, se lleva a la boca.
	function ENT:ActualizarPresa()
		local presa = self:GetPresa()
		if (!IsValid(presa)) then return end

		if (!presa:Alive()) then
			self:Soltar(false)
			return
		end

		local t = CurTime() - (self.AOT_InicioPresa or CurTime())
		local tiempo = AOT.Config("aotTiempoComer", 3.5)
		local f = math.Clamp((t - (tiempo - 1)) / 1, 0, 1)
		f = f * f * (3 - 2 * f)

		local pos = LerpVector(f, self:PosMano(self.AOT_ManoPresa or 1), AOT.PosBoca(self))
		presa:SetPos(pos - Vector(0, 0, 40))
		presa:SetLocalVelocity(vector_origin)
	end

	function ENT:EstadoComer()
		self.loco:SetDesiredSpeed(0)
		self:Secuencia("grab_player_idle", 1)

		local tiempo = AOT.Config("aotTiempoComer", 3.5)

		while (IsValid(self:GetPresa())) do
			if (self:GetMuerto() or self:GetDerribado()) then
				self:Soltar(true)
				return
			end

			if (CurTime() - self.AOT_InicioPresa >= tiempo) then
				self:Devorar()
				coroutine.wait(1.5) -- masticar
				break
			end

			coroutine.yield()
		end

		self:Animar(ACT_WALK)
	end

	function ENT:Devorar()
		local presa = self:GetPresa()
		local boca = AOT.PosBoca(self)

		self:Sangrar(boca, 120)
		self:EmitSound("npc/barnacle/barnacle_crunch2.wav", 100, 70)
		self:EmitSound("physics/flesh/flesh_bloody_break.wav", 95, 80)
		util.Decal("Blood", boca, boca - Vector(0, 0, 2000), self)

		self:Soltar(false)

		if (IsValid(presa) and presa:Alive()) then
			local info = DamageInfo()
			info:SetDamage(AOT.Config("aotDanoComer", 1000))
			info:SetDamageType(DMG_CRUSH)
			info:SetAttacker(self)
			info:SetInflictor(self)
			info:SetDamagePosition(boca)
			presa:TakeDamageInfo(info)
		end
	end

	-- La presa forcejea con sus hojas: retrasa el mordisco y, con 5 tajos, corta la mano.
	function ENT:Forcejeo(p)
		if (p != self:GetPresa()) then return end

		self.AOT_Forcejeo = (self.AOT_Forcejeo or 0) + 1
		self.AOT_InicioPresa = math.min(CurTime(), self.AOT_InicioPresa + 0.35)
		self:Sangrar(self:PosMano(self.AOT_ManoPresa or 1), 30)

		if (self.AOT_Forcejeo >= 5 and (self.AOT_ManoPresa or 0) > 0) then
			AOT.Marcador(p, "¡TE HAS LIBERADO!", Color(120, 255, 120))
			self:Amputar(self.AOT_ManoPresa, p)
		else
			AOT.Marcador(p, "¡FORCEJEA! " .. self.AOT_Forcejeo .. "/5", Color(255, 200, 80))
		end
	end

	-- ============================================================
	-- Daño por partes
	-- ============================================================
	function ENT:Sangrar(pos, cantidad)
		local veces = math.Clamp(math.floor(cantidad / 25), 1, 6)

		for _ = 1, veces do
			local efecto = EffectData()
			efecto:SetOrigin(pos + VectorRand() * 10)
			efecto:SetNormal(VectorRand())
			efecto:SetScale(3)
			util.Effect("BloodImpact", efecto)
		end
	end

	function ENT:RecibirCorte(atacante, parte, dano, punto, rapidez)
		if (self:GetMuerto()) then return end

		self:Sangrar(punto, dano)
		self:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", 85, 70)

		if (!IsValid(self.AOT_Objetivo)) then self.AOT_Provocado = atacante end

		if (parte == P.NUCA) then
			-- La nuca solo cuenta si el corte llega desde atrás o desde arriba.
			-- Solo se rechaza el corte si llega claramente de frente y desde abajo (la garganta).
			-- Tumbado, la nuca queda expuesta desde cualquier lado.
			local nuca = AOT.PuntoParte(self, P.NUCA)
			local desde = (atacante:GetShootPos() - nuca):GetNormalized()

			if (!self:GetDerribado() and desde:Dot(self:GetForward()) > 0.55 and atacante:GetShootPos().z < nuca.z) then
				AOT.Marcador(atacante, "Garganta: ¡la nuca está por detrás!", Color(255, 200, 120))
				return
			end

			-- Un buen tajo (con algo de velocidad, o con el titán derribado) mata de un golpe.
			if (self:GetDerribado()) then dano = dano * 2 end

			self.AOT_NucaVida = self.AOT_NucaVida - dano
			self.AOT_NucaRegen = CurTime() + 10

			if (self.AOT_NucaVida <= 0 or dano >= self.AOT_NucaMax * 0.5) then
				AOT.Marcador(atacante, "¡NUCA!", Color(255, 60, 60))
				self:Morir(atacante)
			else
				local pct = math.Round(100 * (1 - self.AOT_NucaVida / self.AOT_NucaMax))
				AOT.Marcador(atacante, "Nuca " .. pct .. "%: ¡otro tajo!", Color(255, 170, 60))
			end
		elseif (parte == P.OJOS) then
			self:Cegar(AOT.Config("aotRegenOjos", 12))
			AOT.Marcador(atacante, "¡CEGADO!", Color(120, 200, 255))
		elseif (parte == P.BRAZO_I or parte == P.BRAZO_D) then
			local lado = parte == P.BRAZO_I and 1 or 2
			self.AOT_VidaBrazo[lado] = self.AOT_VidaBrazo[lado] - dano

			if (self.AOT_VidaBrazo[lado] <= 0) then
				self:Amputar(lado, atacante)
				AOT.Marcador(atacante, "¡BRAZO CERCENADO!", Color(255, 90, 90))
			else
				AOT.Marcador(atacante, "Brazo herido", Color(230, 230, 230))
			end
		elseif (parte == P.TENDON_I or parte == P.TENDON_D) then
			local lado = parte == P.TENDON_I and 1 or 2
			self.AOT_VidaTendon[lado] = self.AOT_VidaTendon[lado] - dano

			if (self.AOT_VidaTendon[lado] <= 0) then
				self:CortarTendon(lado)
				AOT.Marcador(atacante, self:GetDerribado() and "¡DERRIBADO!" or "¡TENDÓN CORTADO!", Color(255, 230, 90))
			else
				AOT.Marcador(atacante, "Pierna herida", Color(230, 230, 230))
			end
		else
			AOT.Marcador(atacante, "Corte", Color(210, 210, 210))
		end
	end

	function ENT:Amputar(lado, atacante)
		local dur = AOT.Config("aotRegenBrazo", 30)
		local campo = lado == 1 and "RegenBrazoI" or "RegenBrazoD"

		self["Set" .. campo](self, CurTime() + dur)
		self.AOT_RegenDur[campo] = dur
		if (lado == 1) then self:SetDurBrazoI(dur) else self:SetDurBrazoD(dur) end

		local corte = AOT.PosHueso(self, lado == 1 and H.ANTEBRAZO_I or H.ANTEBRAZO_D)
		self:Sangrar(corte, 150)
		self:EmitSound("physics/flesh/flesh_bloody_break.wav", 100, 60)
		self:EmitSound("npc/zombie_poison/pz_pain" .. math.random(1, 3) .. ".wav", 100, 45)

		-- Si sujetaba a alguien con esa mano, lo suelta.
		if (IsValid(self:GetPresa()) and self.AOT_ManoPresa == lado) then
			local presa = self:GetPresa()
			self:Soltar(true)

			if (IsValid(atacante) and atacante != presa) then
				AOT.Marcador(atacante, "¡RESCATE!", Color(120, 255, 120))
			end
		end
	end

	function ENT:CortarTendon(lado)
		local dur = AOT.Config("aotRegenTendon", 20)
		local campo = lado == 1 and "RegenTendonI" or "RegenTendonD"

		self["Set" .. campo](self, CurTime() + dur)
		self.AOT_RegenDur[campo] = dur
		self:EmitSound("npc/zombie_poison/pz_pain" .. math.random(1, 3) .. ".wav", 100, 50)

		if (AOT.ParteCortada(self, P.TENDON_I) and AOT.ParteCortada(self, P.TENDON_D)) then
			self:SetDerribado(true)
		end
	end

	function ENT:Cegar(dur)
		local estaba = self:Ciego()

		self:SetCegadoHasta(CurTime() + dur)
		self.AOT_Objetivo = nil

		if (!estaba) then
			self:EmitSound("npc/zombie_poison/pz_pain" .. math.random(1, 3) .. ".wav", 100, 55)
		end
	end

	-- Derribado: cae con "titan_dying" y se queda tumbado hasta regenerar un tendón. El ciclo
	-- va también por red (CicloDerribo) y el cliente lo impone al dibujar: si no, el cliente
	-- volvía a mostrarlo de pie en cuanto terminaba la caída.
	function ENT:FijarCicloDerribo(ciclo)
		self:SetCycle(ciclo)
		self:SetCicloDerribo(ciclo)
	end

	function ENT:EstadoDerribado()
		local CAIDA = 0.8
		local escala = self:GetEscala()

		self.loco:SetDesiredSpeed(0)
		self:Soltar(true)

		local seq = self:LookupSequence("titan_dying")
		self.AOT_Manual = false
		self.AOT_CicloFijo = true
		self.AOT_Anim = nil
		self:ResetSequence(seq)
		self:SetPlaybackRate(0)

		local inicio = CurTime()
		local tCaida = 1.8
		while (CurTime() - inicio < tCaida) do
			if (self:GetMuerto()) then return end
			local f = (CurTime() - inicio) / tCaida
			self:FijarCicloDerribo(CAIDA * f * f)
			coroutine.yield()
		end

		self:FijarCicloDerribo(CAIDA)
		util.ScreenShake(self:GetPos(), 8, 5, 1, 300 * escala)
		self:EmitSound("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav", 110, 50)

		-- En el suelo hasta que regenere al menos un tendón y, como mínimo, unos segundos (si no, un tendón
		-- que estaba a punto de regenerarse lo levantaba casi al instante y parecía que no caía).
		local caidoDesde = CurTime()

		while ((AOT.ParteCortada(self, P.TENDON_I) and AOT.ParteCortada(self, P.TENDON_D)) or CurTime() - caidoDesde < 8) do
			if (self:GetMuerto()) then return end
			if (self:GetSequence() != seq) then self:ResetSequence(seq) end
			self:FijarCicloDerribo(CAIDA)
			coroutine.wait(0.2)
		end

		inicio = CurTime()
		while (CurTime() - inicio < 2.5) do
			if (self:GetMuerto()) then return end
			self:FijarCicloDerribo(CAIDA * (1 - (CurTime() - inicio) / 2.5))
			coroutine.yield()
		end

		self.AOT_CicloFijo = false
		self:SetDerribado(false)
		self:Animar(ACT_WALK)
	end

	-- ============================================================
	-- Regeneración, pisadas y muerte
	-- ============================================================
	function ENT:ActualizarRegeneracion()
		local ahora = CurTime()

		for lado = 1, 2 do
			local campo = lado == 1 and "RegenBrazoI" or "RegenBrazoD"
			local fin = self["Get" .. campo](self)
			-- El brazo se oculta y vuelve a crecer en el cliente (ver BuildBonePositions).
			if (fin > 0 and ahora >= fin) then
				self["Set" .. campo](self, 0)
				self.AOT_VidaBrazo[lado] = self.AOT_VidaBrazoMax
			end

			local campoT = lado == 1 and "RegenTendonI" or "RegenTendonD"
			local finT = self["Get" .. campoT](self)

			if (finT > 0 and ahora >= finT) then
				self["Set" .. campoT](self, 0)
				self.AOT_VidaTendon[lado] = self.AOT_VidaTendonMax
			end
		end

		if (self.AOT_NucaRegen and ahora > self.AOT_NucaRegen) then
			self.AOT_NucaRegen = nil
			self.AOT_NucaVida = self.AOT_NucaMax
		end
	end

	-- Detecta cada vez que un pie toca el suelo (siguiendo la animación, no un temporizador).
	function ENT:Pisadas()
		if (self:GetMuerto() or self.AOT_Manual or self.AOT_CicloFijo) then return end

		self.AOT_Pies = self.AOT_Pies or {}

		local escala = self:GetEscala()
		local suelo = self:GetPos().z
		local movimiento = self.loco:GetVelocity():Length2D() > 15

		for i, hueso in ipairs({H.PIE_I, H.PIE_D}) do
			local pie = AOT.PosHueso(self, hueso)
			local alto = pie.z - suelo
			local e = self.AOT_Pies[i]

			if (!e) then
				e = {min = alto, max = alto, arriba = false}
				self.AOT_Pies[i] = e
			end

			e.min = math.min(e.min, alto)
			e.max = math.max(e.max, alto)

			local rango = e.max - e.min

			if (movimiento and rango > 1.5 * escala) then
				local f = (alto - e.min) / rango

				if (f > 0.5) then
					e.arriba = true
				elseif (f < 0.2 and e.arriba) then
					e.arriba = false
					self:Pisoton(pie)
				end
			end
		end
	end

	function ENT:Pisoton(pie)
		local escala = self:GetEscala()

		self:EmitSound("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav", math.Clamp(70 + escala * 3, 70, 120), math.Clamp(110 - escala * 6, 45, 100), 0.7)
		util.ScreenShake(pie, math.Clamp(escala * 0.6, 1, 8), 5, 0.4, 200 * escala)

		for _, p in ipairs(player.GetAll()) do
			if (p:Alive() and p:GetNW2Entity("aot_agarre") != self) then
				local dif = p:GetPos() - pie
				local plano = dif:Length2D()

				-- Solo si está en el suelo bajo el pie (no si pasa volando por encima).
				if (plano < 9 * escala and dif.z < 18 * escala and dif.z > -30 * escala) then
					local info = DamageInfo()
					info:SetAttacker(self)
					info:SetInflictor(self)
					info:SetDamageType(DMG_CRUSH)
					info:SetDamagePosition(pie)

					if (plano < 5 * escala) then
						-- Justo debajo: aplastado.
						info:SetDamage(AOT.Config("aotDanoPisoton", 200))
						p:EmitSound("physics/body/body_medium_break" .. math.random(2, 4) .. ".wav", 85)
					else
						-- De refilón: daño y empujón.
						info:SetDamage(AOT.Config("aotDanoPisotonRoce", 40))
						local empuje = dif
						empuje.z = 0
						if (empuje:LengthSqr() > 0.01) then empuje:Normalize() end
						p:SetVelocity(empuje * 450 + Vector(0, 0, 220))
					end

					p:TakeDamageInfo(info)
					p:ViewPunch(Angle(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(-12, 12)))
				end
			end
		end
	end

	function ENT:Think()
		self:ActualizarPresa()
		self:Pisadas()

		if (CurTime() >= (self.AOT_SigLento or 0)) then
			self.AOT_SigLento = CurTime() + 0.25
			self:ActualizarRegeneracion()
			self:SetHealth(1000000)
		end

		self:NextThink(CurTime())
		return true
	end

	function ENT:Morir(atacante)
		if (self:GetMuerto()) then return end

		self:SetMuerto(true)
		self:Soltar(true)
		self.loco:SetDesiredSpeed(0)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		AOT.TitanAbatido(self, atacante)

		local arma = IsValid(atacante) and atacante.GetActiveWeapon and atacante:GetActiveWeapon()
		hook.Run("OnNPCKilled", self, atacante, IsValid(arma) and arma or self)

		self:Secuencia("titan_dying", 0.8)
		self:EmitSound("npc/zombie_poison/pz_die" .. math.random(1, 2) .. ".wav", 110, 45)

		timer.Simple(2.5, function()
			if (IsValid(self)) then
				util.ScreenShake(self:GetPos(), 10, 5, 1.5, 400 * self:GetEscala())
				self:EmitSound("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav", 120, 40)
			end
		end)

		-- Se evapora poco a poco y desaparece.
		local id = "AOT_Evaporar" .. self:EntIndex()
		local inicio = CurTime() + 4
		local color = self:GetColor()

		self:SetRenderMode(RENDERMODE_TRANSCOLOR)

		timer.Create(id, 0.25, 0, function()
			if (!IsValid(self)) then
				timer.Remove(id)
				return
			end

			local f = math.Clamp((CurTime() - inicio) / 16, 0, 1)
			self:SetColor(Color(color.r, color.g, color.b, 255 * (1 - f)))

			if (f >= 1) then
				timer.Remove(id)
				self:Remove()
			end
		end)
	end

	function ENT:OnInjured(info)
		info:ScaleDamage(0)
		if (self:GetMuerto()) then return end

		local atacante = info:GetAttacker()

		-- Las balas no matan a un titán, pero un disparo en los ojos lo ciega un momento.
		if (info:IsBulletDamage() or info:IsExplosionDamage()) then
			local pos = info:GetDamagePosition()

			if (pos:Distance(AOT.PuntoParte(self, P.OJOS)) < AOT.RadioParte(self, P.OJOS) * 1.6) then
				self:Cegar(4)

				if (IsValid(atacante) and atacante:IsPlayer()) then
					AOT.Marcador(atacante, "¡Disparo en los ojos!", Color(120, 200, 255))
				end
			end

			self:Sangrar(pos, 10)
		end

		if (IsValid(atacante) and atacante:IsPlayer() and !IsValid(self.AOT_Objetivo)) then
			self.AOT_Provocado = atacante
		end
	end

	function ENT:OnKilled(info)
		self:SetHealth(1000000)
		self:Morir(info:GetAttacker())
	end

	function ENT:OnRemove()
		self:Soltar(false)
		timer.Remove("AOT_Evaporar" .. self:EntIndex())
	end
else
	-- ============================================================
	-- Cliente: vapor de regeneración y de evaporación
	-- ============================================================
	local HUESOS_VAPOR = {H.CUELLO, H.PECHO, H.CADERA, H.BRAZO_I, H.BRAZO_D, H.PIERNA_I, H.PIERNA_D, H.CABEZA}
	local MAT_VAPOR = "particle/particle_smokegrenade"
	local ANTEBRAZO = {H.ANTEBRAZO_I, H.ANTEBRAZO_D}
	local MANO = {H.MANO_I, H.MANO_D}

	function ENT:Vapor(pos, intensidad, tam)
		local emisor = self.AOT_Emisor
		if (!emisor) then return end

		local escala = self:GetEscala()
		tam = tam or 1

		local p = emisor:Add(MAT_VAPOR, pos + VectorRand() * 2 * escala * tam)

		if (p) then
			p:SetVelocity(VectorRand() * 12 * escala + Vector(0, 0, 22 * escala))
			p:SetDieTime(math.Rand(1.4, 2.8))
			p:SetStartAlpha(math.min(255, 170 * intensidad))
			p:SetEndAlpha(0)
			p:SetStartSize(5 * escala * tam)
			p:SetEndSize(17 * escala * tam)
			p:SetColor(240, 240, 240)
			p:SetRoll(math.Rand(0, 360))
			p:SetRollDelta(math.Rand(-1, 1))
			p:SetAirResistance(70)
		end
	end

	-- Brazo regenerándose: una nube densa envuelve el muñón y lo que va creciendo, para que no se
	-- vea un corte limpio ni un brazo a medias.
	function ENT:VaporBrazo(lado)
		local codo = AOT.PosHueso(self, ANTEBRAZO[lado])
		local f = self:FactorBrazo(lado)
		local punta = LerpVector(math.max(f, 0.15), codo, AOT.PosHueso(self, MANO[lado]))

		for _ = 1, 4 do
			self:Vapor(LerpVector(math.random(), codo, punta), 1.2, 1.2)
		end
	end

	function ENT:Think()
		if (CurTime() < (self.AOT_SigFx or 0)) then return end
		self.AOT_SigFx = CurTime() + 0.05

		if (self:GetPos():DistToSqr(EyePos()) > 9000 * 9000) then return end

		self.AOT_Emisor = self.AOT_Emisor or ParticleEmitter(self:GetPos())
		self.AOT_Emisor:SetPos(self:GetPos())

		if (self:GetMuerto()) then
			for _ = 1, 6 do
				self:Vapor(AOT.PosHueso(self, HUESOS_VAPOR[math.random(#HUESOS_VAPOR)]), 1.2, 1.3)
			end
			return
		end

		local ahora = CurTime()
		if (self:GetRegenBrazoI() > ahora) then self:VaporBrazo(1) end
		if (self:GetRegenBrazoD() > ahora) then self:VaporBrazo(2) end

		for _ = 1, 3 do
			if (self:GetRegenTendonI() > ahora) then self:Vapor(AOT.PuntoParte(self, P.TENDON_I), 1, 0.9) end
			if (self:GetRegenTendonD() > ahora) then self:Vapor(AOT.PuntoParte(self, P.TENDON_D), 1, 0.9) end
		end

		if (self:Ciego()) then
			for _ = 1, 2 do self:Vapor(AOT.PuntoParte(self, P.OJOS), 0.9, 0.7) end
		end
	end

	-- Brazo cortado: todos los huesos del codo hacia abajo se encogen hacia el codo (factor f).
	-- Con f = 0 no queda nada; al regenerar, el brazo vuelve a crecer entero, no "fino".
	local function EncogerBrazos(self)
		for lado = 1, 2 do
			local f = self:FactorBrazo(lado)

			if (f < 1) then
				local raiz = AOT.Hueso(self, ANTEBRAZO[lado])
				local mRaiz = raiz and self:GetBoneMatrix(raiz)

				if (mRaiz) then
					local base = mRaiz:GetTranslation()
					local e = math.max(f, 0.001)
					local escala = Vector(e, e, e)

					for _, b in ipairs(self:Rama(ANTEBRAZO[lado])) do
						local m = self:GetBoneMatrix(b)

						if (m) then
							m:SetTranslation(base + (m:GetTranslation() - base) * e)
							m:Scale(escala)
							self:SetBoneMatrix(b, m)
						end
					end
				end
			end
		end
	end

	function ENT:Initialize()
		self:SetCustomCollisionCheck(true)
		self:AddCallback("BuildBonePositions", EncogerBrazos)
	end

	function ENT:Draw()
		-- Tumbado: se impone la pose que manda el servidor (el cliente si no lo mostraba de pie).
		if (self:GetDerribado() and !self:GetMuerto()) then
			local seq = self:LookupSequence("titan_dying")

			if (seq and seq >= 0) then
				if (self:GetSequence() != seq) then self:SetSequence(seq) end
				self:SetPlaybackRate(0)
				self:SetCycle(self:GetCicloDerribo())
				self:InvalidateBoneCache()
			end
		end

		self:DrawModel()
	end

	function ENT:OnRemove()
		if (self.AOT_Emisor) then
			self.AOT_Emisor:Finish()
			self.AOT_Emisor = nil
		end
	end
end
