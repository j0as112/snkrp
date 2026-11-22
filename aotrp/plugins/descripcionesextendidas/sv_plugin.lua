util.AddNetworkString("ixOpenDetailedDescriptions")
util.AddNetworkString("ixSetDetailedDescriptions")
util.AddNetworkString("ixEditDetailedDescriptions")

net.Receive("ixEditDetailedDescriptions", function(len, client)
	-- Siempre se edita el personaje de quien envía el mensaje, nunca otro.
	local character = IsValid(client) and client:GetCharacter()

	if (!character or CurTime() < (client.ixDescExtCD or 0)) then return end
	client.ixDescExtCD = CurTime() + 2

	local textEntryURL = string.Trim(net.ReadString()):sub(1, 512)
	local text = string.Trim(net.ReadString()):sub(1, 4000)

	-- Solo se aceptan URLs http(s) para la foto de referencia.
	if (textEntryURL != "" and !textEntryURL:find("^https?://")) then
		client:Notify("La URL de la foto debe empezar por http:// o https://")
		textEntryURL = ""
	end

	character:SetData("textDetDescData", text != "" and text or nil)
	character:SetData("textDetDescDataURL", textEntryURL != "" and textEntryURL or nil)
	client:Notify("Descripción extendida actualizada.")
end)

function PLUGIN:OnPlayerOptionSelected(client, callingClient, option)
	if (option == "Examinar") then
		local textEntryData = client:GetCharacter():GetData("textDetDescData", nil) or "Sin descripción extendida."
		local textEntryDataURL = client:GetCharacter():GetData("textDetDescDataURL", nil) or "Sin foto de referencia."

		net.Start("ixOpenDetailedDescriptions")
			net.WriteEntity(client)
			net.WriteString(textEntryData)
			net.WriteString(textEntryDataURL)
		net.Send(callingClient)
	end
end