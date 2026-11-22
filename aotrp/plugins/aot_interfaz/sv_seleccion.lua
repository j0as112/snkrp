-- Escena de seleccion de personaje: la camara real del mapa. La fija el staff con /SeleccionCamara y se guarda
-- POR MAPA (ix.data, "seleccionEscena"). Sin camara guardada, el cliente usa el diorama de estudio.
-- (Mismo planteamiento que la seleccion del servidor de Naruto.)

util.AddNetworkString("aot_SeleccionEscena_Pedir")
util.AddNetworkString("aot_SeleccionEscena")

local function Escena()
	if (Schema.SeleccionEscena == nil) then
		Schema.SeleccionEscena = ix.data.Get("seleccionEscena") or false
	end

	return Schema.SeleccionEscena or nil
end

local function Guardar(esc)
	Schema.SeleccionEscena = esc or false
	ix.data.Set("seleccionEscena", esc)
end

local function Enviar(client)
	net.Start("aot_SeleccionEscena")
		net.WriteTable(Escena() or {})
	if (client) then net.Send(client) else net.Broadcast() end
end

net.Receive("aot_SeleccionEscena_Pedir", function(_, client)
	Enviar(client)
end)

-- Mientras el jugador no tiene personaje ve la escena: el punto de la camara debe estar en su PVS,
-- si no, los props y el mapa de esa zona no le llegan.
hook.Add("SetupPlayerVisibility", "aot_SeleccionEscena_PVS", function(client)
	if (client.GetCharacter and client:GetCharacter()) then return end

	local esc = Escena()

	if (esc and esc.cam and esc.cam.pos) then
		AddOriginToPVS(esc.cam.pos)
	end
end)

ix.command.Add("SeleccionCamara", {
	description = "Fija la camara de la pantalla de seleccion de personaje donde estas mirando ahora. Opcional: distancia, separacion y fov.",
	superAdminOnly = true,
	arguments = {
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, distancia, separacion, fov)
		-- Debe estar dentro del mapa y con suelo debajo; si no, los personajes saldrian en el vacio.
		if (!util.IsInWorld(client:EyePos())) then
			return "No puedo fijar la camara: estas fuera del mapa. Colocate dentro y sobre el suelo."
		end

		local suelo = util.TraceLine({
			start = client:GetPos(),
			endpos = client:GetPos() - Vector(0, 0, 400),
			mask = MASK_SOLID_BRUSHONLY
		})

		if (!suelo.Hit) then
			return "No puedo fijar la camara: no hay suelo bajo tus pies. Colocate sobre el suelo (sin noclip)."
		end

		local esc = {
			cam = {pos = client:EyePos(), ang = client:EyeAngles(), fov = math.Clamp(fov or 70, 30, 110)},
			dist = math.Clamp(distancia or 190, 80, 600),
			sep = math.Clamp(separacion or 70, 30, 200)
		}

		Guardar(esc)
		Enviar()

		return "Camara de seleccion guardada para este mapa. Los personajes saldran delante de ti."
	end
})

ix.command.Add("SeleccionBorrar", {
	description = "Quita la camara de seleccion de este mapa (vuelve al diorama de estudio).",
	superAdminOnly = true,
	OnRun = function(self, client)
		Guardar(nil)
		Enviar()

		return "Camara de seleccion eliminada: se usara el diorama de estudio."
	end
})
