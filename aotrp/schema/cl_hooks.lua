-- Rango visible al mirar a otro personaje.
function Schema:PopulateCharacterInfo(client, character, tooltip)
	local clase = ix.class.list[character:GetClass()]
	if (!clase) then return end

	local faccion = ix.faction.indices[character:GetFaction()]
	local fila = tooltip:AddRowAfter("name", "aotRango")
	fila:SetText(clase.name .. (faccion and (" · " .. faccion.name) or ""))
	fila:SetBackgroundColor(faccion and faccion.color or color_black)
	fila:SizeToContents()
end

function Schema:BuildBusinessMenu()
	return false
end
