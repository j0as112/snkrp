if (!SERVER) then return end

local PLUGIN = PLUGIN

util.AddNetworkString("ixAotBengala")
util.AddNetworkString("ixAotAlarma")

ix.log.AddType("aotBengala", function(client, color)
	return string.format("%s ha disparado una bengala %s.", client:Name(), color)
end)

ix.log.AddType("aotAlarma", function(client, texto)
	return string.format("%s ha hecho sonar la alarma: %s", client:Name(), texto)
end)

function PLUGIN:Disparar(client, color)
	if (!self.bengalas[color]) then return false end

	net.Start("ixAotBengala")
		net.WriteVector(client:EyePos() + Vector(0, 0, 10))
		net.WriteString(color)
	net.Broadcast()

	client:EmitSound("weapons/ar2/ar2_altfire.wav", 100, 130)
	ix.chat.Send(client, "bengala", color, false, nil, {color = color})
	ix.log.Add(client, "aotBengala", color)

	return true
end

-- Dispara usando la primera pistola de bengalas con cargas del inventario (los admins no la necesitan).
function PLUGIN:DispararConPistola(client, color)
	if (!self.bengalas[color]) then
		return "Color no válido. Usa: roja, verde, negra, amarilla o morada."
	end

	if (CurTime() < (client.ixAotSigBengala or 0)) then
		return "Espera un momento antes de disparar otra bengala."
	end

	local character = client:GetCharacter()
	local pistola

	for _, item in pairs(character and character:GetInventory():GetItems() or {}) do
		if (item.uniqueID == "pistola_bengalas" and item:GetData("cargas", item.cargasMax or 8) > 0) then
			pistola = item
			break
		end
	end

	if (!pistola and !client:IsAdmin()) then
		return "Necesitas una pistola de bengalas con cargas."
	end

	client.ixAotSigBengala = CurTime() + 3
	self:Disparar(client, color)

	if (pistola) then
		pistola:SetData("cargas", pistola:GetData("cargas", pistola.cargasMax or 8) - 1)
	end
end

function PLUGIN:Alarma(client, texto)
	texto = string.Trim(texto):sub(1, 200)

	net.Start("ixAotAlarma")
		net.WriteString(texto)
	net.Broadcast()

	ix.chat.Send(client, "alarma", texto)
	ix.log.Add(client, "aotAlarma", texto)
end
