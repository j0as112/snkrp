-- Partes del cuerpo de un titán: dónde están, cuánto miden y qué huesos las forman.
-- Los modelos de titán (hydralis_titan*) usan esqueleto mixamo y sus hitboxes no tienen
-- grupos, así que todo se resuelve con posiciones de huesos.

AOT = AOT or {}

AOT.PARTE = {
	NUCA = 1,
	OJOS = 2,
	BRAZO_I = 3,
	BRAZO_D = 4,
	TENDON_I = 5,
	TENDON_D = 6,
	CUERPO = 7,
}

AOT.NOMBRE_PARTE = {
	[1] = "Nuca",
	[2] = "Ojos",
	[3] = "Brazo izquierdo",
	[4] = "Brazo derecho",
	[5] = "Tendón izquierdo",
	[6] = "Tendón derecho",
	[7] = "Cuerpo",
}

-- Orden de prioridad al resolver un corte: si el filo pasa por la nuca, cuenta la nuca.
AOT.PRIORIDAD = {1, 2, 5, 6, 3, 4, 7}

-- Radio de cada parte en unidades del modelo sin escalar (se multiplica por la escala).
AOT.RADIO_PARTE = {
	[1] = 8,
	[2] = 5,
	[3] = 4.5,
	[4] = 4.5,
	[5] = 4.5,
	[6] = 4.5,
	[7] = 10,
}

AOT.HUESO = {
	CUELLO = "mixamorig:Neck",
	CABEZA = "mixamorig:Head",
	OJO_I = "mixamorig:EyeL",
	OJO_D = "mixamorig:EyeR",
	PECHO = "mixamorig:Spine2",
	TORSO = "mixamorig:Spine1",
	CADERA = "mixamorig:Hips",
	BRAZO_I = "mixamorig:LeftArm",
	ANTEBRAZO_I = "mixamorig:LeftForeArm",
	MANO_I = "mixamorig:LeftHand",
	BRAZO_D = "mixamorig:RightArm",
	ANTEBRAZO_D = "mixamorig:RightForeArm",
	MANO_D = "mixamorig:RightHand",
	PIERNA_I = "mixamorig:LeftLeg",
	PIE_I = "mixamorig:LeftFoot",
	PIERNA_D = "mixamorig:RightLeg",
	PIE_D = "mixamorig:RightFoot",
}

-- Altura aproximada (fracción de 70 unidades * escala) por si un hueso no está disponible.
local ALTURA_RESPALDO = {
	["mixamorig:Neck"] = 0.86, ["mixamorig:Head"] = 0.93, ["mixamorig:EyeL"] = 0.95, ["mixamorig:EyeR"] = 0.95,
	["mixamorig:Spine2"] = 0.72, ["mixamorig:Spine1"] = 0.64, ["mixamorig:Hips"] = 0.5,
	["mixamorig:LeftArm"] = 0.8, ["mixamorig:LeftForeArm"] = 0.62, ["mixamorig:LeftHand"] = 0.48,
	["mixamorig:RightArm"] = 0.8, ["mixamorig:RightForeArm"] = 0.62, ["mixamorig:RightHand"] = 0.48,
	["mixamorig:LeftLeg"] = 0.27, ["mixamorig:LeftFoot"] = 0.04, ["mixamorig:RightLeg"] = 0.27, ["mixamorig:RightFoot"] = 0.04,
}

function AOT.EsTitan(ent)
	return IsValid(ent) and ent.AOT_EsTitan == true
end

function AOT.Escala(ent)
	if (ent.GetEscala) then
		local e = ent:GetEscala()
		if (e and e > 0) then return e end
	end

	return ent:GetModelScale() or 1
end

function AOT.Hueso(ent, nombre)
	ent.AOT_CacheHuesos = ent.AOT_CacheHuesos or {}

	local modelo = ent:GetModel()
	if (ent.AOT_CacheModelo != modelo) then
		ent.AOT_CacheHuesos = {}
		ent.AOT_CacheModelo = modelo
	end

	local id = ent.AOT_CacheHuesos[nombre]

	if (id == nil) then
		id = ent:LookupBone(nombre) or -1
		ent.AOT_CacheHuesos[nombre] = id
	end

	return id >= 0 and id or nil
end

