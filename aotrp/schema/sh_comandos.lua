-- Comandos de mando y de staff.

local function Normalizar(texto)
	texto = string.lower(texto or "")
	local tildes = {["á"] = "a", ["é"] = "e", ["í"] = "i", ["ó"] = "o", ["ú"] = "u", ["ñ"] = "n"}

	for con, sin in pairs(tildes) do
		texto = texto:gsub(con, sin)
	end

	return texto
end

-- Busca un rango (clase) de una facción por nombre aproximado.
local function BuscarRango(faccion, nombre)
	nombre = Normalizar(nombre)

	for _, clase in pairs(ix.class.list) do
		if (clase.faction == faccion and Normalizar(clase.name):find(nombre, 1, true)) then
			return clase
		end
	end
end

local CUERPOS = {
	exploracion = "exploracion",
	guarnicion = "guarnicion",
	policia = "policia",
}

ix.command.Add("Rango", {
	description = "Asigna un rango a un personaje de tu cuerpo (capitanes, comandantes y staff).",
	arguments = {ix.type.character, ix.type.text},
	OnRun = function(self, client, objetivo, nombreRango)
		local clase = BuscarRango(objetivo:GetFaction(), nombreRango)

		if (!clase) then
			return "Ese rango no existe en el cuerpo de " .. objetivo:GetName() .. "."
		end

		if (!client:IsAdmin()) then
			local mio = client:GetCharacter()

			if (!mio or mio:GetFaction() != objetivo:GetFaction()) then
				return "Solo puedes asignar rangos en tu propio cuerpo."
			end

			if (Schema:Rango(mio) < 3 or clase.nivel >= Schema:Rango(mio) or Schema:Rango(objetivo) >= Schema:Rango(mio)) then
				return "No tienes autoridad para asignar ese rango."
			end
		end

		objetivo:SetClass(clase.index)

		local jugador = objetivo:GetPlayer()
		if (IsValid(jugador)) then
			jugador:Notify("Ahora eres " .. clase.name .. ".")
		end

		return objetivo:GetName() .. " ahora es " .. clase.name .. "."
	end
})

ix.command.Add("Graduar", {
	description = "Gradúa a un cadete en un cuerpo: exploracion, guarnicion o policia (instructores y staff).",
	arguments = {ix.type.character, ix.type.string},
	OnRun = function(self, client, objetivo, cuerpo)
		local mio = client:GetCharacter()
		local esInstructor = mio and mio:GetClass() == CLASS_CADETE_INSTRUCTOR

		if (!client:IsAdmin() and !esInstructor) then
			return "Solo los instructores y el staff pueden graduar cadetes."
		end

		if (objetivo:GetFaction() != FACTION_CADETE) then
			return objetivo:GetName() .. " no es un cadete."
		end

		local faccion = ix.faction.teams[CUERPOS[Normalizar(cuerpo)] or ""]

		if (!faccion) then
			return "Cuerpo no válido. Usa: exploracion, guarnicion o policia."
		end

		objetivo:SetFaction(faccion.index)

		for _, clase in pairs(ix.class.list) do
			if (clase.faction == faccion.index and clase.isDefault) then
				objetivo:SetClass(clase.index)
				break
			end
		end

		local jugador = objetivo:GetPlayer()
		if (IsValid(jugador)) then
			jugador:Notify("¡Te has graduado! Ahora perteneces a: " .. faccion.name .. ".")
		end

		return objetivo:GetName() .. " se ha graduado en " .. faccion.name .. "."
	end
})

ix.command.Add("EstablecerAltura", {
	description = "Fija la altura de un personaje (0.3 a 1.9; 1 = normal).",
	adminOnly = true,
	arguments = {ix.type.character, ix.type.number},
	OnRun = function(self, client, objetivo, altura)
		if (altura < 0.3 or altura > 1.9) then
			return "La altura debe estar entre 0.3 y 1.9."
		end

		objetivo:SetAltura(altura)

		local jugador = objetivo:GetPlayer()
		if (IsValid(jugador) and jugador:GetCharacter() == objetivo) then
			jugador:SetModelScale(altura, 0.5)
		end

		return "Altura de " .. objetivo:GetName() .. ": " .. altura .. "."
	end
})