-- Posición mundial de un hueso, con respaldo aproximado si el servidor no la tiene.
function AOT.PosHueso(ent, nombre)
	local id = AOT.Hueso(ent, nombre)

	if (id) then
		local pos = ent:GetBonePosition(id)

		if (pos and pos:DistToSqr(ent:GetPos()) > 4) then
			return pos
		end

		local m = ent:GetBoneMatrix(id)
		if (m) then
			local t = m:GetTranslation()
			if (t:DistToSqr(ent:GetPos()) > 4) then return t end
		end
	end

	local escala = AOT.Escala(ent)
	local altura = (ALTURA_RESPALDO[nombre] or 0.5) * 70 * escala
	local lateral = 0

	if (nombre:find("Left")) then lateral = -9 * escala elseif (nombre:find("Right")) then lateral = 9 * escala end

	return ent:GetPos() + Vector(0, 0, altura) + ent:GetRight() * lateral
end

-- Punto de golpeo/fijación de cada parte.
function AOT.PuntoParte(ent, parte)
	local P, H = AOT.PARTE, AOT.HUESO
	local escala = AOT.Escala(ent)
	local fwd = ent:GetForward()

	if (parte == P.NUCA) then
		-- Detrás del cuello, entre la nuca y los omoplatos.
		local cuello = AOT.PosHueso(ent, H.CUELLO)
		return cuello - fwd * 3 * escala - Vector(0, 0, 1.5 * escala)
	elseif (parte == P.OJOS) then
		if (AOT.Hueso(ent, H.OJO_I) and AOT.Hueso(ent, H.OJO_D)) then
			return (AOT.PosHueso(ent, H.OJO_I) + AOT.PosHueso(ent, H.OJO_D)) * 0.5 + fwd * 1.5 * escala
		end

		return AOT.PosHueso(ent, H.CABEZA) + fwd * 4 * escala + Vector(0, 0, 3 * escala)
	elseif (parte == P.BRAZO_I) then
		return AOT.PosHueso(ent, H.ANTEBRAZO_I)
	elseif (parte == P.BRAZO_D) then
		return AOT.PosHueso(ent, H.ANTEBRAZO_D)
	elseif (parte == P.TENDON_I) then
		-- Parte trasera de la pantorrilla (tendón de Aquiles).
		return LerpVector(0.55, AOT.PosHueso(ent, H.PIERNA_I), AOT.PosHueso(ent, H.PIE_I)) - fwd * 2 * escala
	elseif (parte == P.TENDON_D) then
		return LerpVector(0.55, AOT.PosHueso(ent, H.PIERNA_D), AOT.PosHueso(ent, H.PIE_D)) - fwd * 2 * escala
	end

	return AOT.PosHueso(ent, H.TORSO)
end

function AOT.RadioParte(ent, parte)
	return (AOT.RADIO_PARTE[parte] or 6) * AOT.Escala(ent)
end

-- Boca del titán (donde acaban sus presas).
function AOT.PosBoca(ent)
	local escala = AOT.Escala(ent)
	return AOT.PosHueso(ent, AOT.HUESO.CABEZA) + ent:GetForward() * 4 * escala + Vector(0, 0, 1 * escala)
end

-- ¿Está cortada (o regenerándose) una parte? Las funciones de red las define el titán.
function AOT.ParteCortada(ent, parte)
	if (!AOT.EsTitan(ent)) then return false end

	local P = AOT.PARTE
	local ahora = CurTime()

	if (parte == P.BRAZO_I) then return ent:GetRegenBrazoI() > ahora end
	if (parte == P.BRAZO_D) then return ent:GetRegenBrazoD() > ahora end
	if (parte == P.TENDON_I) then return ent:GetRegenTendonI() > ahora end
	if (parte == P.TENDON_D) then return ent:GetRegenTendonD() > ahora end
	if (parte == P.OJOS) then return ent:GetCegadoHasta() > ahora end

	return false
end

-- Distancia de un punto a un segmento (para saber si el filo pasa por una parte).
function AOT.DistPuntoSegmento(p, a, b)
	local ab = b - a
	local largo = ab:LengthSqr()

	if (largo < 0.001) then return p:Distance(a), a end

	local t = math.Clamp((p - a):Dot(ab) / largo, 0, 1)
	local cercano = a + ab * t

	return p:Distance(cercano), cercano
end

-- Metros aproximados de altura de un titán (1 unidad ≈ 1,9 cm).
function AOT.Metros(ent)
	return math.Round(70 * AOT.Escala(ent) * 0.01905)
end
